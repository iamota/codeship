#!/bin/bash
# Run Grunt build tasks
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/grunt.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/setup/grunt.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e


### Install Grunt
echo -e "\e[1;40;32mInstall Grunt..."
npm install -g grunt-cli


### Run Grunt
echo -e "\e[1;40;32mRun Grunt..."
grunt compile --target=dist --verbose


### Clean Build Artifacts that don't need to be deployed
echo -e "\e[1;40;32mCleanup Grunt..."
rm -rf Gruntfile.js
