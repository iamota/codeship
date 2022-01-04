#!/bin/bash

###############################################################################
# Register SSL Certificate
###############################################################################
# - Register SSL certificate (self-signed or Let's Encrypt)
###############################################################################

# Abort on Error
set -e

# Read User Inputs
read -p "App Name (e.g. iamota_com): " APP_NAME
read -p "App Domains (e.g. iamota.com,www.iamota.com): " APP_DOMAINS


# Verify Inputs
echo ""
echo "=============================================================="
echo "CONFIRM SETTINGS"
echo "=============================================================="
echo "App Name:          ${APP_NAME}"
echo "App Domains:       ${APP_DOMAINS}"
echo "=============================================================="

# Confirm Settings
read -p "Are you ready to register this SSL certificate? " -n 1 confirm
echo ""
if [[ $confirm != "y" && $confirm != "Y" ]]
then
    echo "Aborting."
    exit 1
fi

# Ensure umask is set (files 664, directors 775)
umask 002

# Register a Self-Sigend SSL Certificate
# make-dummy-cert creates a combined cert+key, so duplicate it for legacy site
echo "Registering a self-signed SSL certificate..."
sudo /etc/ssl/certs/make-dummy-cert /etc/ssl/${APP_NAME}.crt
sudo cp /etc/ssl/${APP_NAME}.crt /etc/ssl/${APP_NAME}.key

# Register a Let's Encrypt Certificate
APP_DOMAINS_LIST=${APP_DOMAINS//,/ -d }
sudo certbot certonly --debug --agree-tos --email devops@iamota.com --webroot --webroot-path /mnt/nginx/${APP_NAME}/current -d ${APP_DOMAINS_LIST} -n --cert-name ${APP_NAME}

# If successful, remove existing self signed certificate
existing_certificate=/etc/ssl/${APP_NAME}.crt
new_certificate=/etc/letsencrypt/live/${APP_NAME}/fullchain.pem
if sudo test -e "$existing_certificate" && sudo test -e "$new_certificate"; then
    # Remove self signed certificate
    sudo rm -f /etc/ssl/${APP_NAME}.crt
    sudo rm -f /etc/ssl/${APP_NAME}.key

    # Symlink valid certifiate to the /etc/ssl/ folder
    sudo ln -sf /etc/letsencrypt/live/${APP_NAME}/fullchain.pem /etc/ssl/${APP_NAME}.crt
    sudo ln -sf /etc/letsencrypt/live/${APP_NAME}/privkey.pem /etc/ssl/${APP_NAME}.key
fi

# Reload Nginx
echo "Reloading Nginx..."
sudo service nginx reload

# Done
echo "SSL Certificate for ${APP_NAME} has been issued."
