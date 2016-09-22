#!/bin/sh
# daily nmon.sh <seconds interval> <graphite-host>

#how many seconds between nmon captures
seconds=$1
#how many nmon captures until midnight
count=$((($(date -d "tomorrow 00:00" +%s)-$(date +%s))/${seconds}))

#stop any existing nmon processes according to nmon.pid
cd /nmon
if [ -f nmon.pid ]
then
	kill -0 $(<nmon.pid) >/dev/null 2>&1
	if [ "$?" -eq "0" ]
	then
		kill $(<nmon.pid) >/dev/null 2>&1
	fi
fi

#Remove nmon files older than 30 days
find ./*.nmon -mtime +30 -exec rm {} \; >/dev/null 2>&1

#Setup nmon run for the day
today=`date +%Y%m%d`
hostname=`hostname -s`
nmon -F $hostname.$today.nmon -t -s $seconds -c $count -p > nmon.pid
sleep 2
tail -F $hostname.$today.nmon --pid=$(<nmon.pid) | gawk -F, -v hostname=$hostname -f nmon.gawk | nc -w $seconds $2 2003
