#!/bin/bash
# Install depedencies with Bower
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/bower.sh | bash -s


### Fail the deployment on the first error
set -e


### Cache Bower dependencies
curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/cache/bower.sh | bash


### Install Bower (if necessary)
npm install -g bower


### Install Bower Packages
bower install


### Clean Build Artifacts that don't need to be deployed
rm -rf bower.*
rm -rf .bowerrc
