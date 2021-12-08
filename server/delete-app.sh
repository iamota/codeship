#!/bin/bash

###############################################################################
# Setup an App
###############################################################################
# - Create folders for /mnt/ngnix/[app-name]/curernt
# - Create .env stub
# - Create database
# - Register wtih Nginx
# - Register with CloudWatch
# - Add Codeship delpoyment keys
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

# Done
echo "App ${APP_NAME} has been removed."
echo "If you're 100% sure, you can delete the code now:"
echo "sudo rm -rf /mnt/nginx/${APP_NAME}"
