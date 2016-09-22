#!/bin/bash

case "$1" in 
start)
   /etc/monitoring/nmon/graphite_nmon.sh &
   echo $!>/var/run/graphite_nmon.pid
   ;;
stop)
   kill `cat /var/run/graphite_nmon.pid`
   kill `cat /etc/monitoring/nmon/nmon.pid`
   rm /etc/monitoring/nmon/nmon.pid
   rm /var/run/graphite_nmon.pid
   ;;
restart)
   $0 stop
   $0 start
   ;;
status)
   NMONPID=`cat /var/run/graphite_nmon.pid`
   if ps --pid $NMONPID &>/dev/null
   then
      echo graphite_nmon.sh is running, pid=`cat /var/run/graphite_nmon.pid`
   else
      echo graphite_nmon.sh is NOT running
      exit 1
   fi
   ;;
*)
   echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0 