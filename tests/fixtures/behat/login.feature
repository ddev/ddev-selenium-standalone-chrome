@api @drupal
Feature: User login
  Background:
    Given users:
      | name       | mail                      | pass    |
      | test-usera | test-usera@localhost.test | test123 |
  Scenario: I'm on the login page and I login with the 'test-usera' user.
    Given I am an anonymous user
    Then I am on "/user/login"
    And I fill in the following:
      | name | test-usera |
      | pass | test123   |
    And I press the "Log in" button
    And I should see the link "Edit"
