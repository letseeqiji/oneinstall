#!/bin/bash

. /etc/rc.d/init.d/functions

if [ $# -ne 0 ];then
   echo "Usage:sh `basename $0`"
   exit 1
fi

#MASTER VARIABLES
MASTER_USER=主库用户
MASTER_PASS="主库用户密码"
MASTER_PORT=主库端口
MASTER_IP="主库ip地址"
REP_USER='复制用用户'
REP_PWD='复制用用户密码' 
MASTER_DATA_PATH=日志备份路径[/data/backup]
MASTER_STATUS_FILE=${MASTER_DATA_PATH}/mysqllogs_`date +%F`.log
MASTER_DATA_FILE=${MASTER_DATA_PATH}/mysql_backup_`date +%F`.sql.gz
 
MYSQL_DIR=mysql运行程序的路径[/usr/local/mysql/bin]
MASTER_MYSQL_CMD="$MYSQL_DIR/mysql -u$MASTER_USER -p$MASTER_PASS -h$MASTER_IP -P$MASTER_PORT"
MASTER_MYSQL_DUMP="$MYSQL_DIR/mysqldump -u$MASTER_USER -p$MASTER_PASS -h$MASTER_IP -P$MASTER_PORT  -A  -B -F --single-transaction --events "

#SLAVE VARIABLES
SLAVE_USER=从库用户
SLAVE_PASS="从库用户密码"
SLAVE_PORT=从库端口
SLAVE_IP="从库ip地址"
SLAVE_MYSQL_CMD="$MYSQL_DIR/mysql -u$SLAVE_USER -p$SLAVE_PASS -h$SLAVE_IP -P$SLAVE_PORT"
TO_MAIL="通知邮箱"
SENDMAIL="mail -v -s "MySQL-Slave-build-status" $TO_MAIL"

[ ! -d $MASTER_DATA_PATH ] && mkdir -p $MASTER_DATA_PATH
[ `$MASTER_MYSQL_CMD -e "select user,host from mysql.user" 2> /dev/null |grep rep|wc -l` -ne 1 ] &&\
$MASTER_MYSQL_CMD -e "grant replication slave on *.* to 'rep'@'192.168.1.%' identified by '密码';" 2> /dev/null
[ $? -eq 0  ] && action "主库创建复制用户" /bin/true  
 
$MASTER_MYSQL_CMD -e "flush tables with read lock;"  2> /dev/null
[ $? -eq 0  ] && action "开始锁表" /bin/true ||  action "开始锁表" /bin/false || exit 1 
echo "-----show master status result-----" >$MASTER_STATUS_FILE
$MASTER_MYSQL_CMD -e "show master status;" 2> /dev/null >>$MASTER_STATUS_FILE
[ $? -eq 0  ] && action "查看MASTER状态" /bin/true ||  action "查看MASTER状态" /bin/false ||  exit 1
#echo "${MASTER_MYSQL_DUMP} | gzip > $MASTER_DATA_FILE"
${MASTER_MYSQL_DUMP} 2> /dev/null | gzip > $MASTER_DATA_FILE 
[ $? -eq 0  ] && action "备份主库" /bin/true || action "备份主库" /bin/false || exit 1
$MASTER_MYSQL_CMD -e "unlock tables;" >/dev/null 2>&1
[ $? -eq 0  ] && action "表锁释放" /bin/true
#cat $MASTER_STATUS_FILE

###############################################################################

 
#recover

[ -d ${MASTER_DATA_PATH} ]  && cd ${MASTER_DATA_PATH} && rm -f mysql_backup_`date +%F`.sql
gzip -d mysql_backup_`date +%F`.sql.gz
[ $? -eq 0  ] && action "解压备份文件" /bin/true || action "解压备份文件" /bin/false || exit 1
$SLAVE_MYSQL_CMD  2> /dev/null < mysql_backup_`date +%F`.sql
[ $? -eq 0  ] && action "恢复数据至从库" /bin/true || action "恢复数据至从库" /bin/false || exit 1
MASTER_LOG_FILE=`tail -1 $MASTER_STATUS_FILE|cut -f1`
MASTER_LOG_POS=`tail -1 $MASTER_STATUS_FILE|cut -f2`

 
#config slave

$SLAVE_MYSQL_CMD -e "\
CHANGE MASTER TO  \
MASTER_HOST='$MASTER_IP', \
MASTER_PORT=$MASTER_PORT, \
MASTER_USER='$REP_USER', \
MASTER_PASSWORD='$REP_PWD', \
MASTER_LOG_FILE='$MASTER_LOG_FILE',\
MASTER_LOG_POS=$MASTER_LOG_POS;" 2> /dev/null



if [ $? -eq 0  ] ;then 
     action "执行CHANGE MASTER TO命令" /bin/true 
else
      action "执行CHANGE MASTER TO命令" /bin/false 
      $SLAVE_MYSQL_CMD -e "show slave status\G" 2> /dev/null >> $MASTER_STATUS_FILE
      #echo "$SENDMAIL < $MASTER_STATUS_FILE"
      $SENDMAIL  < $MASTER_STATUS_FILE 2> /dev/null
      exit 1
fi


$SLAVE_MYSQL_CMD -e "start slave;" 2> /dev/null

[ $? -eq 0  ] && action "启动从库复制" /bin/true || action "启动从库复制" /bin/false || exit 1
$SLAVE_MYSQL_CMD -e "show slave status\G" 2> /dev/null |egrep "IO_Running|SQL_Running"  >>$MASTER_STATUS_FILE

MasterLogFile=`$SLAVE_MYSQL_CMD -e "show slave status\G" 2> /dev/null |egrep -i "\<Master_Log_File\>"| awk '{print $2}'`
RelayMasterLogFile=`$SLAVE_MYSQL_CMD -e "show slave status\G" 2> /dev/null |egrep -i "\<Relay_Master_Log_File\>"| awk '{print $2}'`
ReadMasterLogPos=`$SLAVE_MYSQL_CMD -e "show slave status\G" 2> /dev/null |egrep -i "\<Read_Master_Log_Pos\>"| awk '{print $2}'`
ExecMasterLogPos=`$SLAVE_MYSQL_CMD -e "show slave status\G" 2> /dev/null |egrep -i "\<Exec_Master_Log_Pos\>"| awk '{print $2}'`
REP_STATUS=`$SLAVE_MYSQL_CMD -e "show slave status\G" 2> /dev/null |egrep "Slave_IO_Running|Slave_SQL_Running" |grep -c "Yes"`

if [ $MasterLogFile == $RelayMasterLogFile  ] && [ $ReadMasterLogPos == $ExecMasterLogPos  ] && [ $REP_STATUS -eq 2 ];then
   action "主从复制状态检测正常" /bin/true 
else
   action "主从复制状态检测正常" /bin/false
   $SLAVE_MYSQL_CMD -e "show slave status\G" 2> /dev/null >> $MASTER_STATUS_FILE
   $SENDMAIL  < $MASTER_STATUS_FILE 2> /dev/null
   exit 1
fi

$SENDMAIL  < $MASTER_STATUS_FILE 2> /dev/null