#!/bin/bash

. `dirname $0`/../../../src/core.sh

. `dirname $0`/../harness.sh

# Mock 'echo', using the wrapper we use for testability
function _prompter_echo_wrapper
{
  record_call _prompter_echo_wrapper "$@"
}

function test_simple_message()
{
  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  expect_call _prompter_echo_wrapper "LEVEL: A message \$RANDOM"

  # Run test Phase
  _prompter_log_message "LEVEL" "A message \$RANDOM"


  # Verify expectations Phase
  verify_expectations
}

function test_message_from_module()
{
  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  expect_call _prompter_echo_wrapper "LEVEL: Module foo-bar: A message \$RANDOM"
  expect_call _prompter_echo_wrapper "LEVEL: Module a-module: Another message \$RANDOM"

  # Run test Phase
  prompter_executing_module="foo-bar"
  _prompter_log_message "LEVEL" "A message \$RANDOM"

  prompter_executing_module="a-module"
  _prompter_log_message "LEVEL" "Another message \$RANDOM"


  # Verify expectations Phase
  verify_expectations
}



SHUNIT_PARENT=$0 ; . $SHUNIT