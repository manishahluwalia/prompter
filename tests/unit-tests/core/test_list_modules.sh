#!/bin/bash

. `dirname $0`/../../../src/core.sh

. `dirname $0`/../harness.sh

function oneTimeSetUp
{
  :
}

function oneTimeTearDown
{
  :
}

function setUp
{
  :
}

function tearDown
{
  :
}


# Test modules
function prompter_mod_mod_1_main()
{
  ${_ASSERT_FALSE_} '"Should not be called"' 0
}
function prompter_mod_mod_1_usage()
{
  ${_ASSERT_FALSE_} '"Should not be called"' 0
}
function prompter_mod_mod_1_short_desc()
{
  echo "Description of mod-1"
}
function prompter_mod_date_main()
{
  ${_ASSERT_FALSE_} '"Should not be called"' 0
}
function prompter_mod_date_usage()
{
  ${_ASSERT_FALSE_} '"Should not be called"' 0
}
function prompter_mod_date_short_desc()
{
  echo "Description of date"
}


# Tests!

function test_empty_list_modules()
{
  # Initialization Phase
  initialize_expectations

  # No modules registered
  prompter_modules=()

  # Setup expectations Phase
  # Nothing expected

  
  # Run test Phase
  prompter_list_modules


  # Verify expectations Phase
  verify_expectations
}

function test_list_one_module()
{
  # Initialization Phase
  initialize_expectations

  # Register a module
  prompter_modules=(mod-1)


  # Setup expectations Phase
  expect_call printf "%-15s %s\n" mod-1 "Description of mod-1"


  # Run test Phase
  prompter_list_modules


  # Verify expectations Phase
  verify_expectations
}

function test_list_two_modules()
{
  # Initialization Phase
  initialize_expectations

  # Register 2 modules
  prompter_modules=(mod-1 date)


  # Setup expectations Phase
  expect_call printf "%-15s %s\n" mod-1 "Description of mod-1"
  expect_call printf "%-15s %s\n" date "Description of date"


  # Run test Phase
  prompter_list_modules


  # Verify expectations Phase
  verify_expectations
}

SHUNIT_PARENT=$0 ; . $SHUNIT