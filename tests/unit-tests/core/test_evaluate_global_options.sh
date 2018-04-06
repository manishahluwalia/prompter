#!/bin/bash

. `dirname $0`/../../../src/core.sh

. `dirname $0`/../harness.sh

# Setup mocks
function prompter_module_usage()
{
  record_call prompter_module_usage "$@"
}
function prompter_usage()
{
  record_call prompter_usage "$@"
}
function prompter_list_modules()
{
  record_call prompter_list_modules "$@"
}


# Tests


function test_no_args()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1
  prompter_shell=zsh


  # Setup expectations Phase
  # None


  # Run test Phase
  prompter_evaluate_global_options 


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"0"' '"$?"'
  ${_ASSERT_EQUALS_} '"incorrect # of arguments processed: \$prompter_numArgsGlobalOptions not correct"' 0 '"$prompter_numArgsGlobalOptions"'
  ${_ASSERT_EQUALS_} '"incorrect value of \$prompter_hide_from_shell_template"' '$PROMPTER_ZSH_HIDE_FROM_SHELL_TEMPLATE' '$prompter_hide_from_shell_template'
  verify_expectations
}

function test_no_global_args()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1
  prompter_shell=bash


  # Setup expectations Phase
  # None


  # Run test Phase
  prompter_evaluate_global_options "first $RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"0"' '"$?"'
  ${_ASSERT_EQUALS_} '"incorrect # of arguments processed: \$prompter_numArgsGlobalOptions not correct"' 0 '"$prompter_numArgsGlobalOptions"'
  ${_ASSERT_EQUALS_} '"incorrect value of \$prompter_hide_from_shell_template"' '$PROMPTER_BASH_HIDE_FROM_SHELL_TEMPLATE' '$prompter_hide_from_shell_template'
  verify_expectations
}

function test_shell()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1
  prompter_shell=bash


  # Setup expectations Phase
  # None


  # Run test Phase
  prompter_evaluate_global_options --shell zsh "first $RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"0"' '"$?"'
  ${_ASSERT_EQUALS_} '"incorrect # of arguments processed: \$prompter_numArgsGlobalOptions not correct"' 2 '"$prompter_numArgsGlobalOptions"'
  ${_ASSERT_EQUALS_} '"incorrect value of \$prompter_hide_from_shell_template"' '$PROMPTER_ZSH_HIDE_FROM_SHELL_TEMPLATE' '$prompter_hide_from_shell_template'
  verify_expectations
}

function test_invalid_default_shell()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1
  prompter_shell="date \$RANDOM"


  # Setup expectations Phase
  expect_call warn "Shell $SHELL is not supported. Expect peculiar behavior."


  # Run test Phase
  prompter_evaluate_global_options "first $RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"0"' '"$?"'
  ${_ASSERT_EQUALS_} '"incorrect # of arguments processed: \$prompter_numArgsGlobalOptions not correct"' 0 '"$prompter_numArgsGlobalOptions"'
  ${_ASSERT_EQUALS_} '"incorrect value of \$prompter_hide_from_shell_template"' '$PROMPTER_PLAIN_HIDE_FROM_SHELL_TEMPLATE' '$prompter_hide_from_shell_template'
  verify_expectations
}

function test_invalid_provided_shell()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1
  prompter_shell=bash


  # Setup expectations Phase
  expect_call fatal "Shell must be bash or zsh. date \$RANDOM is not supported"


  # Run test Phase
  prompter_evaluate_global_options --shell "date \$RANDOM" "first $RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"2"' '"$?"'
  # We're supposed to exit when we get a return value of 2, so it wouldn't be correct to look at other values
  verify_expectations
}

function test_help()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1


  # Setup expectations Phase
  expect_call prompter_usage

  # Run test Phase
  prompter_evaluate_global_options --help

  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"1"' '"$?"'
  verify_expectations
}

function test_help_module()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1


  # Setup expectations Phase
  expect_call prompter_module_usage "date \$RANDOM"

  # Run test Phase
  prompter_evaluate_global_options --help "date \$RANDOM"

  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"1"' '"$?"'
  verify_expectations
}

function test_list_modules()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1


  # Setup expectations Phase
  expect_call prompter_list_modules

  # Run test Phase
  prompter_evaluate_global_options --list-modules --help "date \$RANDOM"

  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"1"' '"$?"'
  verify_expectations
}

function test_terminal_bg_color()
{
  # Initialization Phase
  initialize_expectations
  OPTIND=1
  prompter_shell=zsh


  # Setup expectations Phase
  # None


  # Run test Phase
  prompter_evaluate_global_options --terminal-bg 713 "first $RANDOM arg" date


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_evaluate_global_options had incorrect return value"' '"0"' '"$?"'
  ${_ASSERT_EQUALS_} '"incorrect # of arguments processed: \$prompter_numArgsGlobalOptions not correct"' 2 '"$prompter_numArgsGlobalOptions"'
  ${_ASSERT_EQUALS_} '"incorrect value of terminal-bg"' 713 '"$prompter_terminal_bg_color"'
  verify_expectations
}

SHUNIT_PARENT=$0 ; . $SHUNIT