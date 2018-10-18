#!/usr/bin/env bash

REMAINING_SYS_MEM_IN_PERCENT=${REMAINING_SYS_MEM_IN_PERCENT:-20}

# Credit: https://github.com/geodocker/geodocker-spark/blob/master/fs/sbin/entrypoint.sh
set -eo pipefail

function bootstrap {
  # Run in all cases
  if [ ! -v ${HADOOP_MASTER_ADDRESS} ]; then
    source /sbin/hdfs-lib.sh

    template $HADOOP_CONF_DIR/core-site.xml
    template $HADOOP_CONF_DIR/hdfs-site.xml

    sed -i.bak "s/{HADOOP_MASTER_ADDRESS}/${HADOOP_MASTER_ADDRESS}/g" ${HADOOP_CONF_DIR}/core-site.xml
  fi
}

function dynamicMemoryAllocation {
  SPARK_WORKER_MEM_PERCENT_FLOAT=$(echo $(( 100 - $REMAINING_SYS_MEM_IN_PERCENT )) / 100 | bc -l)
  TOTAL_MEM_AVAILABLE=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
  SPARK_WORKER_PORTION_IN_MEGABYTE=$(echo $TOTAL_MEM_AVAILABLE*$SPARK_WORKER_MEM_PERCENT_FLOAT/1024 | bc | awk '{print int($1)}')

  sed -i -e "s/SPARK_WORKER_MEMORY=4G/SPARK_WORKER_MEMORY=${SPARK_WORKER_PORTION_IN_MEGABYTE}m/g" $SPARK_CONF_DIR/spark-env.sh
}

function setWorkerInstances {
  sed -i -e "s/SPARK_WORKER_INSTANCS=1/SPARK_WORKER_INSTANCS=${SPARK_WORKER_INSTANCS}/g" $SPARK_CONF_DIR/spark-env.sh
}

# Determine whether this container will run as master, worker, or with another command
if [ -z "$1" ]; then
  echo "Select the role for this container with the docker cmd 'master' or 'worker'"
else
  if [ $1 = "master" ]; then
    bootstrap
    dynamicMemoryAllocation
    setWorkerInstances
    echo "[ $(date) ] Start Spark master"
    exec spark-class org.apache.spark.deploy.master.Master --host $(hostname -i)
  elif [ $1 = "worker" ]; then
    bootstrap
    dynamicMemoryAllocatio
    setWorkerInstances
    echo "[ $(date) ] Start Spark worker"
    exec spark-class org.apache.spark.deploy.worker.Worker --host $(hostname -i) spark://${SPARK_MASTER_ADDRESS}:7077
  else
    exec "$@"
  fi
fi
