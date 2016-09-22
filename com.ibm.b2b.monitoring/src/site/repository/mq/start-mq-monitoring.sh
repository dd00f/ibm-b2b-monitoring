#!/bin/sh
#start-mq-monitoring.sh


#GRAPHANA_SERVER_NAME=gdhape01.torolab.ibm.com
#GRAPHANA_SERVER_PORT=2003

# MQ_MONITOR_ARGUMENTS=-c SYSTEM.DEF.SVRCONN -m PEST -q gdha -i 20 -s -t -x "dubua001v04.dub.usoh.ibm.com(1524)" -g mqmpest -e -k gdhape01.canlab.ibm.com -n 2003 -o dubua001v04
MQ_MONITOR_ARGUMENTS="ARGS"

java -cp "/etc/monitoring/mq/lib/*" com.ibm.monitoring.mq.Xmqqstat $MQ_MONITOR_ARGUMENTS 
