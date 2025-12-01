[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/ddev/ddev-selenium-standalone-chrome/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/ddev/ddev-selenium-standalone-chrome/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/ddev/ddev-selenium-standalone-chrome)](https://github.com/ddev/ddev-selenium-standalone-chrome/commits)
[![release](https://img.shields.io/github/v/release/ddev/ddev-selenium-standalone-chrome)](https://github.com/ddev/ddev-selenium-standalone-chrome/releases/latest)

# DDEV Selenium Standalone Chrome

## Overview

Makes it easy to run Functional, FunctionalJavascript, and Nightwatch tests in DDEV.

This service can be used with any project type. The examples below are Drupal-specific. Contributions for docs and tests that show this service working with other project types are appreciated.

## Installation

```bash
ddev add-on get ddev/ddev-selenium-standalone-chrome
ddev restart
```
Functional and FunctionalJavascript tests require the `drupal/core-dev` Composer package or equivalent:
```bash
ddev composer require drupal/core-dev
```

> [!NOTE]
> Run `ddev add-on get ddev/ddev-selenium-standalone-chrome` after changes to `name`, `additional_hostnames`, `additional_fqdns`, or `project_tld` in `.ddev/config.yaml` so that `.ddev/docker-compose.selenium-chrome_extras.yaml` is regenerated.

After installation, make sure to commit the `.ddev` directory to version control.

### Optional steps

1. Update the provided `.ddev/config.selenium-standalone-chrome.yaml` as you see fit (and remove the #ddev-generated line). You can also just override lines in your `.ddev/config.yaml`
1. Check `config.selenium-standalone-chrome.yaml` and `docker-compose.selenium-chrome.yaml` into your source control.
1. Update by re-running `ddev add-on get ddev/ddev-selenium-standalone-chrome`.

## Usage

- Your project is now ready to run [Functional](https://mglaman.dev/blog/do-you-need-functional-test), FunctionalJavascript and [Nightwatch](https://www.drupal.org/docs/automated-testing/javascript-testing-using-nightwatch) tests from Drupal core, or [Drupal Test Traits](https://git.drupalcode.org/project/dtt) (DTT). Some examples to try:
  - Functional:
    - `ddev exec -d /var/www/html/web "../vendor/bin/phpunit -c ./core/phpunit.xml.dist ./core/modules/migrate/tests/src/Functional/process/DownloadFunctionalTest.php"`
  - FunctionalJavascript:
    - `ddev exec -d /var/www/html/web "../vendor/bin/phpunit -c ./core/phpunit.xml.dist ./core/modules/system/tests/src/FunctionalJavascript/FrameworkTest.php"`
  - Nightwatch
    - `ddev exec -d /var/www/html/web/core yarn install` (do this once)
    - `ddev exec -d /var/www/html/web/core touch .env` (do this once)
    - `ddev exec -d /var/www/html/web/core yarn test:nightwatch tests/Drupal/Nightwatch/Tests/exampleTest.js`
  - Drupal Test Traits
    - Ensure you have a working site that has the `weitzman/drupal-test-traits` Composer package.
    - `ddev exec -d /var/www/html/web "../vendor/bin/phpunit --bootstrap=../vendor/weitzman/drupal-test-traits/src/bootstrap-fast.php --printer '\Drupal\Tests\Listeners\HtmlOutputPrinter' ../vendor/weitzman/drupal-test-traits/tests/ExampleSelenium2DriverTest.php"`

## Watching the tests

### The easy way: Use noVNC (built-in)

1. Remove `--headless` from the `MINK_DRIVER_ARGS_WEBDRIVER` in your project's `.ddev/config.selenium-standalone-chrome.yaml`. Run `ddev restart`.
2. On your host, run `ddev launch :7900` or browse to `https://[DDEV SITE URL]:7900` to watch tests run with noVNC (neat!).

By default noVNC connects without password, you can enable password by removing the `VNC_NO_PASSWORD=1` line in the file `docker-compose.selenium-chrome.yaml`, the default password will be `secret`, and you can set the custom one via `VNC_PASSWORD` environment variable.

This enables you to quickly see what is going on with your tests.

### Use a local VNC client (try noVNC first!)

If you are using something like behat and want to debug tests when they fail by manually navigating around your site in the Chromium browser included with this addon, you might want to use a VNC client installed on your machine, such as Screen Sharing on macOS (built-in) or TightVNC on Linux and Windows (must be downloaded and installed). This is because with noVNC, you are running a browser (Chromium) inside another browser (whatever browser you use on your local machine), which can be inconvenient-- for example, the keyboard shortcut to reload a page in Chromium will reload your local browser and kick you out of noVNC instead of reloading Chromium, and it may be hard to type a new url in the Chromium address bar due to how your local browser handles keyboard input.

In other words, if you just want to watch the tests, use noVNC.

If you want to use the browser provided by this addon to check out the test results by poking around your site, consider using a local VNC client. To do so, you need to open port 5900.

#### How to open port 5900 for VNC access

1. Open `.ddev/docker-compose.selenium-chrome.yaml`.
2. Uncomment the two lines about `ports` and `5900:5900`.
3. Execute `ddev restart`.

You can now connect to `[DDEV SITE URL]:5900` (password: `secret`) in your VNC client.

Note that when using `ports`, only one project at a time can be running with port 5900.

### Behat config example

If you use Behat as a test running, adjust your `behat.yml`

```yaml
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

- Anyone is welcome to submit a PR to this repo. See [DDEV Add-on Maintenance Guide](https://ddev.com/blog/ddev-add-on-maintenance-guide/).

## Credits

Contributed and maintained by Moshe Weitzman ([@weitzman](https://github.com/weitzman)) and
Dezső BICZÓ  ([@mxr576](https://github.com/mxr576))
