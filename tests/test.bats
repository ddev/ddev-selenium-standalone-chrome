setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/testchrome
  mkdir -p $TESTDIR
  export PROJNAME=testchrome
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  composer -n --no-install create-project 'drupal/recommended-project:^9' .
  composer -n config --no-plugins allow-plugins true
  composer -n require 'drupal/core-dev:^9' 'drush/drush:^11' 'phpspec/prophecy-phpunit:^2' 'weitzman/drupal-test-traits:2.0.0-rc1'
  ddev config --project-name=${PROJNAME} --php-version=8.1 --web-environment-add SYMFONY_DEPRECATIONS_HELPER=disabled
  ddev start -y >/dev/null
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  ddev exec ls
  ddev exec "curl -v selenium-chrome:4444/wd/hub/status"
  echo "Run a FunctionalJavascript test." >&3
  ddev exec -d /var/www/html/web "../vendor/bin/phpunit -v -c ./core/phpunit.xml.dist ./core/modules/system/tests/src/FunctionalJavascript/FrameworkTest.php"
  echo "Run a Nightwatch test." >&3
  ddev exec -d /var/www/html/web/core yarn install
  ddev exec -d /var/www/html/web/core touch .env
  ddev exec -d /var/www/html/web/core yarn test:nightwatch tests/Drupal/Nightwatch/Tests/exampleTest.js
  echo "Install Drupal and run a DTT test." >&3
  ddev exec -d /var/www/html/web "../vendor/bin/drush si -y --account-name=admin --account-pass=password standard"
  ddev exec -d /var/www/html/web "../vendor/bin/phpunit --log-junit dtt.junit.xml --bootstrap=../vendor/weitzman/drupal-test-traits/src/bootstrap-fast.php --printer '\Drupal\Tests\Listeners\HtmlOutputPrinter' ../vendor/weitzman/drupal-test-traits/tests/ExampleSelenium2DriverTest.php"
}
