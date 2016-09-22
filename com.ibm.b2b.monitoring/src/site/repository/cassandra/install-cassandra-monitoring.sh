#!/bin/sh
#install-cc-monitoring.sh

# to execute remotely : 
# wget -O - http://myrepository.com/monitoring/cassandra/install-cassandra-monitoring.sh | bash -s (PATH_TO_CASSANDRA)
# Note that PATH_TO_CASSANDRA is set to "/etc/cassandra" by default
# example
# wget -O - http://myrepository.com/monitoring/cassandra/install-cassandra-monitoring.sh | bash -s /etc/cassandra
# wget -O - http://myrepository.com/monitoring/cassandra/install-cassandra-monitoring.sh | bash

MONITORING_HOST_NAME=`hostname -s`
GRAFANA_SERVER=DISABLED
GRAFANA_PORT=DISABLED
REPOSITORY_URL=DISABLED


if [ -f /etc/monitoring/init.sh ]; then
	echo "Loading /etc/monitoring/init.sh"
    source /etc/monitoring/init.sh
fi

if [ -z ${1+x} ]; 
then 
	echo "Parameter 1 is unset, set CASSANDRA_DIR to default"; 
	CASSANDRA_DIR="/etc/cassandra"
else 
	echo "Parameter 1 is set to '$1', assigned to CASSANDRA_DIR"; 
	CASSANDRA_DIR="$1"
fi

CASSANDRA_CONF_DIR="$CASSANDRA_DIR"/conf
CASSANDRA_CONF_FILE="$CASSANDRA_CONF_DIR"/cassandra-env.sh
CASSANDRA_CONF_BACKUP_FILE="$CASSANDRA_CONF_FILE".monitoring.backup
CASSANDRA_MON_DIR="$CASSANDRA_CONF_DIR"/monitoring
CASSANDRA_MON_FILE="$CASSANDRA_MON_DIR"/jmxtrans-agent-Cassandra.xml
CASSANDRA_MON_JAR_FILE="$CASSANDRA_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar


# ensure Cassandra is installed
if [ ! -f "$CASSANDRA_CONF_FILE" ]; then
    echo "Installation failed. Unable to find file '$CASSANDRA_CONF_FILE'"
fi

if [ "$GRAFANA_SERVER" != "DISABLED" ];
then
	echo "Downloading Monitoring configuration files to '$CASSANDRA_MON_DIR'"

	mkdir "$CASSANDRA_MON_DIR"

	wget -q "$REPOSITORY_URL"/cassandra/jmxtrans-agent-1.0.10-SNAPSHOT.jar -O "$CASSANDRA_MON_JAR_FILE"
	wget -q "$REPOSITORY_URL"/cassandra/jmxtrans-agent-Cassandra.xml -O "$CASSANDRA_MON_FILE"
	chmod a+rw "$CASSANDRA_MON_JAR_FILE"
	chmod a+rw "$CASSANDRA_MON_FILE"

	echo "Configuring the Cassandra JVM monitoring templates."

	sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$CASSANDRA_MON_FILE"
	sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$CASSANDRA_MON_FILE"
	sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$CASSANDRA_MON_FILE"

	echo "Creating a backup of the Cassandra startup script : '$CASSANDRA_CONF_BACKUP_FILE'"

	cp -n "$CASSANDRA_CONF_FILE" "$CASSANDRA_CONF_BACKUP_FILE"

	echo "Enabling JVM monitoring on Cassandra"

	sed -e "/JVM_OPTS -Xmn.*$/a JVM_OPTS=\"\$JVM_OPTS -javaagent:$CASSANDRA_MON_JAR_FILE=$CASSANDRA_MON_FILE\"" "$CASSANDRA_CONF_BACKUP_FILE" > "$CASSANDRA_CONF_FILE"
fi


echo "Downloading cassandra filebeat prospector"
service filebeat stop
wget -q $REPOSITORY_URL/cassandra/prospector-cassandra.yml.txt -O /etc/monitoring/filebeat-config/prospector-cassandra.yml
sed -i -- s#CASSANDRA_DIR#"$CASSANDRA_DIR"#g /etc/monitoring/filebeat-config/prospector-cassandra.yml
service filebeat start


echo "Cassandra monitoring configuration completed."

