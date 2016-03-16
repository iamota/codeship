#!/bin/bash
# Deploy the application's assets to CloudFront via S3
#
# Add the following environment variables to your project configuration.
# * AWS_DEFAULT_REGION      - AWS Region being used (e.g. us-west-2)
# * AWS_ACCESS_KEY_ID       - AWS Access Key ID for the user with write permission to the AWS_APP_S3 bucket
# * AWS_SECRET_ACCESS_KEY   - AWS Secret Access Key for the user with write permission to the AWS_APP_S3 bucket
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/deploy/cloudfront.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/deploy/cloudfront.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e


### Verify ENV variables: AWS Authentication
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?'You need to configure the AWS_ACCESS_KEY_ID environment variable!'}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?'You need to configure the AWS_SECRET_ACCESS_KEY environment variable!'}
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:?'You need to configure the AWS_DEFAULT_REGION environment variable!'}


### Verify ENV variables: AWS S3 Bucket
AWS_APP_S3=${AWS_APP_S3:?'You need to configure the AWS_APP_S3 environment variable with the S3 bucket you wish to sync assets to!'}


### Install AWS CLI
pip install awscli


### Push Assets to S3
aws s3 sync . s3://${AWS_APP_S3} --acl public-read --exclude "*" --include "*.css" --include "*.js" --include "*.gif" --include "*.png" --include "*.jpg" --include "*.ico" --include "*.svg" --include "*.ttf" --include "*.otf" --include "*.woff" --include "*.eot" --include "*.less" --include "*.xml"
