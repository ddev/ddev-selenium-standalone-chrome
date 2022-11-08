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
  ddev describe
  # Do something here to verify functioning extra service
  # For extra credit, use a real CMS with actual config.
  ddev exec "curl -v selenium-chrome:4444/wd/hub/status"
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
