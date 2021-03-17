#!/bin/bash 

### Start script ###
##### Set variable #####

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +'%m-%d-%Y'`
DB_BACKUP_PATH='/root/tuyendd/db_backup'
DATABASE_NAME=`mysql --defaults-file=/etc/mysql/debian.cnf -e "show databases" | grep -v 'information_schema\|performance_schema\|Database\|mysql\|sys'`
CMD="mysqldump --defaults-file=/etc/mysql/debian.cnf --routines --ignore-table=mysql.event"
BACKUP_RETAIN_DAYS=14   ## Number of days to keep local backup copy
LOGFILE='/root/mysql-backup-output.log'
DATE_EXEC="$(date "+%d %b %Y %H:%M")"
TMPFILE='/tmp/ipinfo-$DATE_EXEC.txt'
HOSTNAME=$(hostname)

##### Backup database and gzip it #####
 
mkdir -p ${DB_BACKUP_PATH}/${TODAY}
echo "${TODAY} Backup started for database - ${DATABASE_NAME}" >> $LOGFILE 2>&1
 
 for DB in $DATABASE_NAME; do
   $CMD $DB > ${DB_BACKUP_PATH}/${TODAY}/${DB}-${TODAY}.sql

gzip ${DB_BACKUP_PATH}/${TODAY}/${DB}-${TODAY}.sql
done

##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####
 
DBDELDATE=`date +'%m-%d-%Y' --date="${BACKUP_RETAIN_DAYS} days ago"`
 
if [ ! -z ${DB_BACKUP_PATH} ]; then
      cd ${DB_BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi
### End of script ###
