#!/bin/bash
# Modify the robots.txt during deployment
#
# Add the following environment variables to your project configuration.
# * ENVIRONMENT             - Type of environment: dev, staging, or prod
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/deploy/robots.txt.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/deploy/robots.txt.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e


### Verify ENV variables
ENVIRONMENT=${ENVIRONMENT:?'You need to configure the ENVIRONMENT environment variable! (dev, staging, or prod)'}


### Ammend Robots.txt to disallow all robots (unless production)
if [ "${ENVIRONMENT}" = "prod" ]
then
    echo -e "Not editing robots.txt on Prod"
else
    echo -e "\nUser-agent: *\nDisallow: /" >> robots.txt
fi
