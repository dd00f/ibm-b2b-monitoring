#!/bin/sh
#install-cc-log-monitoring.sh


MONITORING_HOST_NAME=`hostname -s`
REPOSITORY_URL=DISABLED

if [ -f /etc/monitoring/init.sh ]; then
    source /etc/monitoring/init.sh
fi

CC_DIR="$1"

echo "Downloading control center filebeat prospector"
service filebeat stop
echo wget -q $REPOSITORY_URL/ccmon/prospector-cc.yml.txt -O /etc/monitoring/filebeat-config/prospector-cc.yml
wget -q $REPOSITORY_URL/ccmon/prospector-cc.yml.txt -O /etc/monitoring/filebeat-config/prospector-cc.yml
sed -i -- s#CC_DIR#"$CC_DIR"#g /etc/monitoring/filebeat-config/prospector-cc.yml
service filebeat start

