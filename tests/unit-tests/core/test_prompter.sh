#!/bin/bash

. `dirname $0`/../../../src/core.sh

. `dirname $0`/../harness.sh

# Declare mocks

function prompter_terminate_prompt()
{
  record_call prompter_terminate_prompt "$@"
}

# Tests!

function test_prompter_terminating_global_options()
{
  function prompter_evaluate_global_options
  {
    record_call prompter_evaluate_global_options "$@"
    return 1
  }

  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  expect_call prompter_evaluate_global_options "first \$RANDOM arg" "second \$RANDOM arg" date


  # Run test Phase
  prompter "first \$RANDOM arg" "second \$RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter had incorrect return value"' '"0"' '"$?"'
  verify_expectations
  unset -f prompter_evaluate_global_options
}

function test_prompter_shift_none()
{
  function prompter_evaluate_global_options
  {
    record_call prompter_evaluate_global_options "$@"
    prompter_numArgsGlobalOptions=0
    return 0
  }
  function prompter_drive_modules()
  {
    record_call prompter_drive_modules "$@"
    return 0
  }

  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  expect_call prompter_evaluate_global_options "first \$RANDOM arg" "second \$RANDOM arg" date
  expect_call prompter_drive_modules "first \$RANDOM arg" "second \$RANDOM arg" date
  expect_call prompter_terminate_prompt


  # Run test Phase
  prompter "first \$RANDOM arg" "second \$RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter had incorrect return value"' '"0"' '"$?"'
  verify_expectations
  unset -f prompter_evaluate_global_options
  unset -f prompter_drive_modules
}

function test_prompter_shift_two()
{
  function prompter_evaluate_global_options
  {
    record_call prompter_evaluate_global_options "$@"
    prompter_numArgsGlobalOptions=2
    return 0
  }
  function prompter_drive_modules()
  {
    record_call prompter_drive_modules "$@"
    return 0
  }

  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  expect_call prompter_evaluate_global_options "first \$RANDOM arg" "second \$RANDOM arg" date
  expect_call prompter_drive_modules date
  expect_call prompter_terminate_prompt


  # Run test Phase
  prompter "first \$RANDOM arg" "second \$RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter had incorrect return value"' '"0"' '"$?"'
  verify_expectations
  unset -f prompter_evaluate_global_options
  unset -f prompter_drive_modules
}

function test_prompter_shift_three()
{
  function prompter_evaluate_global_options
  {
    record_call prompter_evaluate_global_options "$@"
    prompter_numArgsGlobalOptions=3
    return 0
  }
  function prompter_drive_modules()
  {
    record_call prompter_drive_modules "$@"
    return 0
  }

  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  expect_call prompter_evaluate_global_options "first \$RANDOM arg" "second \$RANDOM arg" date
  expect_call prompter_drive_modules 
  expect_call prompter_terminate_prompt


  # Run test Phase
  prompter "first \$RANDOM arg" "second \$RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter had incorrect return value"' '"0"' '"$?"'
  verify_expectations
  unset -f prompter_evaluate_global_options
  unset -f prompter_drive_modules
}

function test_prompter_nothing_to_shift()
{
  function prompter_evaluate_global_options
  {
    record_call prompter_evaluate_global_options "$@"
    prompter_numArgsGlobalOptions=0
    return 0
  }
  function prompter_drive_modules()
  {
    record_call prompter_drive_modules "$@"
    return 0
  }

  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  expect_call prompter_evaluate_global_options
  expect_call prompter_drive_modules 
  expect_call prompter_terminate_prompt


  # Run test Phase
  prompter


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter had incorrect return value"' '"0"' '"$?"'
  verify_expectations
  unset -f prompter_evaluate_global_options
  unset -f prompter_drive_modules
}

function test_prompter_error_from_driver()
{
  function prompter_evaluate_global_options
  {
    record_call prompter_evaluate_global_options "$@"
    prompter_numArgsGlobalOptions=1
    return 0
  }
  function prompter_drive_modules()
  {
    record_call prompter_drive_modules "$@"
    return 1
  }

  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  expect_call prompter_evaluate_global_options "first \$RANDOM arg"
  expect_call prompter_drive_modules 
  expect_call prompter_terminate_prompt


  # Run test Phase
  prompter "first \$RANDOM arg"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter had incorrect return value"' '"1"' '"$?"'
  verify_expectations
  unset -f prompter_evaluate_global_options
  unset -f prompter_drive_modules
}

export SHUNIT_PARENT=$0 ; . $SHUNIT