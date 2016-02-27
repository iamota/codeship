#!/bin/bash
# Install dependencies with Composer
#
# Add the following environment variables to your project configuration.
# * GITHUB_ACCESS_TOKEN
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/composer.sh | bash -s


### Fail the deployment on the first error
set -e


### Verify ENV variables
GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN:?'You need to configure the GITHUB_ACCESS_TOKEN environment variable! (https://help.github.com/articles/creating-an-access-token-for-command-line-use/)'}


### Install Composer Packages
export COMPOSER_HOME="${HOME}/cache/composer"
composer config -g github-oauth.github.com $GITHUB_ACCESS_TOKEN
composer install --prefer-dist --no-interaction --no-dev


### Clean Build Artifacts that don't need to be deployed
rm -rf composer.*
