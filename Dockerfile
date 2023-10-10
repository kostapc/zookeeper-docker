FROM openjdk:8u212-jre-alpine

ARG build_date=unspecified

LABEL org.label-schema.name="zookeeper" \
      org.label-schema.description="Apache Zookeeper" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/kostapc/zookeeper-docker" \
      maintainer="kostapc"

ENV ZOOKEEPER_VERSION="3.5.5"
ENV ZK_HOME /opt/apache-zookeeper-${ZOOKEEPER_VERSION}

RUN apk --update add gpgme bash curl jq dos2unix

COPY download-zookeeper.sh /tmp

RUN \
 dos2unix /tmp/download-zookeeper.sh && \
 /tmp/download-zookeeper.sh && \
 mkdir -p /opt && \
 tar -xzf /tmp/apache-zookeeper-${ZOOKEEPER_VERSION}.tar.gz -C /opt && \
 mv /opt/apache-zookeeper-${ZOOKEEPER_VERSION}/conf/zoo_sample.cfg /opt/apache-zookeeper-${ZOOKEEPER_VERSION}/conf/zoo.cfg && \
 sed  -i "s|/tmp/apache-zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data && \
 ln -s /opt/apache-zookeeper-${ZOOKEEPER_VERSION} /opt/zookeeper

RUN apk del gpgme curl jq && rm -rf /var/cache/apk/*

ADD start-zk.sh /usr/bin/start-zk.sh
RUN dos2unix /usr/bin/start-zk.sh && apk del dos2unix

EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper
VOLUME ["/opt/apache-zookeeper-${ZOOKEEPER_VERSION}/conf", "/opt/apache-zookeeper-${ZOOKEEPER_VERSION}/data"]

CMD ["/bin/sh", "/usr/bin/start-zk.sh"]
