#! /bin/bash
RSYNC_PARAMS='-avuq'
EXCLUDE_FILE='/root/scripts/exclude.sync'
PWD_FILE='/root/scripts/rsyncpwd'
TARGET='192.168.168.3'
TARGETPATH='/Backup'

STARTTIME=`date`
START=`date +%s%N`

echo $STARTTIME
printf "Start rsync to QNAP\n"

printf "Start copy of /data\n"
# Data Shares COPY
rsync -avu --exclude-from '/root/scripts/exclude.sync' --password-file=/root/scripts/rsyncpwd /data/ rsync://rsync@192.168.168.3/Backup/data/

printf "Start copy of /root\n"
# Root Home Copy
rsync -avu --password-file=/root/scripts/rsyncpwd /root/ rsync://rsync@192.168.168.3/Backup/home/root/

ENDTIME=`date`
END=`date +%s%N`

ELAPSED=`echo "scale=8; ($END - $START) / 1000000000" | bc`

echo $ENDTIME
printf "rsync fininshed\n"

printf "Elapsed time: "
echo $ELAPSED
printf "\n"

