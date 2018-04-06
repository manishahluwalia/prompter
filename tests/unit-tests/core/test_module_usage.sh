#!/bin/bash

. `dirname $0`/../../../src/core.sh

. `dirname $0`/../harness.sh


# Test modules
function prompter_mod_mod1_main()
{
  ${_ASSERT_FALSE_} '"Should not be called"' 0
}
function prompter_mod_mod1_usage()
{
  record_call mod1_usage
}
function prompter_mod_mod1_short_desc()
{
  ${_ASSERT_FALSE_} '"Should not be called"' 0
}
function prompter_mod_mod2_main()
{
  ${_ASSERT_FALSE_} '"Should not be called"' 0
}
function prompter_mod_mod2_usage()
{
  record_call mod2_usage
}
function prompter_mod_mod2_short_desc()
{
  ${_ASSERT_FALSE_} '"Should not be called"' 0
}


# Tests!

function test_module_usage_no_modules()
{
  # Initialization Phase
  initialize_expectations

  # No modules registered
  prompter_modules=()

  # Setup expectations Phase
  expect_call fatal "No such module of name modX"

  
  # Run test Phase
  prompter_module_usage "modX"

  # Verify expectations Phase
  verify_expectations
}

function test_module_usage_one_module()
{
  # Initialization Phase
  initialize_expectations

  # Register a module
  prompter_modules=(mod1)


  # Setup expectations Phase
  expect_call mod1_usage


  # Run test Phase
  prompter_module_usage "mod1"


  # Verify expectations Phase
  verify_expectations
}

function test_module_usage_two_modules()
{
  # Initialization Phase
  initialize_expectations

  # Register 2 modules
  prompter_modules=(mod1 mod2)


  # Setup expectations Phase
  expect_call mod1_usage


  # Run test Phase
  prompter_module_usage "mod1"


  # Verify expectations Phase
  verify_expectations
}

SHUNIT_PARENT=$0 ; . $SHUNIT