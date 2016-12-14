#!/bin/bash
# Deploy with Rsync or with Opsworks
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/dev-deploy.sh | bash -s


### Install AWS CLI
pip install awscli
#
### Get ElasticIp of the stack
elasticip=$(aws opsworks --region us-east-1 describe-instances --stack-id ${AWS_STACK_ID} --output text --query 'Instances[*].[ElasticIp]')
echo $elasticip
#
# Check if SSH is added to the instance
if [ ssh codeship@$elasticip ]; then
#
### Rsync directly into the instance for automated testing
# File transfer test
### Some of the app name uses dash instead of underscore. Need to make this more consistent to avoid error.
rsync -rave "ssh" --rsync-path="sudo rsync" . codeship@$elasticip:/mnt/httpd/${APP_NAME//-/_}/current/
### Set ownership of the folder
ssh codeship@$elasticip sudo chown -R apache:apache /mnt/httpd/${APP_NAME//-/_}/current/
### remove timber cache from uploads folder
ssh codeship@$elasticip sudo rm -rf /mnt/httpd/${APP_NAME//-/_}/current/wp-content/uploads/cache/timber/
#
#
### Zip the application (ignore any files named .git* in any folder)
zip -r "${APP_NAME}-${ENVIRONMENT}.zip" .
#
### Upload Compiled Application to S3
aws s3 cp ${APP_NAME}-${ENVIRONMENT}.zip s3://${AWS_STACK_S3}/${AWS_STACK_NAME}-${ENVIRONMENT}.zip
#
else
#
### Zip the application (ignore any files named .git* in any folder)
zip -r "${APP_NAME}-${ENVIRONMENT}.zip" .
#
### Upload Compiled Application to S3
aws s3 cp ${APP_NAME}-${ENVIRONMENT}.zip s3://${AWS_STACK_S3}/${AWS_STACK_NAME}-${ENVIRONMENT}.zip
#
#
### Trigger OpsWorks Deployment
aws opsworks --region us-east-1 create-deployment --stack-id ${AWS_STACK_ID} --app-id ${AWS_APP_ID} --command "{\"Name\": \"deploy\"}"
# End if SSH is added to the instance
fi
