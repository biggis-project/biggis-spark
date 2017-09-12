#!/usr/bin/env bash
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

# Determine whether this container will run as master, worker, or with another command
if [ -z "$1" ]; then
  echo "Select the role for this container with the docker cmd 'master' or 'worker'"
else
  if [ $1 = "master" ]; then
    bootstrap
    echo "[ $(date) ] Start Spark master"
    exec spark-class org.apache.spark.deploy.master.Master --host $(hostname -i)
  elif [ $1 = "worker" ]; then
    bootstrap
    echo "[ $(date) ] Start Spark worker"
    exec spark-class org.apache.spark.deploy.worker.Worker --host $(hostname -i) spark://${SPARK_MASTER_ADDRESS}:7077
  else
    exec "$@"
  fi
fi
