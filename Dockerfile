FROM biggis/base:oraclejava8-jre

MAINTAINER wipatrick

ARG SPARK_VERSION=2.0.2
ARG SPARK_ARCHIVE=http://d3kbcqa49mib13.cloudfront.net/spark-2.0.2-bin-hadoop2.7.tgz

ARG BUILD_DATE
ARG VCS_REF

LABEL eu.biggis-project.build-date=$BUILD_DATE \
      eu.biggis-project.license="MIT" \
      eu.biggis-project.name="BigGIS" \
      eu.biggis-project.url="http://biggis-project.eu/" \
      eu.biggis-project.vcs-ref=$VCS_REF \
      eu.biggis-project.vcs-type="Git" \
      eu.biggis-project.vcs-url="https://github.com/biggis-project/biggis-spark" \
      eu.biggis-project.environment="dev" \
      eu.biggis-project.version=$SPARK_VERSION

RUN set -x && \
    apk --update add --virtual build-dependencies curl && \
    curl -s ${SPARK_ARCHIVE} | tar -xzf - -C /opt && \
    ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop2.7 /opt/spark && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

ENV SPARK_HOME /opt/spark-${SPARK_VERSION}-bin-hadoop2.7
ENV PATH $PATH:${SPARK_HOME}/bin

ADD start.sh $SPARK_HOME/bin/

WORKDIR /opt/spark

CMD ["start.sh", "sh", "-c"]
