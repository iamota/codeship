#!/bin/bash
# Install depedencies with NPM
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/npm.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/setup/npm.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Install NPM
echo -e "\e[1;40;32mInstall NPM..."
npm -g install npm@latest


### Install NPM Packages
echo -e "\e[1;40;32mInstall NPM Packages..."
npm install


### Don't Clean Build Artifacts (yet)
### They'll be needed to run Grunt, etc.
