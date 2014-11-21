#!/bin/bash

sed s/HOSTNAME/$HOSTNAME/ /opt/hadoop/etc/hadoop/core-site.xml.template > /opt/hadoop/etc/hadoop/core-site.xml

mkdir -p /var/log/hadoop
mkdir -p /var/log/accumulo
mkdir -p /var/log/elasticsearch

service sshd start
/opt/zookeeper/bin/zkServer.sh start

if [ ! -d "/tmp/hadoop-root" ]; then
  /opt/hadoop/bin/hdfs namenode -format
fi
/opt/hadoop/sbin/start-dfs.sh
/opt/hadoop/sbin/start-yarn.sh

if [ $(/opt/hadoop/bin/hadoop fs -ls /user | grep accumulo | wc -l) == "0" ]; then
  echo "Creating accumulo user in hdfs"
  /opt/hadoop/bin/hadoop fs -mkdir -p /user/accumulo
  /opt/hadoop/bin/hadoop fs -chown accumulo /user/accumulo
fi

if /opt/accumulo/bin/accumulo info 2>&1 | grep --quiet "Accumulo not initialized"; then
  /opt/accumulo/bin/accumulo init --instance-name lumify --password secret --clear-instance-name
fi
/opt/accumulo/bin/start-all.sh

/opt/elasticsearch/bin/elasticsearch > /dev/null &

/bin/bash
