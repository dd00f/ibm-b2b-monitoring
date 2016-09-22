if [ -z ${1+x} ]; then logstashserver=gdhape01.canlab.ibm.com; else logstashserver=$1; fi
if [ -z ${2+x} ]; then logstashserverport=2003; else logstashserverport=$2; fi
if [ -z ${3+x} ]; then { echo "No repository URL specified, installation failed."; exit 1; }; else repositoryurl=$3; fi
if [ -z ${4+x} ]; then installtopbeat=true else installtopbeat=$4; fi

wget -O - $repositoryurl/ccmon/install-monitoring.sh | bash -s DISABLED DISABLED $logstashserver $logstashserverport $repositoryurl $installtopbeat

