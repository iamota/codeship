#!/bin/bash

TODAY=`date +"%Y-%b-%d"`  # e.g. 2022-Jan-01
DAYOFMONTH=`date +"%d"`   # e.g. 01
DAYOFWEEK=`date +"%a"`    # e.g. Sat

# Define BACKUPTYPE (1st backup of the month is a "Monthly" backup, rest are "Daily")
[[ $DAYOFMONTH = 1 ]] && BACKUPTYPE="Monthly" || BACKUPTYPE="Daily"

BACKUP_DB_PATH="/tmp/db-backups"
BACKUP_DB_S3="iamota-db-backups"

mkdir -p ${BACKUP_DB_PATH}

for d in /mnt/nginx/* ; do
    [ -L "${d%/}" ] && continue
    
    echo "$d"
    echo "-- Checking for .env..."
    if test -e "$d/current/.env"; then
        echo "-- Gathering DB credentials..."

        BACKUP_DB_ENVIRONMENT=`crudini --get $d/current/.env "" "ENVIRONMENT"`
        BACKUP_DB_HOST=`crudini --get $d/current/.env "" "DB_HOST"`
        BACKUP_DB_USER=`crudini --get $d/current/.env "" "DB_USER"`
        BACKUP_DB_PASSWORD=`crudini --get $d/current/.env "" "DB_PASSWORD"`
        BACKUP_DB_NAME=`crudini --get $d/current/.env "" "DB_NAME"`

        if [[ ${BACKUP_DB_HOST} && ${BACKUP_DB_USER} && ${BACKUP_DB_PASSWORD} && ${BACKUP_DB_NAME} && ${BACKUP_DB_ENVIRONMENT} ]]; then
            echo "-- Backing up ${BACKUP_DB_NAME} from ${BACKUP_DB_USER}:****@${BACKUP_DB_HOST}..."
            
            BACKUP_FILENAME="${BACKUP_DB_NAME}-${TODAY}--${BACKUP_DB_ENVIRONMENT}.sql.gz"
            BACKUP_FILE="${BACKUP_DB_PATH}/${BACKUP_FILENAME}"
            BACKUP_S3_KEY="iamota-${BACKUP_DB_ENVIRONMENT}/${BACKUP_DB_NAME}/${BACKUP_FILENAME}"
            BACKUP_S3_LINK="s3://${BACKUP_DB_S3}/${BACKUP_S3_KEY}"
            
            echo "---- Dumping DB (${BACKUP_DB_NAME} to ${BACKUP_FILE})..."
            mysqldump --user=${BACKUP_DB_USER} --password=${BACKUP_DB_PASSWORD} --lock-tables --databases ${BACKUP_DB_NAME} | gzip > ${BACKUP_FILE}
            
            echo "---- Pushing to S3 (${BACKUP_S3_LINK})..."
            aws s3 mv ${BACKUP_FILE} ${BACKUP_S3_LINK}
            
            echo "---- Tagging object in S3 ({environment: ${BACKUP_DB_ENVIRONMENT}, Database: ${BACKUP_DB_NAME}, DayOfMonth: ${DAYOFMONTH}, DayOfWeek: ${DAYOFWEEK}, BackupType: ${BACKUPTYPE}})"
            aws s3api put-object-tagging \
                --bucket ${BACKUP_DB_S3} \
                --key ${BACKUP_S3_KEY} \
                --tagging "{\"TagSet\": [ { \"Key\": \"environment\", \"Value\": \"${BACKUP_DB_ENVIRONMENT}\" }, { \"Key\": \"Database\", \"Value\": \"${BACKUP_DB_NAME}\" }, { \"Key\": \"DayOfMonth\", \"Value\": \"${DAYOFMONTH}\" }, { \"Key\": \"DayOfWeek\", \"Value\": \"${DAYOFWEEK}\" }, { \"Key\": \"BackupType\", \"Value\": \"${BACKUPTYPE}\" } ]}"
            
            echo "---- Removing local copy..."
            rm -rf ${BACKUP_FILE}
            
            echo "-- Backup complete."
        else
            echo "-- DB Credentials not found, aborting backup."
        fi;
        
        unset BACKUP_DB_HOST
        unset BACKUP_DB_USER
        unset BACKUP_DB_PASSWORD
        unset BACKUP_DB_NAME
       
    else
        echo "-- $d/current/.env not found, aborting backup.";
    fi;    
    
    echo ""
    echo "----------------------------------------";
    echo ""
done
