#!/bin/sh
#install-monitoring.sh

if [ -z ${1+x} ]; then grafanaserver=DISABLED; else grafanaserver=$1; fi
if [ -z ${2+x} ]; then grafanaserverport=DISABLED; else grafanaserverport=$2; fi
if [ -z ${3+x} ]; then logstashserver=DISABLED; else logstashserver=$3; fi
if [ -z ${4+x} ]; then logstashserverport=DISABLED; else logstashserverport=$4; fi
if [ -z ${5+x} ]; then { echo "No repository URL specified, installation failed."; exit 1; }; else repositoryurl=$5; fi
if [ -z ${6+x} ]; then nmonloopdelay=7; else nmonloopdelay=$6; fi
if [ -z ${7+x} ]; then nmonloopcount=1440; else nmonloopcount=$7; fi
if [ -z ${8+x} ]; then installtopbeat=true; else installtopbeat=$8; fi

echo nmonloopdelay $nmonloopdelay

monitoringfolder=/etc/monitoring
nmonmonitoringfolder=$monitoringfolder/nmon
hostname=`hostname -s`

echo making monitoring dir
mkdir -p $monitoringfolder
mkdir -p $nmonmonitoringfolder
cd $monitoringfolder

echo "export GRAFANA_SERVER=$grafanaserver
export GRAFANA_PORT=$grafanaserverport
export LOGSTASH_SERVER=$logstashserver
export LOGSTASH_PORT=$logstashserverport
export NMON_LOOP_DELAY=$nmonloopdelay
export NMON_LOOP_COUNT=$nmonloopcount
export MONITORING_HOST_NAME=$hostname
export REPOSITORY_URL=$repositoryurl
" > $monitoringfolder/init.sh
chmod a+rx $monitoringfolder/init.sh


if [ "$grafanaserver" != "DISABLED" ];
then

	echo updating nss to make the epel repository work
	yum -y --disablerepo="epel" update nss 
	echo installing netcat nc
	yum -y install nc
	type nc > temp.txt
	if grep -q not "temp.txt"
	then
		echo failed to install netcat
		exit 1
	else
		echo netcat installation successful
	fi

	osversionfile=/etc/redhat-release


	if grep -q ' 7\.2' "$osversionfile"
		then
		echo Red Hat 7.2 detected, download of nmon required.
		wget "http://downloads.sourceforge.net/project/nmon/nmon16e_x86_rhel72?r=http%3A%2F%2Fnmon.sourceforge.net%2Fpmwiki.php%3Fn%3DSite.Download&ts=1467990407&use_mirror=tenet" -O $nmonmonitoringfolder/nmon16e_x86_rhel72
		chmod +x $nmonmonitoringfolder/nmon16e_x86_rhel72
		ln $nmonmonitoringfolder/nmon16e_x86_rhel72 /usr/bin/nmon
	elif grep -q ' 7\.' "$osversionfile"
		then
		echo Red Hat 7 detected, getting corresponding epel repository
		wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -O $nmonmonitoringfolder/epel-release-latest-7.noarch.rpm
		rpm -Uhv $nmonmonitoringfolder/epel-release-latest-7.noarch.rpm
	elif grep -q ' 6\.' "$osversionfile"
		then
		echo Red Hat 6 detected, getting corresponding epel repository
		wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm -O $nmonmonitoringfolder/epel-release-latest-6.noarch.rpm
		rpm -Uhv $nmonmonitoringfolder/epel-release-latest-6.noarch.rpm	   
	else
		echo Not Red Hat 7 or 6, unsupported OS detected.
		exit 1
	fi


	echo installing nmon
	yum -y install nmon
	type nmon > temp.txt
	if grep -q not "temp.txt"
	then
		echo failed to install nmon
		exit 1
	else
		echo netcat installation successful	
	fi

	echo stopping previous monitoring process
	service graphitenmonservice stop
	pkill -f graphite_nmon.sh
	sleep 1

	echo downloading required monitoring script
	wget -r $repositoryurl/nmon.gawk.sh -O $nmonmonitoringfolder/nmon.gawk.sh
	wget -r $repositoryurl/graphite_nmon.sh -O $nmonmonitoringfolder/graphite_nmon.sh
	wget -r $repositoryurl/graphitenmonservice.sh -O /etc/rc.d/init.d/graphitenmonservice

	echo adding execute permission to monitoring script
	chmod a+x $nmonmonitoringfolder/graphite_nmon.sh
	chmod a+x /etc/rc.d/init.d/graphitenmonservice

	ln -s /etc/rc.d/init.d/graphitenmonservice /etc/rc.d/rc5.d/S20graphitenmonservice

	echo starting monitoring service
	service graphitenmonservice start

fi

echo installing filebeat

systemctl stop filebeat

filebeat_config_file=/etc/filebeat/filebeat.yml
mkdir /etc/systemd/system/filebeat.d
wget -r $repositoryurl/override.conf.txt -O /etc/systemd/system/filebeat.d/override.conf.txt
wget -r https://download.elastic.co/beats/filebeat/filebeat-5.0.0-alpha5-x86_64.rpm -O $monitoringfolder/filebeat-5.0.0-alpha5-x86_64.rpm
sudo rpm -e filebeat
sudo rpm -vi $monitoringfolder/filebeat-5.0.0-alpha5-x86_64.rpm
echo get filebeat config
echo wget -r $repositoryurl/filebeat.yml.txt -O $filebeat_config_file
wget -r $repositoryurl/filebeat.yml.txt -O $filebeat_config_file
mkdir $monitoringfolder/filebeat-config
chmod a+rw $monitoringfolder/filebeat-config
echo update filebeat config
sed -i -- s#LOGSTASH_SERVER#"$logstashserver"#g "$filebeat_config_file"
sed -i -- s#LOGSTASH_PORT#"$logstashserverport"#g "$filebeat_config_file"
echo start filebeat service

wget -q $repositoryurl/prospector-topbeat.txt -O /etc/monitoring/filebeat-config/prospector-topbeat.yml
wget -q $repositoryurl/prospector-filebeat.txt -O /etc/monitoring/filebeat-config/prospector-filebeat.yml
wget -q $repositoryurl/prospector-linux.txt -O /etc/monitoring/filebeat-config/prospector-linux.yml
wget -q $repositoryurl/prospector-zabbix-agent.txt -O /etc/monitoring/filebeat-config/prospector-zabbix-agent.yml

systemctl start filebeat
systemctl enable filebeat


if [ "$installtopbeat" = "true" ];
then
	echo installing topbeat
	topbeat_config_file=/etc/topbeat/topbeat.yml
	
	systemctl stop topbeat
	
	wget -r https://download.elastic.co/beats/topbeat/topbeat-1.2.3-x86_64.rpm -O $monitoringfolder/topbeat-1.2.3-x86_64.rpm
	sudo rpm -e topbeat
	sudo rpm -vi $monitoringfolder/topbeat-1.2.3-x86_64.rpm

	wget -r $repositoryurl/topbeat.yml.txt -O $topbeat_config_file
	chmod a+rw $topbeat_config_file

	sed -i -- s#LOGSTASH_SERVER#"$logstashserver"#g "$topbeat_config_file"
	sed -i -- s#LOGSTASH_PORT#"$logstashserverport"#g "$topbeat_config_file"

	systemctl start topbeat
	systemctl enable topbeat
	
else
	echo Skipping topbeat installation.
fi

if [ "$grafanaserver" != "DISABLED" ];
then
	hash nmon 2>/dev/null || { echo >&2 "NMON Installation failed.  Aborting."; exit 1; }
fi

echo installation successful

