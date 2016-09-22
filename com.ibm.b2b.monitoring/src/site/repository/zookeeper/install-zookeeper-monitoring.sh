#!/bin/sh

# to execute remotely : 
# wget -O - http://myserver.com/monitoring/zookeeper/install-zookeeper-monitoring.sh | bash -s (PATH_TO_ZOOKEEPER)
# Note that PATH_TO_ZOOKEEPER is set to "/opt/zookeeper" by default
# example
# wget -O - http://myserver.com/monitoring/zookeeper/install-zookeeper-monitoring.sh | bash -s /opt/zookeeper
# wget -O - http://myserver.com/monitoring/zookeeper/install-zookeeper-monitoring.sh | bash

MONITORING_HOST_NAME=`hostname -s`
GRAFANA_SERVER=DISABLED
GRAFANA_PORT=DISABLED
REPOSITORY_URL=http://myserver.com/monitoring

if [ -f /etc/monitoring/init.sh ]; then
    source /etc/monitoring/init.sh
fi

if [ -z ${1+x} ]; 
then 
	echo "Parameter 1 is unset, set ZOOKEEPER_DIR to default"; 
	ZOOKEEPER_DIR="/opt/zookeeper"
else 
	echo "Parameter 1 is set to '$1', assigned to ZOOKEEPER_DIR"; 
	ZOOKEEPER_DIR="$1"
fi

echo "ZOOKEEPER_DIR set to '$ZOOKEEPER_DIR'"; 

ZOOKEEPER_CONF_DIR="$ZOOKEEPER_DIR"/conf
ZOOKEEPER_CONF_FILE="$ZOOKEEPER_CONF_DIR"/java.env
ZOOKEEPER_CONF_BACKUP_FILE="$ZOOKEEPER_CONF_FILE".monitoring.backup
ZOOKEEPER_MON_DIR="$ZOOKEEPER_DIR"/monitoring
ZOOKEEPER_MON_FILE="$ZOOKEEPER_MON_DIR"/jmxtrans-agent-Zookeeper.xml
ZOOKEEPER_MON_JAR_FILE="$ZOOKEEPER_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar

if [ "$GRAFANA_SERVER" != "DISABLED" ];
then
	# ensure zookeeper is installed
	#if [ ! -f "$ZOOKEEPER_CONF_FILE" ]; then
	#    echo "Installation failed. Unable to find file '$ZOOKEEPER_CONF_FILE'"
	#fi

	echo "Downloading Monitoring configuration files to '$ZOOKEEPER_MON_DIR'"

	mkdir "$ZOOKEEPER_MON_DIR"

	wget -q "$REPOSITORY_URL"/zookeeper/jmxtrans-agent-1.0.10-SNAPSHOT.jar -O "$ZOOKEEPER_MON_JAR_FILE"
	chmod a+rw "$ZOOKEEPER_MON_JAR_FILE"

	wget -q "$REPOSITORY_URL"/zookeeper/jmxtrans-agent-Zookeeper.xml -O "$ZOOKEEPER_MON_FILE"
	chmod a+rw "$ZOOKEEPER_MON_FILE"

	echo "Configuring the Zookeeper JVM monitoring templates."

	sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$ZOOKEEPER_MON_FILE"
	sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$ZOOKEEPER_MON_FILE"
	sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$ZOOKEEPER_MON_FILE"

	echo "Enabling JVM monitoring on Zookeeper"

cat >$ZOOKEEPER_CONF_FILE <<EOL
#!/bin/sh
JVMFLAGS="\$JVMFLAGS -javaagent:${ZOOKEEPER_MON_JAR_FILE}=${ZOOKEEPER_MON_FILE}"

EOL
	chmod a+r "$ZOOKEEPER_CONF_FILE"
fi


echo "Downloading zookeeper filebeat prospector"
service filebeat stop
wget -q $REPOSITORY_URL/zookeeper/prospector-zookeeper.yml.txt -O /etc/monitoring/filebeat-config/prospector-zookeeper.yml
sed -i -- s#ZOOKEEPER_DIR#"$ZOOKEEPER_DIR"#g /etc/monitoring/filebeat-config/prospector-zookeeper.yml
service filebeat start


echo "Zookeeper monitoring configuration completed."

