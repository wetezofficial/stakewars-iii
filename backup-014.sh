#!/bin/bash
# 0 12 * * * /data/near_backup/backup.sh >> /data/near_backup/backup.log 2>&1

DATE=$(date +%Y-%m-%d-%H-%M)
DATADIR=/home/near/.near
BACKUPDIR=/home/near/near_backup

mkdir -p ${BACKUPDIR}

# `touch $BACKUPDIR/near_data_testfile` for the first run.
OLDEST=$(ls -t ${BACKUPDIR}/near_data_* | tail -1)

sudo systemctl stop neard.service

wait

echo "[$(date "+%Y-%m-%d %H:%M:%S")] NEAR node was stopped" | ts

if [ -d "${BACKUPDIR}" ]; then
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] NEAR Data Backup started." | ts

    cd ${DATADIR}
    tar -czf ${BACKUPDIR}/near_data_${DATE}.tgz data

    # Submit backup completion status, you can use healthchecks.io, betteruptime.com or other services
    # Example
    # curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/xXXXxXXx-XxXx-XXXX-XXXx-...

    echo "[$(date "+%Y-%m-%d %H:%M:%S")] NEAR Data Backup completed to ${BACKUPDIR}/near_data_${DATE}.tgz " | ts

    rm -f ${OLDEST}
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Deleted Backup file ${OLDEST}." | ts
else
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] ${BACKUPDIR} is not created. Check your permissions."
    exit 0
fi

sudo systemctl start neard.service

echo "[$(date "+%Y-%m-%d %H:%M:%S")] NEAR node was started" | ts
