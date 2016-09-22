#!/bin/sh
#install-mq-monitoring.sh

# to execute remotely : 
# wget -O - http://jute.torolab.ibm.com/mcduffs/monitoring/mq/install-mq-monitoring.sh | bash -s -- (arguments to MQ monitor)
#
#    -b chl-tbl-name  Use the named client channel table
#    -c chl-name      Channel name for client connection
#    -e               Display extended data
#    -h               Display handles information accessing the queue
#    -i interval      Interval (seconds) at which to display statistics
#    -l               Use the MQCHLTAB/MQCHLLIB environment variables
#    -m qmgr-name     Name of the queue manager hosting the queue
#    -q q-name        Name of the local queue to display statistics for
#    -u ciph-suite    Cipher suite for SSL connection
#    -v               Use the MQSERVER environment variable
#    -x conn-name     Connection name as host(port) for client connection
#    -g user-name     User name for the MQSERVER client connection
#    -j password      Password for the MQSERVER client connection
#    -k address       Address of the Graphite server to receive metrics
#    -n port          Port of the Graphite server to receive metrics
#    -o server-name   Name of the server reported in the metric path
#
# example
# wget -O - http://jute.torolab.ibm.com/mcduffs/monitoring/mq/install-mq-monitoring.sh | bash -s -- -c SYSTEM.DEF.SVRCONN -m PEST -q gdha -i 20 -s -t -x "dubua001v04.dub.usoh.ibm.com(1524)" -g mqmpest -e -k gdhape01.canlab.ibm.com -n 2003 -o dubua001v04

hostname=`hostname -s`
MONITOR_DIR=/etc/monitoring
MQ_MONITOR_DIR=$MONITOR_DIR/mq

yum -y install unzip

service mqmonservice stop

REPOSITORY_URL=http://jute.torolab.ibm.com/mcduffs/monitoring

echo "Downloading Monitoring configuration files"

mkdir "$MONITOR_DIR"
chmod 777 "$MONITOR_DIR"
mkdir "$MQ_MONITOR_DIR"
chmod 777 "$MQ_MONITOR_DIR"

wget -q "$REPOSITORY_URL"/mq/mqmonitor.zip -O "$MQ_MONITOR_DIR"/mqmonitor.zip

wget -r "$REPOSITORY_URL"/mq/mqmonservice.sh -O /etc/rc.d/init.d/mqmonservice

unzip -o "$MQ_MONITOR_DIR"/mqmonitor.zip -d "$MQ_MONITOR_DIR"

wget -r "$REPOSITORY_URL"/mq/start-mq-monitoring.sh -O "$MQ_MONITOR_DIR"/start-mq-monitoring.sh
wget -r "$REPOSITORY_URL"/mq/mqmonitor.jar -O "$MQ_MONITOR_DIR"/lib/mqmonitor.jar

echo "Configuring the MQ monitoring templates."

ARGSREGEX="$*"
echo MQ monitoring arguments are : $ARGSREGEX

sed -i -- s#ARGS#"$ARGSREGEX"#g "$MQ_MONITOR_DIR"/start-mq-monitoring.sh

echo adding execute permission to monitoring script
chmod 777 /etc/rc.d/init.d/mqmonservice
chmod 777 "$MQ_MONITOR_DIR"/start-mq-monitoring.sh
chmod +x "$MQ_MONITOR_DIR"/start-mq-monitoring.sh
chmod +x /etc/rc.d/init.d/mqmonservice

ln -s /etc/rc.d/init.d/mqmonservice /etc/rc.d/rc5.d/S20mqmonservice

echo starting monitoring service
service mqmonservice start

echo "MQ monitoring configuration completed."

