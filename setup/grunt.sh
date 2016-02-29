#!/bin/bash
# Run Grunt build tasks
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/grunt.sh | bash -s


echo -e "\e[100m=================================================================================================="
echo -e "\e[100m/setup/grunt.sh"
echo -e "\e[100m=================================================================================================="


### Fail the deployment on the first error
set -e


### Install Grunt (if necessary)
echo -e "\e[100mInstall Grunt..."
npm install -g grunt-cli


### Run Grunt
echo -e "\e[100mRun Grunt..."
grunt compile --verbose


### Clean Build Artifacts that don't need to be deployed
echo -e "\e[100mCleanup Grunt..."
rm -rf Gruntfile.js
