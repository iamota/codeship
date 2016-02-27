#!/bin/bash
# Configure Codeship's PHP Environment
#
# Add the following environment variables to your project configuration.
# * PHP_VERSION
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/php.sh | bash -s


### Fail the deployment on the first error
set -e


### Verify ENV variables
PHP_VERSION=${PHP_VERSION:?'You need to configure the PHP_VERSION environment variable! (e.g. 5.5 or 5.6)'}


### Set ENV Variables
phpenv local $PHP_VERSION
export PHP_INI="${HOME}/.phpenv/versions/${PHP_VERSION}/etc/php.ini"


### Disable PHP XDebug (helps compile faster)
#cat $PHP_INI
sed -i "s/zend_extension=.*\/xdebug.so/;xdebug disabled/" $PHP_INI
sed -i "s/xdebug.remote_autostart=.*/xdebug.remote_autostart=0/" $PHP_INI
sed -i "s/xdebug.remote_enable=.*/xdebug.remote_enable=0/" $PHP_INI
sed -i "s/xdebug.profiler_enable=.*/xdebug.profiler_enable=0/" $PHP_INI
sed -i "$ a xdebug.remote_autostart=0" $PHP_INI
sed -i "$ a xdebug.remote_enable=0" $PHP_INI
sed -i "$ a xdebug.profiler_enable=0" $PHP_INI
#cat $PHP_INI
