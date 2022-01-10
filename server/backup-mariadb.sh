for d in /mnt/nginx/* ; do
    [ -L "${d%/}" ] && continue
    
    echo "$d"
    echo "-- Checking for .env..."
    if test -e "$d/current/.env"; then
        echo "-- Gathering DB credentials..."
      
        BACKUP_DB_HOST=`crudini --get $d/current/.env "" "DB_HOST"`
        BACKUP_DB_USER=`crudini --get $d/current/.env "" "DB_USER"`
        BACKUP_DB_PASSWORD=`crudini --get $d/current/.env "" "DB_PASSWORD"`
        BACKUP_DB_NAME=`crudini --get $d/current/.env "" "DB_NAME"`

        if [[ ${BACKUP_DB_HOST} && ${BACKUP_DB_USER} && ${BACKUP_DB_PASSWORD} && ${BACKUP_DB_NAME} ]]; then
            echo "-- Backing up ${BACKUP_DB_NAME} from ${BACKUP_DB_USER}:****@${BACKUP_DB_HOST}..."
            
            echo "-- TODO IMPLEMENT ACTUAL BACKUP STEP"
            
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
