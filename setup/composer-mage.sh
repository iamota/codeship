#!/bin/bash
# Install dependencies with Composer
#
# Add the following environment variables to your project configuration.
# * GITHUB_ACCESS_TOKEN
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/composer.sh | bash -s


echo -e "\e[1;40;32m=================================================================================================="
echo -e "\e[1;40;32m/setup/composer.sh"
echo -e "\e[1;40;32m=================================================================================================="


### Fail the deployment on the first error
set -e


### Verify ENV variables
GITHUB_ACCESS_TOKEN=${GITHUB_ACCESS_TOKEN:?'You need to configure the GITHUB_ACCESS_TOKEN environment variable! (https://help.github.com/articles/creating-an-access-token-for-command-line-use/)'}
MAGENTO_PUBLIC_KEY=${MAGENTO_PUBLIC_KEY:?'You need to configure the MAGENTO_PUBLIC_KEY environment variable!'}
MAGENTO_PRIVATE_KEY=${MAGENTO_PRIVATE_KEY:?'You need to configure the MAGENTO_PRIVATE_KEY environment variable!'}

### Configure Composer
echo -e "\e[1;40;32mConfigure Composer..."
export COMPOSER_HOME="${HOME}/cache/composer"
composer config -g github-oauth.github.com $GITHUB_ACCESS_TOKEN
composer config -g http-basic.repo.magento.com $MAGENTO_PUBLIC_KEY $MAGENTO_PRIVATE_KEY

### Install Composer Packages
echo -e "\e[1;40;32mInstall Magento 2 Composer Packages..."
if [ -d "${MAGENTO_SUB_DIR}" ]; then
	echo - "\e[1;40;32mChanging to Mage dir: ${MAGENTO_SUB_DIR}"
	cd $MAGENTO_SUB_DIR
fi;
composer install --prefer-dist --no-interaction --no-dev


### Leaving Composer files on server
echo -e "\e[1;40;32mComposer files are NOT deleted..."
