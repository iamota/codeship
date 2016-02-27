#!/bin/bash
# Clean Build Artifacts that don't need to be deployed
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/clean.sh | bash -s


### Fail the deployment on the first error
set -e


### Clean Git
git clean -fd
rm -rf .git
rm -rf .gitignore


### Clean Composer
rm -rf composer.*


### Clean NPM
rm -rf package.json
rm -rf node_modules


### Clean Bower
rm -rf bower.*
rm -rf .bowerrc


### Clean Grunt
rm -rf Gruntfile.js


### Clean VMs
rm -rf Vagrantfile
rm -rf puphpet
