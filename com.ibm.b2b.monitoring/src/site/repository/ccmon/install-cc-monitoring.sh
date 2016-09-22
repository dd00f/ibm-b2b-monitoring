#!/bin/sh
#install-cc-monitoring.sh


MONITORING_HOST_NAME=`hostname -s`
GRAFANA_SERVER=DISABLED
GRAFANA_PORT=DISABLED
REPOSITORY_URL=DISABLED

if [ -f /etc/monitoring/init.sh ]; then
    source /etc/monitoring/init.sh
fi

CC_DIR="$1"
CC_BIN_DIR="$CC_DIR"/bin
CC_CONF_DIR="$CC_DIR"/conf
CC_DEFAULT_SERVER_DIR="$CC_DIR"/web/wlp/usr/servers/defaultServer
CC_SERVER_BIN_DIR="$CC_DIR"/web/wlp/bin

# take a backup of the JVM options
if [ ! -f "$CC_DEFAULT_SERVER_DIR"/jvm.options ]; then
    echo Installation failed. The first parameter didnt match the root directory of control center. Parameter value : "$1"
fi

echo "Downloading performance logs enablement scripts"

wget -q $REPOSITORY_URL/ccmon/disabled.javalogging.properties.txt -O "$CC_CONF_DIR"/disabled.javalogging.properties
wget -q $REPOSITORY_URL/ccmon/enabled.javalogging.properties.txt -O "$CC_CONF_DIR"/enabled.javalogging.properties
wget -q $REPOSITORY_URL/ccmon/enablePerformanceLogs.sh -O "$CC_BIN_DIR"/enablePerformanceLogs.sh
wget -q $REPOSITORY_URL/ccmon/disablePerformanceLogs.sh -O "$CC_BIN_DIR"/disablePerformanceLogs.sh
wget -q $REPOSITORY_URL/ccmon/report.sh -O "$CC_BIN_DIR"/report.sh
chmod a+wr "$CC_CONF_DIR"/disabled.javalogging.properties
chmod a+wr "$CC_CONF_DIR"/enabled.javalogging.properties
chmod a+wrx "$CC_BIN_DIR"/enablePerformanceLogs.sh
chmod a+wrx "$CC_BIN_DIR"/disablePerformanceLogs.sh
chmod a+wrx "$CC_BIN_DIR"/report.sh

wget -q $REPOSITORY_URL/performance.zip -O "$CC_DIR"/performance.zip
unzip -o "$CC_DIR"/performance.zip -d "$CC_DIR"
# wget -q $REPOSITORY_URL/ccmon/generatePerformanceReportProduction.sh -O "$CC_DIR"/performance/bin/generatePerformanceReportProduction.sh
chmod -R 777 "$CC_DIR"/performance
chmod a+wrx "$CC_DIR"/performance/bin/report.sh

echo "Download of performance logs enablement scripts complete"


echo "Hooking the CC engine to the GRAFANA dashboard"

wget -q $REPOSITORY_URL/ccmon/jmxtrans-agent.xml -O "$CC_BIN_DIR"/jmxtrans-agent.xml
wget -q $REPOSITORY_URL/ccmon/jmxtrans-agent-1.0.10-SNAPSHOT.jar -O "$CC_BIN_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar
wget -q $REPOSITORY_URL/ccmon/runEngineWithMonitoring.sh -O "$CC_BIN_DIR"/runEngineWithMonitoring.sh
chmod a+wr "$CC_BIN_DIR"/jmxtrans-agent.xml
chmod a+wr "$CC_BIN_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar
chmod a+wrx "$CC_BIN_DIR"/runEngineWithMonitoring.sh
sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$CC_BIN_DIR"/jmxtrans-agent.xml
sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$CC_BIN_DIR"/jmxtrans-agent.xml
sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$CC_BIN_DIR"/jmxtrans-agent.xml

echo "Hooking the CC engine to the GRAFANA dashboard successful"


echo "Hooking the CC web client to the GRAFANA dashboard"

# take a backup of the JVM options
if [ ! -f "$CC_DEFAULT_SERVER_DIR"/jvm.options.bak ]; then
    cp "$CC_DEFAULT_SERVER_DIR"/jvm.options "$CC_DEFAULT_SERVER_DIR"/jvm.options.bak
fi

wget -q $REPOSITORY_URL/ccmon/jvm.txt -O "$CC_DEFAULT_SERVER_DIR"/jvm.options
chmod a+wr "$CC_DEFAULT_SERVER_DIR"/jvm.options
sed -i -- s#????#"$CC_SERVER_BIN_DIR"#g "$CC_DEFAULT_SERVER_DIR"/jvm.options

wget -q $REPOSITORY_URL/ccmon/jmxtrans-agent-1.0.10-SNAPSHOT.jar -O "$CC_SERVER_BIN_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar
chmod a+wr "$CC_SERVER_BIN_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar

wget -q $REPOSITORY_URL/ccmon/liberty-jmxtrans-agent.xml -O "$CC_SERVER_BIN_DIR"/liberty-jmxtrans-agent.xml
chmod a+wr "$CC_SERVER_BIN_DIR"/liberty-jmxtrans-agent.xml
sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$CC_SERVER_BIN_DIR"/liberty-jmxtrans-agent.xml
sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$CC_SERVER_BIN_DIR"/liberty-jmxtrans-agent.xml
sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$CC_SERVER_BIN_DIR"/liberty-jmxtrans-agent.xml

wget -O - $REPOSITORY_URL/ccmon/install-cc-log-monitoring.sh | bash -s $CC_DIR

echo "Hooking the CC web client to the GRAFANA dashboard successful"


