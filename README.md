# BigGIS Spark
[![Build Status](https://api.travis-ci.org/biggis-project/biggis-spark.svg)](https://travis-ci.org/biggis-project/biggis-spark)
Docker container for Apache Spark


## Prerequisites
Docker Compose >= 1.9.0

## Deployment

**On local setup**:
```sh
docker-compose up -d
```

**On Rancher**:

**Note**: HDFS stack should be deployed and running before Spark stack is deployed.

* NFS server and Rancher NFS service need to be configured in the cluster. The NFS volume `spark-home` need to be created via the Rancher WebUI, which is needed for Apache Zepelin.
* Add host label `spark-master=true` to any of your hosts.
* Create new Spark stack `spark` via Rancher WebUI and deploy `docker-compose.rancher.yml`.

## Submit Spark Job
Build Spark sample job.
```sh
cd job/spark-example
mvn clean package
```
### Using Spark Client Image
The image ```biggis/spark-client:2.1.0``` can be used submit Spark jobs to the Spark cluster. Edit the environment variables and volumes in the ```docker-compose.client.yml``` according to your setup and specify what spark job (jar and class) to submit. The jar file is mapped as a local volume.  

Then run the ```docker-compose.client.yml``` file as following.
```sh
docker-compose -f docker-compose.client.yml run --rm spark-client
```

### Using Spark REST API
You can also upload the job jar to HDFS and deploy the Spark job via curl.

**Example**: WordCount hamlet.txt
1. Upload hamlet.txt from [biggis-hdfs](https://github.com/biggis-project/biggis-hdfs) repository:
```sh
curl -u hdfs:password \
     -F 'file=@data/hamlet.txt' \
     -X POST http://localhost:3000/api/v1/upload/files?hdfspath=/demo/hamlet.txt
```
2. Upload packaged `spark-example-1.0-SNAPSHOT.jar`:
```sh
curl -u hdfs:password -F 'job=@job/spark-example/target/spark-example-1.0-SNAPSHOT.jar' http://localhost:3000/api/v1/upload/jobs?hdfspath=/jobs/spark-example
```
3. Deploy Spark job:
```sh
curl -X POST http://localhost:6066/v1/submissions/create --header "Content-Type:application/json;charset=UTF-8" --data @wordcount-job.json
```

## Ports
- Spark WebUI is running on port `8080`
