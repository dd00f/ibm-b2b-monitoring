#!/bin/sh
#graphite_nmon.sh

source /etc/monitoring/init.sh

hostname=`hostname -s`

if [ -z ${NMON_LOOP_DELAY+x} ]; then sleep=7; else sleep=$NMON_LOOP_DELAY; fi
if [ -z ${NMON_LOOP_COUNT+x} ]; then count=14400; else count=$NMON_LOOP_COUNT; fi
if [ -z ${GRAFANA_SERVER+x} ]; then server=gdhape01.canlab.ibm.com; else server=$GRAFANA_SERVER; fi
if [ -z ${GRAFANA_PORT+x} ]; then serverport=2003; else serverport=$GRAFANA_PORT; fi
if [ -z ${MONITORING_HOST_NAME+x} ]; then hostname=$hostname; else hostname=$MONITORING_HOST_NAME; fi


#echo count : $count
#echo sleep : $sleep
#echo server : $server
#echo serverport : $serverport

nmonfilename=/etc/monitoring/nmon/$hostname.nmon
pkill -x nmon
osversionfile=/etc/redhat-release

hash nmon 2>/dev/null || { echo >&2 "I require nmon but it's not installed.  Aborting."; exit 1; }
hash nc 2>/dev/null || { echo >&2 "I require nc (netcat) but it's not installed.  Aborting."; exit 1; }

seconds="-w 180s"

if grep -q ' 7\.' "$osversionfile"
then
   # echo Red Hat 7 detected
   seconds="-w 180s"
else
   # echo Not Red Hat 7
   seconds="-w 180"
fi

sleep 1

while true
do
	rm -rf $nmonfilename
	nmon_pid=`nmon -F $nmonfilename -t -s $sleep -c $count -p`
	echo $nmon_pid>/etc/monitoring/nmon/nmon.pid
	sleep 1
	tail -f $nmonfilename --pid=$nmon_pid | gawk -F, -v hostname=$hostname -f /etc/monitoring/nmon/nmon.gawk.sh | nc $seconds $server $serverport
	sleep 1
    if ps --pid $nmon_pid &>/dev/null
    then
       kill $nmon_pid
    fi
	rm /etc/monitoring/nmon/nmon.pid
done

