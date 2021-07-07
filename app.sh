#!/bin/bash

export LANG=en_US.UTF-8

if [ -z "$BASE" ] ; then
    BASE=/opt/canal-deployer
fi

bin_abs_path=$BASE/bin

cd $BASE

canal_conf=$BASE/conf/canal.properties
canal_local_conf=$BASE/conf/canal_local.properties
logback_configurationFile=$BASE/conf/logback.xml

CANAL_DESTINATIONS=$(perl -le 'print $ENV{"canal.destinations"}')
mv conf/example conf/${CANAL_DESTINATIONS:-cdc}

sed -i "s|canal.destinations = .*|canal.destinations = ${CANAL_DESTINATIONS:-cdc}|" $canal_conf
sed -i "s|canal.auto.scan = .*|canal.auto.scan = false|" $canal_conf
sed -i "s|canal.instance.global.spring.xml = .*|canal.instance.global.spring.xml = classpath:spring/default-instance.xml|" $canal_conf

## set java path
if [ -z "$JAVA" ] ; then
  JAVA=$(which java)
fi

case "$#"
in
0 )
	;;
1 )
	var=$*
	if [ "$var" = "local" ]; then
		canal_conf=$canal_local_conf
	else
		if [ -f $var ] ; then
			canal_conf=$var
		else
			echo "THE PARAMETER IS NOT CORRECT.PLEASE CHECK AGAIN."
			exit
		fi
	fi;;
2 )
	var=$1
	if [ "$var" = "local" ]; then
		canal_conf=$canal_local_conf
	else
		if [ -f $var ] ; then
			canal_conf=$var
		else
			if [ "$1" = "debug" ]; then
				DEBUG_PORT=$2
				DEBUG_SUSPEND="n"
				JAVA_DEBUG_OPT="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=$DEBUG_PORT,server=y,suspend=$DEBUG_SUSPEND"
			fi
		fi
     fi;;
* )
	echo "THE PARAMETERS MUST BE TWO OR LESS.PLEASE CHECK AGAIN."
	exit;;
esac

str=`file -L $JAVA | grep 64-bit`
if [ -n "$str" ]; then
	JAVA_OPTS="-server -Xms2048m -Xmx3072m -Xmn1024m -XX:SurvivorRatio=2 -XX:PermSize=96m -XX:MaxPermSize=256m -Xss256k -XX:-UseAdaptiveSizePolicy -XX:MaxTenuringThreshold=15 -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDumpOnOutOfMemoryError"
else
	JAVA_OPTS="-server -Xms1024m -Xmx1024m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:MaxPermSize=128m "
fi

JAVA_OPTS=" $JAVA_OPTS -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8"
CANAL_OPTS="-DappName=otter-canal -Dlogback.configurationFile=$logback_configurationFile -Dcanal.conf=$canal_conf"

if [ -e $canal_conf -a -e $logback_configurationFile ]
then

	for i in $BASE/lib/*;
		do CLASSPATH=$i:"$CLASSPATH";
	done
 	CLASSPATH="$BASE/conf:$CLASSPATH";

 	echo "cd to $bin_abs_path for workaround relative path"
  	cd $bin_abs_path

	echo LOG CONFIGURATION : $logback_configurationFile
	echo canal conf : $canal_conf
	echo CLASSPATH :$CLASSPATH
	$JAVA $JAVA_OPTS $JAVA_DEBUG_OPT $CANAL_OPTS -classpath .:$CLASSPATH com.alibaba.otter.canal.deployer.CanalLauncher
else
	echo "canal conf("$canal_conf") OR log configration file($logback_configurationFile) is not exist,please create then first!"
fi
