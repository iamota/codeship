#!/bin/bash
# Install depedencies with NPM
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/npm.sh | bash -s


echo -e "\e[100m=================================================================================================="
echo -e "\e[100m/setup/npm.sh"
echo -e "\e[100m=================================================================================================="


### Install NPM
npm -g install npm@latest


### Install NPM Packages
echo -e "\e[100mInstall NPM Packages..."
npm install


### Clean Build Artifacts that don't need to be deployed
rm -rf package.json
rm -rf node_modules
