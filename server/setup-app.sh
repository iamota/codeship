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
read -p "App Primary URL (e.g. https://www.iamota.com): " APP_URL


# Verify Inputs
echo ""
echo "=============================================================="
echo "CONFIRM SETTINGS"
echo "=============================================================="
echo "App Name:          ${APP_NAME}"
echo "App Primary URL:   ${APP_URL}"
echo "App Path:          /mnt/nginx/${APP_NAME}/current"
echo "=============================================================="

# Confirm Settings
read -p "Are you ready to setup this app? " -n 1 confirm
echo ""
if [[ $confirm != "y" && $confirm != "Y" ]]
then
    echo "Aborting."
    exit 1
fi

# Ensure umask is set (files 664, directors 775)
umask 002

# Prepare folder structure
echo "Creating App folders..."
mkdir /mnt/nginx/${APP_NAME} -m 775
mkdir /mnt/nginx/${APP_NAME}/current -m 775
mkdir /mnt/nginx/${APP_NAME}/current/log -m 775
mkdir /mnt/nginx/${APP_NAME}/current/cache -m 775

# Create .env file
echo "Creating .env stub..."
cat << EOF > /mnt/nginx/${APP_NAME}/current/.env
ENVIRONMENT = ${ENVIRONMENT}
EOF


# Register a Self-Sigend SSL Certificate
# make-dummy-cert creates a combined cert+key, so duplicate it for legacy site
echo "Registering a self-signed SSL certificate..."
sudo /etc/ssl/certs/make-dummy-cert /etc/ssl/${APP_NAME}.crt
sudo cp /etc/ssl/${APP_NAME}.crt /etc/ssl/${APP_NAME}.key

# Register Site with Nginx
echo "Registering Site with Nginx..."
touch /mnt/nginx/${APP_NAME}/current/nginx.conf
sudo tee /etc/nginx/conf.d/${APP_NAME}.conf << EOF
include /mnt/nginx/${APP_NAME}/current/nginx.conf;
EOF

# Reload Nginx
echo "Reloading Nginx..."
sudo service nginx reload

# Register Logs with CloudWatch
echo "Registering Logs with CloudWatch..."

# Access Logs (HTTP)
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/access.log"                "file"            "/var/log/nginx/${APP_NAME}.access.log"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/access.log"                "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/access.log"                "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/access.log"

# Access Logs (HTTPS)
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/ssl.access.log"            "file"            "/var/log/nginx/${APP_NAME}.ssl.access.log"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/ssl.access.log"            "log_group_name"  "${SERVER_NAME}/"${APP_NAME}
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/ssl.access.log"            "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/ssl.access.log"

# Error Logs
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/error.log"                 "file"            "/var/log/nginx/${APP_NAME}.error.log"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/error.log"                 "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/error.log"                 "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/error.log"

# Sucuri Whitelist Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-whitelist.log"      "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-whitelist.log"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-whitelist.log"      "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-whitelist.log"      "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-whitelist.log"

# Sucuri Last Logins Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-lastlogins.php"     "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-lastlogins.php"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-lastlogins.php"     "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-lastlogins.php"     "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-lastlogins.php"

# Sucuri Audit Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-auditlogs.php"      "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-auditlogs.php"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-auditlogs.php"      "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-auditlogs.php"      "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-auditlogs.php"

# Sucuri Audit Queue Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-auditqueue.php"     "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-auditqueue.php"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-auditqueue.php"     "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-auditqueue.php"     "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-auditqueue.php"

# Sucuri Failed Logins Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-failedlogins.php"   "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-failedlogins.php"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-failedlogins.php"   "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-failedlogins.php"   "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-failedlogins.php"

# Sucuri Hook Data Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-hookdata.php"       "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-hookdata.php"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-hookdata.php"       "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-hookdata.php"       "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-hookdata.php"

# Sucuri Ignore Scanning Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-ignorescanning.php" "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-ignorescanning.php"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-ignorescanning.php" "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-ignorescanning.php" "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-ignorescanning.php"

# Sucuri Integrity Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-integrity.php"      "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-integrity.php"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-integrity.php"      "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-integrity.php"      "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-integrity.php"

# Sucuri Site Check Log
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-sitecheck.php"      "file"            "/mnt/nginx/${APP_NAME}/log/sucuri-sitecheck.php"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-sitecheck.php"      "log_group_name"  "${SERVER_NAME}/${APP_NAME}"
sudo crudini --set /etc/awslogs/awslogs.conf "${SERVER_NAME}/${APP_NAME}/sucuri-sitecheck.php"      "log_stream_name" "${SERVER_NAME}/{instance_id}/${APP_NAME}/log/sucuri-sitecheck.php"

# Restart CloudWatch Log Monitor
echo "Restarting CloudWatch log monitor..."
sudo systemctl restart awslogsd


# Configure Sucuri
echo "Preparing Sucuri settings..."
# Set Sucuri Debug Mod
if [ "${ENVIRONMENT}" = "prod" ]
    then SUCURI_DEBUG="enabled"
    else SUCURI_DEBUG="disabled"
fi

# Define Sucuri JSON
SUCURI_JSON=$(jq   -n -c \
                   --arg debug            "${SUCURI_DEBUG}" \
                   --arg sucuri_key       "" \
                   --arg sucuri_cloud_key "" \
                   --arg sucuri_notify_to "devops+${SERVER_NAME}.${APP_NAME}@iamota.com" \
                   --arg app_url          "${APP_URL}" \
                   '{
                        "sucuriscan_diff_utility":              "enabled",
                        "sucuriscan_notify_available_updates":  "disabled",
                        "sucuriscan_notify_bruteforce_attack":  "disabled",
                        "sucuriscan_notify_failed_login":       "disabled",
                        "sucuriscan_notify_plugin_activated":   "disabled",
                        "sucuriscan_notify_plugin_deactivated": $debug,
                        "sucuriscan_notify_plugin_deleted":     $debug,
                        "sucuriscan_notify_plugin_installed":   "disabled",
                        "sucuriscan_notify_plugin_updated":     "disabled",
                        "sucuriscan_notify_post_publication":   "disabled",
                        "sucuriscan_notify_scan_checksums":     "disabled",
                        "sucuriscan_notify_settings_updated":   $debug,
                        "sucuriscan_notify_theme_activated":    $debug,
                        "sucuriscan_notify_theme_deleted":      $debug,
                        "sucuriscan_notify_theme_editor":       $debug,
                        "sucuriscan_notify_theme_installed":    $debug,
                        "sucuriscan_notify_theme_updated":      "disabled",
                        "sucuriscan_notify_user_registration":  "disabled",
                        "sucuriscan_notify_website_updated":    "disabled",
                        "sucuriscan_notify_widget_added":       $debug,
                        "sucuriscan_notify_widget_deleted":     $debug,
                        "sucuriscan_notify_to":                 $sucuri_notify_to,
                        "sucuriscan_api_key":                   $sucuri_key,
                        "sucuriscan_cloudproxy_apikey":         $sucuri_cloud_key,
                        "sucuriscan_addr_header":               "HTTP_X_SUCURI_CLIENTIP",
                        "sucuriscan_revproxy":                  $debug,
                        "sucuriscan_auto_clear_cache":          $debug,
                        "sucuriscan_sitecheck_target":          $app_url,
                        "sucuriscan_lastlogin_redirection":     "enabled",
                        "sucuriscan_selfhosting_monitor":       "disabled",
                        "sucuriscan_selfhosting_fpath":         "",
                        "sucuriscan_api_service":               "enabled",
                        "sucuriscan_notify_success_login":      "disabled",
                        "sucuriscan_runtime":                   0,
                        "sucuriscan_site_version":              "5.8.1",
                        "sucuriscan_checksum_api":              "",
                        "sucuriscan_timezone":                  "UTC+00.00",
                        "sucuriscan_plugin_version":            "1.8.28",
                        "sucuriscan_ignored_events":            "",
                        "sucuriscan_maximum_failed_logins":     30,
                        "sucuriscan_api_protocol":              "https",
                        "sucuriscan_dns_lookups":               $debug,
                        "sucuriscan_email_subject":             "Sucuri Alert, :domain, :event, :remoteaddr",
                        "sucuriscan_emails_per_hour":           5,
                        "sucuriscan_notify_plugin_change":      $debug,
                        "sucuriscan_prettify_mails":            "disabled",
                        "sucuriscan_use_wpmail":                $debug
                    }' )

# Write Sucuri Config
echo "Creating sucuri-settings.php..."
echo "<?php exit(0); ?>${SUCURI_JSON}" > /mnt/nginx/${APP_NAME}/current/log/sucuri-settings.php

# Done
echo "App ${APP_NAME} has been initalized."
