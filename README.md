[![tests](https://github.com/weitzman/ddev-selenium-standalone-chrome/actions/workflows/tests.yml/badge.svg)](https://github.com/drud/ddev-addon-template/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2022.svg)

## Introduction

In ddev v1.19+, run `ddev get weitzman/ddev-selenium-standalone-chrome` to fetch this service into your local DDEV installation. You may then check it into your source control if desired.

This service can be used with any project type. The examples below are Drupal-specific. Contributions for docs and tests that show this service working with other project types are appreciated.

## Use

- Your project is now ready to run FunctionalJavascript and [Nightwatch](https://www.drupal.org/docs/automated-testing/javascript-testing-using-nightwatch) tests from Drupal core, or [Drupal Test Traits](https://gitlab.com/weitzman/drupal-test-traits) (DTT). All these types are tested in this repo. Some examples to try:
  - FunctionalJavascript:
    - Ensure you have the `drupal/core-dev` Composer package or equivalent.
    - `ddev exec -d /var/www/html/web "../vendor/bin/phpunit -v -c ./core/phpunit.xml.dist ./core/modules/system/tests/src/FunctionalJavascript/FrameworkTest.php"`
  - Nightwatch
    - `ddev exec -d /var/www/html/web/core yarn install` (do this once)
    - `ddev exec -d /var/www/html/web/core touch .env` ((do this once))
    - `ddev exec -d /var/www/html/web/core yarn test:nightwatch tests/Drupal/Nightwatch/Tests/exampleTest.js`
  - Drupal Test Traits
    - Ensure you have a working site that has the `weitzman/drupal-test-traits` Composer package.
    - `ddev exec -d /var/www/html/web "../vendor/bin/phpunit --bootstrap=../vendor/weitzman/drupal-test-traits/src/bootstrap-fast.php --printer '\Drupal\Tests\Listeners\HtmlOutputPrinter' ../vendor/weitzman/drupal-test-traits/tests/ExampleSelenium2DriverTest.php"`
- On your host, browse to https://[DDEV SITE URL]:7900 (password: `secret`) to watch tests run (neat!).

## Contribute

- Anyone is welcome to submit a PR to this repo. See README.md at https://github.com/drud/ddev-addon-template, the parent of this repo.

## Maintainer

- Contributed and maintained by [@weitzman](https://github.com/weitzman).
