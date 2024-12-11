FROM openjdk:8u212-jre-alpine

ARG build_date=unspecified

LABEL org.label-schema.name="zookeeper" \
      org.label-schema.description="Apache Zookeeper" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/kostapc/zookeeper-docker" \
      maintainer="kostapc"

ENV ZOOKEEPER_VERSION="3.9.3"
ENV ZOOKEEPER_DISTR=${ZOOKEEPER_VERSION}-bin
ENV ZK_HOME=/opt/zookeeper

RUN \
  uname -a && \
  apk --update add gpgme bash curl jq dos2unix && \
  rm -rf /var/cache/apk/*

RUN apk add ca-certificates && update-ca-certificates

COPY download-zookeeper.sh /tmp
COPY download-zookeeper-mirrored.sh /tmp
RUN \
  dos2unix /tmp/download-zookeeper.sh && chmod +x /tmp/download-zookeeper.sh && \
  dos2unix /tmp/download-zookeeper-mirrored.sh && chmod +x /tmp/download-zookeeper-mirrored.sh && \
  /tmp/download-zookeeper-mirrored.sh
#  /tmp/download-zookeeper.sh

RUN \
 mkdir -p /opt && \
 tar -xzf /tmp/apache-zookeeper-${ZOOKEEPER_DISTR}.tar.gz -C /opt && \
 ln -s /opt/apache-zookeeper-${ZOOKEEPER_DISTR} ${ZK_HOME} && \
 ls /opt && \
 mv /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg && \
 sed  -i "s|/tmp/apache-zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

ADD start-zk.sh /usr/bin/start-zk.sh
RUN dos2unix /usr/bin/start-zk.sh && apk del dos2unix

EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper
VOLUME ["/opt/apache-zookeeper-${ZOOKEEPER_VERSION}/conf", "/opt/apache-zookeeper-${ZOOKEEPER_VERSION}/data"]

CMD ["/bin/sh", "/usr/bin/start-zk.sh"]
