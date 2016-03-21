#!/bin/bash
# Deploy the application's assets to CloudFront via S3
#
# Add the following environment variables to your project configuration.
# * AWS_CLOUDFRONT_KEYS     - CSV of ENV variable names that contain CloudFront distiribution IDs
#                             For each value in AWS_CLOUDFRONT_KEYS, define an ENV variable containing the
#                             associated CloudFront distiribution ID (e.g. export AWS_CLOUDFRONT_CDN="abc123")
# * AWS_DEFAULT_REGION      - AWS Region being used (e.g. us-west-2)
# * AWS_ACCESS_KEY_ID       - AWS Access Key ID for the user with write permission to the AWS_APP_S3 bucket
# * AWS_SECRET_ACCESS_KEY   - AWS Secret Access Key for the user with write permission to the AWS_APP_S3 bucket
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/deploy/aws/cloudfront_rewrite.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/deploy/cloudfront_rewrite.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e


### Verify ENV variables: AWS Authentication
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?'You need to configure the AWS_ACCESS_KEY_ID environment variable!'}
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:?'You need to configure the AWS_DEFAULT_REGION environment variable!'}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?'You need to configure the AWS_SECRET_ACCESS_KEY environment variable!'}


### Verify ENV variables: CloudFront ENV variable names (names of key/value pairs of Variable Name => CloudFront ID)
AWS_CLOUDFRONT_KEYS=${AWS_CLOUDFRONT_KEYS:?'You need to configure the AWS_CLOUDFRONT_KEYS environment variable!'}


### Check for nginx.conf
echo -e "\e[1;40;32mCheck for nginx.conf..."
if [ -s "nginx.conf" ];
then
    echo -e "\e[1;40;32mFile nginx.conf found"
    echo -e
else
    echo -e "\e[1;40;33mWarning: File nginx.conf not found"
    echo -e
fi


### Check for .htaccess
echo -e "\e[1;40;32mCheck for .htaccess..."
if [ -s ".htaccess" ];
then
    echo -e "\e[1;40;32mFile .htaccess found"
    echo -e
else
    echo -e "\e[1;40;33mWarning: File .htaccess not found"
    echo -e
fi


### Perform Dynamic nginx.conf String Replacement
echo -e "\e[1;40;32mPerform Dynamic nginx.conf String Replacement..."
for key in $(echo ${AWS_CLOUDFRONT_KEYS} | sed "s/,/ /g")
do
    value=${!key}
    temp=${value:?"You need to configure the ${key} environment variable specified in your AWS_CLOUDFRONT_KEYS!"}

    ### Replace nginx.conf
    if [ -s "nginx.conf" ];
    then
        echo -e "\e[1;40;32mReplacing \e[1;40;33m\${$key}\e[1;40;32m with '\e[1;40;33m${value}\e[1;40;32m' in nginx.conf..."
        sed -i "s/\${$key}/$value/" nginx.conf
    fi

    ### Replace .htaccess
    if [ -s ".htaccess" ];
    then
        echo -e "\e[1;40;32mReplacing \e[1;40;33m\${$key}\e[1;40;32m with '\e[1;40;33m${value}\e[1;40;32m' in .htaccess..."
        sed -i "s/\${$key}/$value/" .htaccess
    fi

done
