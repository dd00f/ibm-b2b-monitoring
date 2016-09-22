#!/bin/sh
#install-cc-monitoring.sh

# to execute remotely : 
# wget -O - http://myrepository.com/monitoring/b2bimon/install-b2bi-monitoring.sh | bash -s (PATH_TO_B2BI)
# example
# wget -O - http://myrepository.com/monitoring/b2bimon/install-b2bi-monitoring.sh | bash -s /sv_team/SI/SI5020500


MONITORING_HOST_NAME=`hostname -s`
GRAFANA_SERVER=DISABLED
GRAFANA_PORT=DISABLED
REPOSITORY_URL=DISABLED

if [ -f /etc/monitoring/init.sh ]; then
    source /etc/monitoring/init.sh
fi

B2BI_DIR="$1"
B2BI_BIN_DIR="$B2BI_DIR"/bin
B2BI_MON_DIR="$B2BI_DIR"/monitoring

# ensure B2Bi is installed
if [ ! -f "$B2BI_BIN_DIR"/startContainer.sh ]; then
    echo Installation failed. The first parameter didnt match the root directory of B2Bi. Parameter value : "$1"
fi


if [ "$GRAFANA_SERVER" != "DISABLED" ];
then
	echo "Downloading Monitoring configuration files"

	mkdir "$B2BI_MON_DIR"
	chmod a+r "$B2BI_MON_DIR"

	wget -q "$REPOSITORY_URL"/b2bimon/jmxtrans-agent-1.0.10-SNAPSHOT.jar -O "$B2BI_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar
	wget -q "$REPOSITORY_URL"/b2bimon/jmxtrans-agent-activemq.xml -O "$B2BI_MON_DIR"/jmxtrans-agent-activemq.xml
	wget -q "$REPOSITORY_URL"/b2bimon/jmxtrans-agent-b2bi-container.xml -O "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-container.xml
	wget -q "$REPOSITORY_URL"/b2bimon/jmxtrans-agent-b2bi-listener.xml -O "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-listener.xml
	wget -q "$REPOSITORY_URL"/b2bimon/jmxtrans-agent-b2bi-noapp.xml -O "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-noapp.xml
	wget -q "$REPOSITORY_URL"/b2bimon/jmxtrans-agent-b2bi-ops.xml -O "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-ops.xml
	chmod a+r "$B2BI_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar
	chmod a+r "$B2BI_MON_DIR"/jmxtrans-agent-activemq.xml
	chmod a+r "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-container.xml
	chmod a+r "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-listener.xml
	chmod a+r "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-noapp.xml
	chmod a+r "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-ops.xml

	echo "Configuring the B2Bi JVM monitoring templates."

	sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$B2BI_MON_DIR"/jmxtrans-agent-activemq.xml
	sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$B2BI_MON_DIR"/jmxtrans-agent-activemq.xml
	sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$B2BI_MON_DIR"/jmxtrans-agent-activemq.xml

	sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-container.xml
	sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-container.xml
	sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-container.xml

	sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-listener.xml
	sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-listener.xml
	sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-listener.xml

	sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-noapp.xml
	sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-noapp.xml
	sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-noapp.xml

	sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-ops.xml
	sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-ops.xml
	sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$B2BI_MON_DIR"/jmxtrans-agent-b2bi-ops.xml


	echo "Creating a backup of the B2Bi startup script with the extension : .monitoring.backup"

	cp -n "$B2BI_BIN_DIR"/startContainer.sh "$B2BI_BIN_DIR"/startContainer.sh.monitoring.backup
	cp -n "$B2BI_BIN_DIR"/startListeners.sh "$B2BI_BIN_DIR"/startListeners.sh.monitoring.backup
	cp -n "$B2BI_BIN_DIR"/startActiveMQ.sh "$B2BI_BIN_DIR"/startActiveMQ.sh.monitoring.backup
	cp -n "$B2BI_DIR"/noapp/bin/startNoApp.sh "$B2BI_DIR"/noapp/bin/startNoApp.sh.monitoring.backup
	cp -n "$B2BI_DIR"/noapp/bin/startContainerNode.sh "$B2BI_DIR"/noapp/bin/startContainerNode.sh.monitoring.backup

	echo "Enabling JVM monitoring on B2Bi"

	JAVA_SYSTEM_VAR="-Dcom.ibm.logger.performanceLogger.enabled=true"
	JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.intervals=1m"
	JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.csvPrintIntervalName=1m"
	JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.PeriodicMetricPrintEnabled=true"
	JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.periodicMetricPrintClassName=com.ibm.logger.trace.CsvPerformanceLogsToFilePrinter"
	JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.periodicMetricPrintIntervalInMillisecond=60000"

	OPS_JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -javaagent:$B2BI_MON_DIR/jmxtrans-agent-1.0.10-SNAPSHOT.jar=$B2BI_MON_DIR/jmxtrans-agent-b2bi-ops.xml"
	OPS_JAVA_SYSTEM_VAR="$OPS_JAVA_SYSTEM_VAR -Dcom.ibm.logger.trace.CsvPerformanceLogsToFilePrinter.csvFileNamePattern=$B2BI_DIR/logs/performance-metrics-\%DATE_ISO_8601\%.csv"

	CONTAINER_JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -javaagent:$B2BI_MON_DIR/jmxtrans-agent-1.0.10-SNAPSHOT.jar=$B2BI_MON_DIR/jmxtrans-agent-b2bi-container.xml"
	CONTAINER_JAVA_SYSTEM_VAR="$CONTAINER_JAVA_SYSTEM_VAR -Dcom.ibm.logger.trace.CsvPerformanceLogsToFilePrinter.csvFileNamePattern=$B2BI_DIR/logs/node-performance-metrics-\%DATE_ISO_8601\%.csv"

	LISTENER_JAVA_SYSTEM_VAR="-javaagent:"$B2BI_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar=$B2BI_MON_DIR/jmxtrans-agent-b2bi-listener.xml"

	ACTIVE_MQ_JAVA_SYSTEM_VAR="-javaagent:"$B2BI_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar="$B2BI_MON_DIR"/jmxtrans-agent-activemq.xml"

	NO_APP_JAVA_SYSTEM_VAR="-javaagent:"$B2BI_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar="$B2BI_MON_DIR"/jmxtrans-agent-b2bi-noapp.xml"


	# echo sed -e "s#opsvendor.properties com#opsvendor.properties $OPS_JAVA_SYSTEM_VAR com#g"
	sed -e "s#opsvendor.properties com#opsvendor.properties $OPS_JAVA_SYSTEM_VAR com#g" "$B2BI_BIN_DIR"/startContainer.sh.monitoring.backup > "$B2BI_BIN_DIR"/startContainer.sh
	echo "Modified $B2BI_BIN_DIR/startContainer.sh"
	sed -e "s#java \$jvm#java $LISTENER_JAVA_SYSTEM_VAR \$jvm#g" "$B2BI_BIN_DIR"/startListeners.sh.monitoring.backup > "$B2BI_BIN_DIR"/startListeners.sh
	echo "Modified $B2BI_BIN_DIR/startListeners.sh"
	sed -e "s#servers.properties -Dactivemq#servers.properties $ACTIVE_MQ_JAVA_SYSTEM_VAR -Dactivemq#g" "$B2BI_BIN_DIR"/startActiveMQ.sh.monitoring.backup > "$B2BI_BIN_DIR"/startActiveMQ.sh
	echo "Modified $B2BI_BIN_DIR/startActiveMQ.sh"
	sed -e "s#servers.properties -classpath#servers.properties $NO_APP_JAVA_SYSTEM_VAR -classpath#g" "$B2BI_DIR"/noapp/bin/startNoApp.sh.monitoring.backup > "$B2BI_DIR"/noapp/bin/startNoApp.sh
	echo "Modified $B2BI_DIR/noapp/bin/startNoApp.sh"
	# echo sed -e "s#servers.properties -classpath#servers.properties $CONTAINER_JAVA_SYSTEM_VAR -classpath#g"
	sed -e "s#servers.properties -classpath#servers.properties $CONTAINER_JAVA_SYSTEM_VAR -classpath#g" "$B2BI_DIR"/noapp/bin/startContainerNode.sh.monitoring.backup > "$B2BI_DIR"/noapp/bin/startContainerNode.sh
	echo "Modified $B2BI_DIR/noapp/bin/startContainerNode.sh"
fi

echo "Downloading b2bi filebeat prospector"
service filebeat stop
wget -q $REPOSITORY_URL/b2bimon/prospector-b2bi.yml.txt -O /etc/monitoring/filebeat-config/prospector-b2bi.yml
sed -i -- s#B2BI_DIR#"$B2BI_DIR"#g /etc/monitoring/filebeat-config/prospector-b2bi.yml
service filebeat start


echo "B2Bi monitoring configuration completed."

