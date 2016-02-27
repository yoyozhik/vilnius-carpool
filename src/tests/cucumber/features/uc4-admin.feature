Feature: 4.1 Login as admin
  As an admin
  I want to create/read/update/delete stop
  So that these stops would be used as meeting points

  Background: Admin account exists
    Given Admin exists

  Scenario: Admin should see langing page
    Given Login with "admin@tiktai.lt"
    And I see ".stops" in "/admin"

  Scenario: Not Admin shouldn't see langing page
    Given Login with "user1@tiktai.lt"
    And I see ".noPermission" in "/admin"