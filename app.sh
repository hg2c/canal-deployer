#!/bin/bash

export LANG=en_US.UTF-8

BASE=/opt/canal-deployer

CDC_MASTER_CANAL=${CDC_MASTER_CANAL:-127.0.0.1:11111}
CDC_INSTANCE=${CDC_INSTANCE:-cdc}

mv $BASE/conf/example $BASE/conf/${CDC_INSTANCE}

canal_conf=$BASE/conf/canal.properties
canal_local_conf=$BASE/conf/canal_local.properties
instance_conf=$BASE/conf/${CDC_INSTANCE}/instance.properties
logback_configurationFile=$BASE/conf/logback.xml


sed -i "s|canal.zkServers =.*|canal.zkServers = ${CDC_ZOOKEEPER}|" $canal_conf
sed -i "s|canal.destinations =.*|canal.destinations = ${CDC_INSTANCE}|" $canal_conf
sed -i "s|canal.auto.scan =.*|canal.auto.scan = false|" $canal_conf
sed -i "s|canal.instance.global.spring.xml =.*|canal.instance.global.spring.xml = classpath:spring/default-instance.xml|" $canal_conf

sed -i "s|canal.instance.master.address=.*|canal.instance.master.address=${CDC_MASTER_ADDRESS}|" $instance_conf
sed -i "s|canal.instance.master.journal.name=.*|canal.instance.master.journal.name=${CDC_MASTER_JOURNAL_NAME}|" $instance_conf
sed -i "s|canal.instance.master.position=.*|canal.instance.master.position=${CDC_MASTER_JOURNAL_POSITION}|" $instance_conf
sed -i "s|canal.instance.dbUsername=.*|canal.instance.dbUsername=${CDC_MASTER_USERNAME}|" $instance_conf
sed -i "s|canal.instance.dbPassword=.*|canal.instance.dbPassword=${CDC_MASTER_PASSWORD}|" $instance_conf

CDC_INSTANCE_FILTER_REGEX=$(printf '%s\n' "${CDC_INSTANCE_FILTER_REGEX}" | sed -e 's/[]\/$*.^[]/\\&/g')
sed -i "s|canal.instance.filter.regex=.*|canal.instance.filter.regex=${CDC_INSTANCE_FILTER_REGEX}|" $instance_conf

if [ -z "$CDC_INSTANCE_FILTER_BLACK" ] ; then
    CDC_INSTANCE_FILTER_BLACK="information_schema\\\\..*,mysql\\\\..*,performance_schema\\\\..*,sys\\\\..*"
fi
CDC_INSTANCE_FILTER_BLACK=$(printf '%s\n' "${CDC_INSTANCE_FILTER_BLACK}" | sed -e 's/[]\/$*.^[]/\\&/g')
sed -i "s|canal.instance.filter.black.regex=.*|canal.instance.filter.black.regex=${CDC_INSTANCE_FILTER_BLACK}|" $instance_conf

echo ---
cat $canal_conf
echo ---
cat $instance_conf

## set java path
if [ -z "$JAVA" ] ; then
  JAVA=$(which java)
fi

if [ ! -z "$DEBUG_SUSPEND" ] ; then
    echo ---
    echo "enable debug on :9999!"
    JAVA_DEBUG_OPT="-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=9999,server=y,suspend=$DEBUG_SUSPEND"
fi

JAVA_OPTS="-server -Xms2048m -Xmx3072m -Xmn1024m -XX:SurvivorRatio=2 -XX:PermSize=96m -XX:MaxPermSize=256m -Xss256k -XX:-UseAdaptiveSizePolicy -XX:MaxTenuringThreshold=15 -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:+HeapDumpOnOutOfMemoryError"
JAVA_OPTS=" $JAVA_OPTS -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Dfile.encoding=UTF-8"
CANAL_OPTS="-DappName=otter-canal -Dlogback.configurationFile=$logback_configurationFile -Dcanal.conf=$canal_conf"

for i in $BASE/lib/*;
    do CLASSPATH=$i:"$CLASSPATH";
done

CLASSPATH="$BASE/conf:$CLASSPATH";

cd $BASE/bin

# echo CLASSPATH :$CLASSPATH
$JAVA $JAVA_OPTS $JAVA_DEBUG_OPT $CANAL_OPTS -classpath .:$CLASSPATH com.alibaba.otter.canal.deployer.CanalLauncher
