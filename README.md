# Codeship
iamota's base Codeship Test &amp; Deployment Scripts (http://www.codeship.com).


## Test Settings

Paste the following into the **Setup Commands** section of your Codeship project. As required, customize the ENV variables:
- `PHP_VERSION` (e.g. 5.5, or 5.6)

```Shell
### Setup Environment Variables
export PHP_VERSION="5.5"
#
#
### Setup
curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/php.sh | bash -s
#
#
### Install Dependencies
curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/composer.sh | bash -s
curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/npm.sh | bash -s
curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/bower.sh | bash -s
#
#
### Build
curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/grunt.sh | bash -s
#
#
### Cleanup Build Artifacts
curl -sSL https://raw.githubusercontent.com/iamota/codeship/master/setup/clean.sh | bash -s
```
