#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=ddev/ddev-selenium-standalone-chrome

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  export SKIP_CLEANUP=1
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"

  composer -n --no-install create-project 'drupal/recommended-project:^10' .
  composer -n config --no-plugins allow-plugins true
  composer -n require 'drupal/core-dev:^10' 'drush/drush:^12' 'phpspec/prophecy-phpunit:^2' 'weitzman/drupal-test-traits:^2'

  run ddev config --project-name=${PROJNAME} --project-tld=ddev.site --php-version=8.1 --web-environment-add=SYMFONY_DEPRECATIONS_HELPER=disabled
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  run ddev exec curl -sfI selenium-chrome:4444/wd/hub/status
  assert_success
  assert_output --partial "HTTP/1.1 200 OK"

  run ddev exec curl -sf selenium-chrome:4444/wd/hub/status
  assert_success
  assert_output --partial "Selenium Grid ready."

  echo "Run a FunctionalJavascript test." >&3

  run ddev exec -d /var/www/html/web "../vendor/bin/phpunit -v -c ./core/phpunit.xml.dist ./core/modules/system/tests/src/FunctionalJavascript/FrameworkTest.php"
  assert_success

  echo "Ensure file uploads from browser works." >&3
  run ddev exec -d /var/www/html/web "../vendor/bin/phpunit -v -c ./core/phpunit.xml.dist ./core/modules/file/tests/src/FunctionalJavascript/FileManagedFileElementTest.php"
  assert_success

  echo "Run a Nightwatch test." >&3

  run ddev exec -d /var/www/html/web/core yarn install
  assert_success

  run ddev exec -d /var/www/html/web/core touch .env
  assert_success

  run ddev exec -d /var/www/html/web/core yarn test:nightwatch tests/Drupal/Nightwatch/Tests/jsOnceTest.js
  assert_success

  echo "Run a Nightwatch test that logs into Drupal." >&3

  run ddev exec -d /var/www/html/web/core yarn test:nightwatch tests/Drupal/Nightwatch/Tests/loginTest.js
  assert_success

  echo "Install Drupal and run a DTT test." >&3

  run ddev exec -d /var/www/html/web "../vendor/bin/drush si -y --account-name=admin --account-pass=password standard"
  assert_success

  run ddev exec -d /var/www/html/web "../vendor/bin/phpunit --log-junit dtt.junit.xml --bootstrap=../vendor/weitzman/drupal-test-traits/src/bootstrap-fast.php --printer '\Drupal\Tests\Listeners\HtmlOutputPrinter' ../vendor/weitzman/drupal-test-traits/tests/ExampleSelenium2DriverTest.php"
  assert_success
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ ! -z "${SKIP_CLEANUP}" ] || ( [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR} )
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}
