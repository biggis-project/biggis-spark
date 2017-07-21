#!/usr/bin/env bash
set -eo pipefail

DEPLOY_MODE=${DEPLOY_MODE:-cluster}
CLASS=${CLASS}
SPARK_MASTER_ADRESS=${SPARK_MASTER_ADDRESS:-master}
PATH_TO_JAR=$1

function bootstrap {
  # Run in all cases
  if [ ! -v ${HADOOP_MASTER_ADDRESS} ]; then
    source /sbin/hdfs-lib.sh

    template $HADOOP_CONF_DIR/core-site.xml
    template $HADOOP_CONF_DIR/hdfs-site.xml

    sed -i.bak "s/{HADOOP_MASTER_ADDRESS}/${HADOOP_MASTER_ADDRESS}/g" ${HADOOP_CONF_DIR}/core-site.xml
  fi
}

function usage {
  echo "[ $(date) ] Usage: docker-compose -f docker-compose.client.yml run --rm spark-client submit.sh [ /opt/sample.jar ]"
}

if [ $# -eq 0 ]; then
  echo "[ $(date) ] Specify spark-submit deployment arguments"
  usage
else
  bootstrap
  echo "[ $(date) ] Submit Spark job"
  exec $SPARK_HOME/bin/spark-submit \
        --deploy-mode $DEPLOY_MODE \
        --class $CLASS \
        --master spark://$SPARK_MASTER_ADRESS:7077 \
        --driver-memory 1g \
        --executor-memory 1g \
        --executor-cores 1 \
        $PATH_TO_JAR
fi
