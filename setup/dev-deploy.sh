#!/bin/bash
# Deploy with Rsync or with Opsworks
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/dev-deploy.sh | bash -s

#
### Get ElasticIp of the stack
elasticip=$(aws opsworks --region us-east-1 describe-instances --stack-id ${AWS_STACK_ID} --output text --query 'Instances[*].[ElasticIp]')
echo $elasticip
#
# Check if SSH is added to the instance
if [ ssh "codeship@$elasticip" ]; then
	### Rsync directly into the instance for automated testing
	### Some of the app name uses dash instead of underscore. Need to make this more consistent to avoid error.
	rsync -rave "ssh" --rsync-path="sudo rsync" . codeship@$elasticip:/mnt/httpd/${APP_NAME//-/_}/current/
	### Set ownership of the folder
	ssh codeship@$elasticip sudo chown -R apache:apache /mnt/httpd/${APP_NAME//-/_}/current/
	### remove timber cache from uploads folder
	ssh codeship@$elasticip sudo rm -rf /mnt/httpd/${APP_NAME//-/_}/current/wp-content/uploads/cache/timber/
else
	### Trigger OpsWorks Deployment
	aws opsworks --region us-east-1 create-deployment --stack-id ${AWS_STACK_ID} --app-id ${AWS_APP_ID} --command "{\"Name\": \"deploy\"}"
	# End if SSH is added to the instance
fi