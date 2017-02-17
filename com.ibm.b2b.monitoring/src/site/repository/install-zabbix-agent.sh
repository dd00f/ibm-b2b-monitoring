#!/bin/sh
#install-monitoring.sh
# wget -O - http://jute.torolab.ibm.com/mcduffs/monitoring/install-zabbix-agent.sh | bash -s -- pestvm053c.dub.usoh.ibm.com http://jute.torolab.ibm.com/mcduffs/monitoring

if [ -z ${1+x} ]; then { echo "No zabbix host specified in parameter 1."; exit 1; }; else zabbixhost=$1; fi
if [ -z ${2+x} ]; then { echo "No repository URL specified in parameter 2, installation failed."; exit 1; }; else repositoryurl=$2; fi

if [ -b "/etc/redhat-release" ]
then
	rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
	yum -y install zabbix-agent
	wget -r $repositoryurl/zabbix_agent.pp.txt -O /etc/zabbix/zabbix_agent.pp
else
	wget http://repo.zabbix.com/zabbix/3.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.2-1+xenial_all.deb
	# wget http://repo.zabbix.com/zabbix/3.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.0-1+xenial_all.deb
	# sudo dpkg -i zabbix-release_3.0-1+xenial_all.deb
	sudo dpkg -i zabbix-release_3.2-1+xenial_all.deb
	sudo apt update
	sudo apt-get -y install zabbix-agent
fi


wget -r $repositoryurl/zabbix_agentd.txt -O /etc/zabbix/zabbix_agentd.conf
# wget -r http://jute.torolab.ibm.com/mcduffs/monitoring/zabbix_agentd.txt -O /etc/zabbix/zabbix_agentd.conf

sed -i -- s#ZABBIX_SERVER#"$zabbixhost"#g "/etc/zabbix/zabbix_agentd.conf"
# sed -i -- s#ZABBIX_SERVER#"pestvm053b.dub.usoh.ibm.com"#g "/etc/zabbix/zabbix_agentd.conf"

chmod a+r /etc/zabbix/zabbix_agentd.conf

if [ -b "/etc/redhat-release" ]
then
	semodule -i /etc/zabbix/zabbix_agent.pp
	systemctl restart zabbix-agent
	systemctl enable zabbix-agent
else
	/etc/init.d/zabbix-agent restart
fi

echo installation successful

