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


### Check that nginx.conf exists
if [ -f "nginx.conf" ];
then
   echo -e "\e[1;40;32mFile nginx.conf exists"
else
   echo -e "\e[1;40;31mFile nginx.conf does not exist" >&2
   exit 1
fi


### Perform Dynamic nginx.conf String Replacement
for key in $(echo ${AWS_CLOUDFRONT_KEYS} | sed "s/,/ /g")
do
    value=${!key}
    temp=${value:?"You need to configure the ${key} environment variable specified in your AWS_CLOUDFRONT_KEYS!"}
    sed -i "s/\${$key}/$value/" nginx.conf
done
