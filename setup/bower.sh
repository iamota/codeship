#!/bin/bash
# Install depedencies with Bower
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/bower.sh | bash -s


echo -e "\e[100m=================================================================================================="
echo -e "\e[100m/setup/bower.sh"
echo -e "\e[100m=================================================================================================="


### Fail the deployment on the first error
set -e


### Cache Bower Dependencies
echo -e "\e[100mCache Bower Dependencies..."
curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/cache/bower.sh | bash


### Install Bower (if necessary)
echo -e "\e[100mInstall Bower..."
npm install -g bower


### Install Bower Packages
echo -e "\e[100mInstall Bower Packages..."
bower install


### Clean Build Artifacts that don't need to be deployed
echo -e "\e[100mCleanup Bower..."
rm -rf bower.*
rm -rf .bowerrc
