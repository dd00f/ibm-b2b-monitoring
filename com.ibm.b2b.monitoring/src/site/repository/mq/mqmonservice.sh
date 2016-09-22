#!/bin/bash

case "$1" in 
start)
   /etc/monitoring/mq/start-mq-monitoring.sh &
   echo $!>/var/run/mq-monitoring.pid
   ;;
stop)
   kill `cat /var/run/mq-monitoring.pid`
   rm /var/run/mq-monitoring.pid
   ;;
restart)
   $0 stop
   $0 start
   ;;
status)
   if [ -e /var/run/mq-monitoring.pid ]; then
      echo start-mq-monitoring.sh is running, pid=`cat /var/run/mq-monitoring.pid`
   else
      echo start-mq-monitoring.sh is NOT running
      exit 1
   fi
   ;;
*)
   echo "Usage: $0 {start|stop|status|restart}"
esac

exit 0 