#!/bin/bash
# Run Grunt build tasks
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/grunt.sh | bash -s


### Fail the deployment on the first error
set -e


### Install Grunt (if necessary)
npm install -g grunt-cli


### Compile Assets
grunt compile --verbose


### Clean Build Artifacts that don't need to be deployed
rm -rf Gruntfile.js
