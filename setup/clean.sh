#!/bin/bash
# Clean Build Artifacts that don't need to be deployed
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/clean.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/setup/clean.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e


### Clean Git
echo -e "\e[1;40;32mCleanup Git..."
git clean -fd
rm -rf .git
rm -rf .gitignore
rm -rf .gitattributes


### Clean Composer
echo -e "\e[1;40;32mCleanup Composer..."
rm -rf composer.*


### Clean NPM
echo -e "\e[1;40;32mCleanup NPM..."
rm -rf package.json
rm -rf node_modules


### Clean Bower
echo -e "\e[1;40;32mCleanup Bower..."
rm -rf bower.*
rm -rf .bowerrc


### Clean Grunt
echo -e "\e[1;40;32mCleanup Grunt..."
rm -rf Gruntfile.js


### Clean VMs
echo -e "\e[1;40;32mCleanup VMs..."
rm -rf Vagrantfile
rm -rf puphpet
