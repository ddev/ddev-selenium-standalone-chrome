setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/testchrome
  mkdir -p $TESTDIR
  export PROJNAME=testchrome
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
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
  ddev exec "curl -v selenium-chrome:4444/wd/hub/status"
  # Fetch Drupal core and run a FunctionalJavascript test.
  composer create-project 'drupal/recommended-project:^9' my-project
  composer require --dev 'drupal/core-dev:^9'
  ddev exec -d /var/www/html/web "../vendor/bin/phpunit -v -c ./core/phpunit.xml.dist ./core/modules/system/tests/src/FunctionalJavascript/FrameworkTest.php"
}

@test "install from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get weitzman/ddev-selenium-standalone-chrome with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get weitzman/ddev-selenium-standalone-chrome
  ddev restart >/dev/null
  # Do something useful here that verifies the add-on
  ddev exec "curl -v selenium-chrome:4444/wd/hub/status"
}
