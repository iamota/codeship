#!/bin/bash
# Deploy the application to AWS Lambda
#
# Add the following environment variables to your project configuration.
# * AWS_DEFAULT_REGION      - AWS Region being used (e.g. us-west-2)
# * AWS_ACCESS_KEY_ID       - AWS Access Key ID for the user with write permission to the AWS_STACK_S3 bucket and deploy permission to AWS_STACK_ID
# * AWS_SECRET_ACCESS_KEY   - AWS Secret Access Key for the user with write permission to the AWS_APP_S3 bucket and deploy permission to AWS_STACK_ID
# * FUNCTION_NAME           - AWS Lambda Function Name (e.g. my-function)
# * FUNCTION_PATH           - Path to function code in the repo (e.g. some/path/to/code)
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/deploy/lambda.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/deploy/aws/lambda.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e


### Verify ENV variables
AWS_ACCESS_KEY_ID       =${AWS_ACCESS_KEY_ID:?      'You need to configure the AWS_ACCESS_KEY_ID environment variable!'}
AWS_SECRET_ACCESS_KEY   =${AWS_SECRET_ACCESS_KEY:?  'You need to configure the AWS_SECRET_ACCESS_KEY environment variable!'}
AWS_DEFAULT_REGION      =${AWS_DEFAULT_REGION:?     'You need to configure the AWS_DEFAULT_REGION environment variable!'}
FUNCTION_NAME           =${FUNCTION_NAME:?          'You need to configure the FUNCTION_NAME environment variable! (e.g. my-function)'}
FUNCTION_PATH           =${FUNCTION_PATH:?          'You need to configure the FUNCTION_PATH environment variable! (e.g. some/path/to/code)'}


### Install AWS CLI
pip install awscli

# Access the Function's Code
cd $HOME/clone/{$FUNCTION_PATH}

# Zip the Code
zip -r ${FUNCTION_NAME}.zip .

# Update the latest version of the code
FUNCTION_SHA256=`aws lambda update-function-code --function-name $FUNCTION_NAME --zip-file fileb://{$FUNCTION_NAME}.zip | jq -r .CodeSha256`
echo $FUNCTION_SHA256

# Publishing a new Version of the Lambda function
FUNCTION_VERSION=`aws lambda publish-version --function-name $FUNCTION_NAME --code-sha256 $FUNCTION_SHA256 --description "$CI_COMMIT_ID" | jq -r .Version`
echo $FUNCTION_VERSION

# Updating the PROD Lambda Alias so it points to the new function
aws lambda update-alias --function-name $FUNCTION_NAME --function-version $FUNCTION_VERSION --name $CI_BRANCH
