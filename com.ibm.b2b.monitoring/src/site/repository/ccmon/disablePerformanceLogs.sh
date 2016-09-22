#!/bin/sh
#

cp -f ../conf/disabled.javalogging.properties ../conf/javalogging.properties

sed -i -- 's#<logging.*#<logging traceFormat="ENHANCED" traceSpecification="*=info:com.ibm.tenx.*=fine:openjpa.jdbc.SQL=fine:com.ibm.service.*=info"/>#' ../web/wlp/usr/servers/defaultServer/server.xml
