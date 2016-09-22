#!/bin/sh
#install-gm-monitoring.sh

# to execute remotely : 
# wget -O - http://myserver.com/monitoring/gm/install-gm-monitoring.sh | bash -s (PATH_TO_GM_LIBERTY)
# example
# wget -O - http://myserver.com/monitoring/gm/install-gm-monitoring.sh | bash -s /home/user/IBM/SterlingIntegrator/wlp


MONITORING_HOST_NAME=`hostname -s`
GRAFANA_SERVER=DISABLED
GRAFANA_PORT=DISABLED
REPOSITORY_URL=DISABLED

if [ -f /etc/monitoring/init.sh ]; then
    source /etc/monitoring/init.sh
fi

GM_DIR="$1"
GM_BIN_DIR="$GM_DIR"/bin
GM_SERVER_DIR="$GM_DIR"/usr/servers/mailboxui
GM_MON_DIR="$GM_SERVER_DIR"/monitoring

# ensure GM is installed
if [ ! -f "$GM_BIN_DIR"/server ]; then
    echo Installation failed. The first parameter didnt match the wlp directory of Global Mailbox. Parameter value : "$1". File not found : "$GM_BIN_DIR"/server
fi

if [ "$GRAFANA_SERVER" != "DISABLED" ];
then
	echo "Downloading Monitoring configuration files"

	mkdir "$GM_MON_DIR"

	wget -q "$REPOSITORY_URL"/gm/jmxtrans-agent-1.0.10-SNAPSHOT.jar -O "$GM_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar
	chmod a+r "$GM_MON_DIR"/jmxtrans-agent-1.0.10-SNAPSHOT.jar

	wget -q "$REPOSITORY_URL"/gm/jmxtrans-agent-gmliberty.xml -O "$GM_MON_DIR"/jmxtrans-agent-gmliberty.xml
	chmod a+r "$GM_MON_DIR"/jmxtrans-agent-gmliberty.xml

	wget -q "$REPOSITORY_URL"/gm/jvm.options.txt -O "$GM_SERVER_DIR"/jvm.options
	chmod a+r "$GM_SERVER_DIR"/jvm.options

	echo "Configuring the GM Liberty JVM monitoring templates."

	sed -i -- s#????#"$MONITORING_HOST_NAME"#g "$GM_MON_DIR"/jmxtrans-agent-gmliberty.xml
	sed -i -- s#GRAFANA_SERVER_NAME#"$GRAFANA_SERVER"#g "$GM_MON_DIR"/jmxtrans-agent-gmliberty.xml
	sed -i -- s#GRAFANA_SERVER_PORT#"$GRAFANA_PORT"#g "$GM_MON_DIR"/jmxtrans-agent-gmliberty.xml
fi

echo "Downloading global mailbox filebeat prospector"
service filebeat stop
wget -q $REPOSITORY_URL/gm/prospector-gm.yml.txt -O /etc/monitoring/filebeat-config/prospector-gm.yml
sed -i -- s#GM_DIR#"$GM_DIR"#g /etc/monitoring/filebeat-config/prospector-gm.yml
service filebeat start

echo "GM Liberty monitoring configuration completed."

