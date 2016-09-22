#!/bin/sh
#

cp -f ../conf/enabled.javalogging.properties ../conf/javalogging.properties

sed -i -- 's#<logging.*#<logging traceFormat="ENHANCED" traceSpecification="*=info:com.ibm.tenx.*=fine:openjpa.jdbc.SQL=fine:com.ibm.service.*=fine"/>#' ../web/wlp/usr/servers/defaultServer/server.xml
