#!/bin/bash
# Install depedencies with NPM
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/npm.sh | bash -s


### Install NPM Packages
#npm install -g npm
#npm install -g vinyl-fs@2.2.1
npm install


### Clean Build Artifacts that don't need to be deployed
rm -rf package.json
rm -rf node_modules
