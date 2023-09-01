#!/bin/bash

###############################################################################
# Delete an App
###############################################################################
# - Remove SSL Certificates
# - Remove Let's Encrypt registration
# - Remove Nginx registration + restart Nginx
# - Remove CloudWatch log registration + restart CloudWatch Log Monitor
# - Archive the code in /mnt/archive/[app-name]
###############################################################################

# Abort on Error
set -e

# Read User Inputs
read -p "App Name (e.g. iamota_com): " APP_NAME

# Confirm Settings
read -p "Are you sure you want to delete ${APP_NAME}? " -n 1 confirm
echo ""
if [[ $confirm != "y" && $confirm != "Y" ]]
then
    echo "Aborting."
    exit 1
fi

# Remove SSL Certificate
echo "Removing SSL certificates..."
sudo rm -f /etc/ssl/${APP_NAME}.crt
sudo rm -f /etc/ssl/${APP_NAME}.key

# Remove Let's Encrypt Registration
echo "Removing Let's Encrypt Registration..."
sudo rm -f /etc/letsencrypt/renewal/${APP_NAME}.conf
sudo rm -f /etc/letsencrypt/live/${APP_NAME}

# Register Site with Nginx
echo "Un-Registering Site with Nginx..."
sudo rm -f /etc/nginx/conf.d/${APP_NAME}.conf

# Reload Nginx
echo "Reloading Nginx..."
sudo service nginx reload

# Register Logs with CloudWatch
echo "Un-Registering Logs with CloudWatch..."

# Access Logs (HTTP)
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/access.log"

# Access Logs (HTTPS)
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/ssl.access.log"

# Error Logs
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/error.log"

# Sucuri Whitelist Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-whitelist.log"

# Sucuri Last Logins Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-lastlogins.php"

# Sucuri Audit Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-auditlogs.php"

# Sucuri Audit Queue Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-auditqueue.php"

# Sucuri Failed Logins Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-failedlogins.php"

# Sucuri Hook Data Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-hookdata.php"

# Sucuri Ignore Scanning Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-ignorescanning.php"

# Sucuri Integrity Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-integrity.php"

# Sucuri Site Check Log
sudo crudini --del /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-sitecheck.php"

# Restart CloudWatch Log Monitor
echo "Restarting CloudWatch log monitor..."
sudo systemctl restart awslogsd

# Move Code to Archive
echo "Archiving Code..."
if [ ! -d "/mnt/archive" ]; then
    sudo mkdir -p /mnt/archive
fi
sudo mv /mnt/nginx/${APP_NAME} /mnt/archive/${APP_NAME}

# Done
echo ""
echo "###############################################################################"
echo "# ${APP_NAME} has been removed."
echo "# The code has been archived in /mnt/archive/${APP_NAME}"
echo "###############################################################################"
echo "# If you want to remove it entirely, you can run:"
echo "# sudo rm -rf /mnt/archive/${APP_NAME}"
echo "###############################################################################"
echo ""
