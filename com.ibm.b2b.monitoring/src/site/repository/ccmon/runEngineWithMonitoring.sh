#!/bin/sh
#

cd .
. ./setEnv.sh
# cd ../conf

if [ "X$JAVA_HOME" = "X" ]; then 
 echo "ERROR: JAVA_HOME not found in your environment."
 echo "Please, set the JAVA_HOME variable in your environment to match the"
 echo "location of the Java Virtual Machine you want to use."
 exit -1
fi 

# Backup nohup files
${JAVA_HOME}/bin/java  -Xbootclasspath/p:$BOOT_CP -Xms128m -Xmx256m -DCONFIG_DIR=../conf -jar ../lib/sterling/SCCenter.jar com.sterlingcommerce.scc.common.util.NohupManager


JAVA_HEAP="-Xms256m -Xmx4096m"
JAVA_XX_OPT="-XX:+UseParallelGC  -XX:+HeapDumpOnOutOfMemoryError"

JAVA_SYSTEM_VAR="-Dopenjpa.DynamicEnhancementAgent=false -Djava.util.Arrays.useLegacyMergeSort=true -Dfile.encoding=UTF-8 "
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Djava.util.logging.config.file=../conf/javalogging.properties "
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dlog4j.defaultInitOverride=true  -Dlog4j.configuration=file:../conf/Engine.log4j"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -DBrowserAgent=true -DSI_OPT=true  -DCONFIG_DIR=../conf "
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -DADD_ACTIVE_ALERTS_TO_DB_USING_OPENJPA=true"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.csvPrintIntervalName=1m"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.PeriodicMetricPrintEnabled=true"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.periodicMetricPrintClassName=com.ibm.logger.trace.CsvPerformanceLogsToFilePrinter"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.trace.CsvPerformanceLogsToFilePrinter.csvFileNamePattern=../log/performance-metrics-%DATE_ISO_8601%.csv"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.periodicMetricPrintIntervalInMillisecond=60000"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.intervals=1m"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.ibm.logger.performanceLogger.enabled=true"
JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -javaagent:jmxtrans-agent-1.0.10-SNAPSHOT.jar=jmxtrans-agent.xml"

# uncomment to enable JMX remote access
# JAVA_SYSTEM_VAR="$JAVA_SYSTEM_VAR -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"


LAUNCH_CMD="-jar ../lib/sterling/SCCenter.jar  com.sterlingcommerce.scc.agent.SCCAgent"


nohup ${JAVA_HOME}/bin/java  -server -Xbootclasspath/p:$BOOT_CP:$XERCES_IMPL_JAR ${JAVA_XX_OPT}  ${JAVA_HEAP} ${JAVA_SYSTEM_VAR} ${LAUNCH_CMD} >> nohup.out &

# cd ../bin
