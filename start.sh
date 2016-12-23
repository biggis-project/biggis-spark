#!/bin/sh

# Determine whether this container will run as master, worker, or with another command
if [ -z "$1" ]; then
  echo "Select the role for this container with the docker cmd 'master' or 'worker'"
else
  if [ $1 = "master" ]; then
    exec spark-class org.apache.spark.deploy.master.Master --host $(hostname)
  elif [ $1 = "worker" ]; then
    exec spark-class org.apache.spark.deploy.worker.Worker --host $(hostname) spark://${SPARK_MASTER}:7077
  else
    exec "$@"
  fi
fi
