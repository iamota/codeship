#!/bin/bash
# Run Webpack build tasks
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/webpack.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/setup/webpack.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e

### Run Webpack
echo -e "\e[1;40;32mRun Webpack..."
npm run-script build


### Clean Build Artifacts that don't need to be deployed
echo -e "\e[1;40;32mCleanup Webpack..."
rm -rf webpack.config.js
