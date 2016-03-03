#!/bin/bash
# Deploy the application to OpsWorks
#
# Add the following environment variables to your project configuration.
# * ENVIRONMENT             - Type of environment: dev, staging, or prod
# * AWS_DEFAULT_REGION      - AWS Region being used (e.g. us-west-2)
# * AWS_ACCESS_KEY_ID       - AWS Access Key ID for the user with write permission to the AWS_STACK_S3 bucket and deploy permission to AWS_STACK_ID
# * AWS_SECRET_ACCESS_KEY   - AWS Secret Access Key for the user with write permission to the AWS_APP_S3 bucket and deploy permission to AWS_STACK_ID
# * AWS_STACK_ID            - AWS OpsWorks ID for the Stack to deploy to
# * AWS_STACK_S3            - AWS S3 Bucket that stores compiled OpsWorks applications
# * AWS_APP_ID              - AWS OpsWorks ID for the App that is being deployed
# * APP_NAME                - Name given to this app (e.g. someproject)
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/deploy/opsworks.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/deploy/aws/opsworks.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e


### Verify ENV variables
ENVIRONMENT             =${ENVIRONMENT:?            'You need to configure the ENVIRONMENT environment variable! (dev, staging, or prod)'}
AWS_ACCESS_KEY_ID       =${AWS_ACCESS_KEY_ID:?      'You need to configure the AWS_ACCESS_KEY_ID environment variable!'}
AWS_SECRET_ACCESS_KEY   =${AWS_SECRET_ACCESS_KEY:?  'You need to configure the AWS_SECRET_ACCESS_KEY environment variable!'}
AWS_DEFAULT_REGION      =${AWS_DEFAULT_REGION:?     'You need to configure the AWS_DEFAULT_REGION environment variable!'}
AWS_STACK_ID            =${AWS_STACK_ID:?           'You need to configure the AWS_STACK_ID environment variable! (OpsWorks ID found on the Stack Settings page)'}
AWS_STACK_S3            =${AWS_STACK_S3:?           'You need to configure the AWS_STACK_S3 environment variable! (e.g. opsworks-iamota-dev)'}
AWS_APP_ID              =${AWS_APP_ID:?             'You need to configure the AWS_APP_ID environment variable! (OpsWorks ID found on the App page)'}
APP_NAME                =${APP_NAME:?               'You need to configure the APP_NAME environment variable! (e.g. someproject)'}


### Install AWS CLI
pip install awscli


### Activate the "OpsWorks" environment variables
mv .env.opsworks .env


### Zip the application
zip -r "${APP_NAME}-${ENVIRONMENT}.zip" .


### Upload Compiled Application to the OpsWorks S3 bucket
aws s3 cp ${APP_NAME}-${ENVIRONMENT}.zip s3://${AWS_STACK_S3}/${APP_NAME}-${ENVIRONMENT}.zip


### Trigger OpsWorks Deployment
aws opsworks --region us-east-1 create-deployment --stack-id ${AWS_STACK_ID} --app-id ${AWS_APP_ID} --command "{\"Name\": \"deploy\"}"
