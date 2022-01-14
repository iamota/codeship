#!/bin/bash

TODAY=`date +"%Y-%b-%d"`
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
            
            echo "---- Dumping DB (${BACKUP_DB_PATH}/${BACKUP_DB_NAME}-${TODAY}--${BACKUP_DB_ENVIRONMENT}.sql.gz)..."
            mysqldump --user=${BACKUP_DB_USER} --password=${BACKUP_DB_PASSWORD} --lock-tables --databases ${BACKUP_DB_NAME} | gzip > ${BACKUP_DB_PATH}/${BACKUP_DB_NAME}-${TODAY}--${BACKUP_DB_ENVIRONMENT}.sql.gz
            
            echo "---- Pushing to S3 (s3://${BACKUP_DB_S3}/iamota-${BACKUP_DB_ENVIRONMENT}/${BACKUP_DB_NAME}/${BACKUP_DB_NAME}-${TODAY}--${BACKUP_DB_ENVIRONMENT}.sql.gz)..."
            aws s3 mv ${BACKUP_DB_PATH}/${BACKUP_DB_NAME}-${TODAY}--${BACKUP_DB_ENVIRONMENT}.sql.gz s3://${BACKUP_DB_S3}/iamota-${BACKUP_DB_ENVIRONMENT}/${BACKUP_DB_NAME}/${BACKUP_DB_NAME}-${TODAY}--${BACKUP_DB_ENVIRONMENT}.sql.gz
            
            echo "---- Removing local copy..."
            rm -rf ${BACKUP_DB_PATH}/${BACKUP_DB_NAME}-${TODAY}--${BACKUP_DB_ENVIRONMENT}.sql.gz
            
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
