<?php

use Behat\Step\Then;
use Behat\MinkExtension\Context\RawMinkContext;

/**
 * Steps that wait for the browser instead of checking the page only once.
 */
class FeatureContext extends RawMinkContext {

  /**
   * Waits for a visible link, so a page still loading doesn't fail the test.
   */
  #[Then('I should eventually see the link :link')]
  public function assertLinkEventuallyVisible(string $link): void {
    $page = $this->getSession()->getPage();
    $found = $page->waitFor(10, function () use ($page, $link) {
      try {
        $result = $page->findLink($link);
        return $result && $result->isVisible();
      }
      catch (\Exception) {
        // The element can go stale while the page is navigating; retry.
        return FALSE;
      }
    });
    if (!$found) {
      throw new \Exception(sprintf("No link to '%s' on the page %s after waiting 10 seconds", $link, $this->getSession()->getCurrentUrl()));
    }
  }

}
