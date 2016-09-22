#!/bin/sh
# db2 DB2 10.5 statistics
hostname=`hostname -s`

db2 connect to $1 > /dev/null 2>/dev/null

while :
do

	for column in $(cat ./db2-mon-columns.txt)
	do 
		db2 -x "select MEMBER,"$column" FROM TABLE (MON_GET_DATABASE(-2))"|gawk -v host=$hostname -v column=$column -v database=$1\
			'{currenttime=systime();\
			print "server."host".db."database".member."$1"."column,$2,currenttime;}'
	done

	for table in $(cat ./table-to-monitor.txt)
	do 
		db2 -x "select count(*) from "$table" with ur" | gawk -v database=$1 -v host=$hostname -v table=$table '{print "server."host".db."database".table."table,$1,systime()}'
	done

	sleep 4
done

