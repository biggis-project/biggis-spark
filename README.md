# BigGIS Spark
[![Build Status](https://api.travis-ci.org/biggis-project/biggis-spark.svg)](https://travis-ci.org/biggis-project/biggis-spark)
Docker container for Apache Spark


## Prerequisites
Docker Compose >= 1.9.0

## Deployment
```sh
docker-compose up -d
```
The image ```biggis/spark-client:2.1.0``` can be used submit Spark jobs to the Spark cluster. Edit the environment variables and volumes in the ```docker-compose.client.yml``` according to your setup and specify what spark job (jar and class) to submit. The jar file is mapped as a local volume.  
```yaml
version: '2.1'

services:

  spark-client:
    image: biggis/spark-client:2.1.0
    hostname: spark-client
    command: submit.sh /opt/spark-example-1.0-SNAPSHOT.jar hdfs:///hamlet.txt hdfs:///counts
    environment:
      USER_ID: ${USER_ID-1000}
      USER_NAME: spark-client
      TIMEZONE: Europe/Berlin
      DEPLOY_MODE: client
      CLASS: eu.biggis.sparkexample.WordCount
      SPARK_MASTER_ADRESS: spark-master
      HADOOP_MASTER_ADDRESS: hdfs-name
    volumes:
      - ./job/spark-example/target/spark-example-1.0-SNAPSHOT.jar:/opt/spark-example-1.0-SNAPSHOT.jar

networks:
  default:
    external:
      name: biggishdfs_default
```
Then run the ```docker-compose.client.yml``` file as following.
```sh
docker-compose -f docker-compose.client.yml run --rm spark-client
```

## Ports
- Spark WebUI is running on port `8080`
