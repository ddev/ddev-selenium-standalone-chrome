[![tests](https://github.com/ddev/ddev-selenium-standalone-chrome/actions/workflows/tests.yml/badge.svg)](https://github.com/ddev/ddev-addon-template/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

## Introduction

This service can be used with any project type. The examples below are Drupal-specific. Contributions for docs and tests that show this service working with other project types are appreciated.

## Install/Update

1. `ddev get ddev/ddev-selenium-standalone-chrome`
2. Optional. Update the provided .ddev/config.selenium-standalone-chrome.yaml as you see fit(and remove the #ddev-generated line). You can also just override lines in your .ddev/config.yaml
3. Optional. Check config.selenium-standalone-chrome.yaml and docker-compose.selenium-chrome.yaml into your source control.
4. Update by re-running `ddev get ddev/ddev-selenium-standalone-chrome`.

## Use

- Your project is now ready to run FunctionalJavascript and [Nightwatch](https://www.drupal.org/docs/automated-testing/javascript-testing-using-nightwatch) tests from Drupal core, or [Drupal Test Traits](https://gitlab.com/weitzman/drupal-test-traits) (DTT). All these types are tested in this repo. Some examples to try:
  - FunctionalJavascript:
    - Ensure you have the `drupal/core-dev` Composer package or equivalent.
    - `ddev exec -d /var/www/html/web "../vendor/bin/phpunit -v -c ./core/phpunit.xml.dist ./core/modules/system/tests/src/FunctionalJavascript/FrameworkTest.php"`
  - Nightwatch
    - `ddev exec -d /var/www/html/web/core yarn install` (do this once)
    - `ddev exec -d /var/www/html/web/core touch .env` (do this once)
    - `ddev exec -d /var/www/html/web/core yarn test:nightwatch tests/Drupal/Nightwatch/Tests/exampleTest.js`
  - Drupal Test Traits
    - Ensure you have a working site that has the `weitzman/drupal-test-traits` Composer package.
    - `ddev exec -d /var/www/html/web "../vendor/bin/phpunit --bootstrap=../vendor/weitzman/drupal-test-traits/src/bootstrap-fast.php --printer '\Drupal\Tests\Listeners\HtmlOutputPrinter' ../vendor/weitzman/drupal-test-traits/tests/ExampleSelenium2DriverTest.php"`

## Watching the tests

### The easy way: Use noVNC (built-in)

On your host, browse to https://[DDEV SITE URL]:7900 (password: `secret`) to watch tests run with noVNC (neat!).

This is a no-configuration solution that enables you to quickly see what is going on with your tests.

### Use a local VNC client (try noVNC first!)

If you are using something like behat and want to debug tests when they fail by manually navigating around your site in the Chromium browser included with this addon, you might want to use a VNC client installed on your machine, such as Screen Sharing on macOS (built-in) or TightVNC on Linux and Windows (must be downloaded and installed). This is because with noVNC, you are running a browser (Chromium) inside another browser (whatever browser you use on your local machine), which can be inconvenient-- for example, the keyboard shortcut to reload a page in Chromium will reload your local browser and kick you out of noVNC instead of reloading Chromium, and it may be hard to type a new url in the Chromium address bar due to how your local browser handles keyboard input.

In other words, if you just want to watch the tests, use noVNC.

If you want to use the browser provided by this addon to check out the test results by poking around your site, consider using a local VNC client. To do so, you need to open port 5900.

#### How to open port 5900 for VNC access

1. Open `.ddev/docker-compose.selenium-chrome.yaml`.
2. Uncomment the two lines about `ports` and `5900:5900`.
3. Execute `ddev restart`.

You can now connect to [DDEV SITE URL]:5900 (password: `secret`) in your VNC client.

Note that when using `ports`, only one project at a time can be running with port 5900.

### Behat config example

If you use Behat as a test running, adjust your `behat.yml`

```yml
  extensions:
    Behat\MinkExtension:
      base_url: http://web
      selenium2:
        wd_host: http://selenium-chrome:4444/wd/hub
        capabilities:
          chrome:
            switches:
              - "--disable-gpu"
              - "--headless"
              - "--no-sandbox"
              - "--disable-dev-shm-usage"
```

## Contribute

- Anyone is welcome to submit a PR to this repo. See README.md at https://github.com/ddev/ddev-addon-template, the parent of this repo.

## Maintainer

- Contributed and maintained by [@weitzman](https://github.com/weitzman).
