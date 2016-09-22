@echo off

rem C:
cd .

call setEnv.bat
REM cd ..\conf
rem echo  %JAVA_HOME%

if "%JAVA_HOME%" == "" goto java_error

:run
set DEBUG_OPTS=
if "%1" == "debug" set DEBUG_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000 


SET JAVA_HEAP=-Xms256m -Xmx4096m -XX:PermSize=256m -XX:MaxPermSize=512m
SET JAVA_XX_OPT=-XX:+UseParallelGC  -XX:+HeapDumpOnOutOfMemoryError 

SET JAVA_SYSTEM_VAR=-Dopenjpa.DynamicEnhancementAgent=false -Djava.util.Arrays.useLegacyMergeSort=true -Dfile.encoding=UTF-8  
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Djava.util.logging.config.file=../conf/javalogging.properties 
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Dlog4j.defaultInitOverride=true  -Dlog4j.configuration=file:../conf/Engine.log4j
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -DBrowserAgent=true -DSI_OPT=true  -DCONFIG_DIR=../conf
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -DADD_ACTIVE_ALERTS_TO_DB_USING_OPENJPA=true  -DLAUNCH_MODE=console
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Dcom.ibm.logger.performanceLogger.csvPrintIntervalName=1m
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Dcom.ibm.logger.performanceLogger.PeriodicMetricPrintEnabled=true
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Dcom.ibm.logger.performanceLogger.periodicMetricPrintClassName=com.ibm.logger.trace.CsvPerformanceLogsToFilePrinter
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Dcom.ibm.logger.trace.CsvPerformanceLogsToFilePrinter.csvFileNamePattern=../log/performance-metrics-%%DATE_ISO_8601%%.csv
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Dcom.ibm.logger.performanceLogger.periodicMetricPrintIntervalInMillisecond=60000
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Dcom.ibm.logger.performanceLogger.intervals=1m
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -Dcom.ibm.logger.performanceLogger.enabled=true
SET JAVA_SYSTEM_VAR=%JAVA_SYSTEM_VAR% -javaagent:jmxtrans-agent-1.0.10-SNAPSHOT.jar=jmxtrans-agent.xml


SET LAUNCH_CMD=-jar ../lib/sterling/SCCenter.jar  com.sterlingcommerce.scc.agent.SCCAgent 

%JAVA_HOME%\bin\java  -server  -Xbootclasspath/p:%BOOT_CP%;  %JAVA_XX_OPT% %JAVA_HEAP% %DEBUG_OPTS%  %JAVA_SYSTEM_VAR%  %LAUNCH_CMD%


goto end

:java_error
 echo "ERROR: JAVA_HOME not found in your environment."
 echo "Please, set the JAVA_HOME variable in your environment to match the"
 echo "location of the Java Virtual Machine you want to use."
 goto end


:end
