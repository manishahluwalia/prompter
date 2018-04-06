#!/bin/bash

. `dirname $0`/../../../src/core.sh

. `dirname $0`/../harness.sh

# Setup mocks
prompter_mod_first_module_options=(foo bar:)
function prompter_mod_first_module_main()
{
  record_call first-module "$prompter_fg_color" "$prompter_bg_color" "$prompter_mod_first_module_arg_foo" "$prompter_mod_first_module_arg_bar" -- "$@"
}

prompter_mod_second_module_options=(long-hypenated-arg:)
function prompter_mod_second_module_main()
{
  record_call second-module "$prompter_fg_color" "$prompter_bg_color" "$prompter_mod_second_module_arg_long_hyphenated_arg" -- "$@"
}

function prompter_mod_third_module_options()
{
  record_call third-module "$prompter_fg_color" "$prompter_bg_color" -- "$@"
}

# Tests


function test_no_modules()
{
  # Initialization Phase
  initialize_expectations


  # Setup expectations Phase
  # None


  # Run test Phase
  prompter_drive_modules


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_bad_module_in_begining()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call fatal "Unknown module no-such-module"


  # Run test Phase
  prompter_drive_modules no-such-module :: first-module


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"2"' '"$?"'
  verify_expectations
}

function test_bad_module_at_end()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module 71 "$PROMPTER_DEFAULT_BG_COLOR" "" "true \$RANDOM" -- "false \$RANDOM" "ls -a \$RANDOM"
  expect_call fatal "Unknown module no-such-module"


  # Run test Phase
  prompter_drive_modules first-module --fg 71 --bar "true \$RANDOM" "false \$RANDOM" "ls -a \$RANDOM" :: no-such-module


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"2"' '"$?"'
  verify_expectations
}

function test_one_module()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module 71 "$PROMPTER_DEFAULT_BG_COLOR" "" "true \$RANDOM" -- "false \$RANDOM" "ls -a \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module --fg 71 --bar "true \$RANDOM" "false \$RANDOM" "ls -a \$RANDOM"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_no_args()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module "$PROMPTER_DEFAULT_FG_COLOR" "$PROMPTER_DEFAULT_BG_COLOR" "" "" --


  # Run test Phase
  prompter_drive_modules first-module


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_one_pos_arg()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module "$PROMPTER_DEFAULT_FG_COLOR" "$PROMPTER_DEFAULT_BG_COLOR" "" "" -- "false \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module "false \$RANDOM"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_two_pos_args()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module "$PROMPTER_DEFAULT_FG_COLOR" "$PROMPTER_DEFAULT_BG_COLOR" "" "" -- "false \$RANDOM" "ls -a \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module "false \$RANDOM" "ls -a \$RANDOM"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_boolean_option()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module "$PROMPTER_DEFAULT_FG_COLOR" "$PROMPTER_DEFAULT_BG_COLOR" "true" "" --


  # Run test Phase
  prompter_drive_modules first-module --foo


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_valued_option()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module "$PROMPTER_DEFAULT_FG_COLOR" "$PROMPTER_DEFAULT_BG_COLOR" "" "ls / \$RANDOM" --


  # Run test Phase
  prompter_drive_modules first-module --bar "ls / \$RANDOM"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_empty_valued_option()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module "$PROMPTER_DEFAULT_FG_COLOR" "$PROMPTER_DEFAULT_BG_COLOR" "" "" --


  # Run test Phase
  prompter_drive_modules first-module --bar ""


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_missing_valued_option()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call fatal "Argument bar for module first-module needs a value"


  # Run test Phase
  prompter_drive_modules first-module --bar


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"2"' '"$?"'
  verify_expectations
}

function test_bad_option()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call fatal "Module first-module has no argument named bum"


  # Run test Phase
  prompter_drive_modules first-module --bum


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"2"' '"$?"'
  verify_expectations
}

function test_double_hyphen_terminates_option_processing()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module 71 "$PROMPTER_DEFAULT_BG_COLOR" "" "" -- --bar "true \$RANDOM" "false \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module --fg 71 -- --bar "true \$RANDOM" "false \$RANDOM"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_two_modules()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module 71 "$PROMPTER_DEFAULT_BG_COLOR" "" "true \$RANDOM" -- "false \$RANDOM"
  expect_call second-module "$PROMPTER_DEFAULT_FG_COLOR" "$PROMPTER_DEFAULT_BG_COLOR" "" -- "false \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module --fg 71 --bar "true \$RANDOM" "false \$RANDOM" :: second-module "false \$RANDOM"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_reset_between_two_calls()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)


  # Setup expectations Phase
  expect_call first-module 71 "$PROMPTER_DEFAULT_BG_COLOR" "true" "true \$RANDOM" -- "false \$RANDOM"
  expect_call first-module "$PROMPTER_DEFAULT_FG_COLOR" "$PROMPTER_DEFAULT_BG_COLOR" "" "" -- "false \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module --fg 71 --foo --bar "true \$RANDOM" "false \$RANDOM" :: first-module "false \$RANDOM"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_module_color_overrides_default_color()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)
  
  # Simulate module color preference
  prompter_mod_first_module_default_fg_color=324232
  prompter_mod_first_module_default_bg_color=2736472

  # Setup expectations Phase
  expect_call first-module "$prompter_mod_first_module_default_fg_color" "$prompter_mod_first_module_default_bg_color" "true" "true \$RANDOM" -- "false \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module --foo --bar "true \$RANDOM" "false \$RANDOM"
 
  # Remove simulated module colors
  unset prompter_mod_first_module_default_fg_color
  unset prompter_mod_first_module_default_bg_color

  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_explicit_color_overrides_module_color()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)
  
  # Simulate module color preference
  prompter_mod_first_module_default_fg_color=324232
  prompter_mod_first_module_default_bg_color=2736472

  # Setup expectations Phase
  expect_call first-module "97297" "2342" "true" "true \$RANDOM" -- "false \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module --bg 2342 --fg 97297 --foo --bar "true \$RANDOM" "false \$RANDOM"


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}

function test_explicit_color_overrides_default_color()
{
  # Initialization Phase
  initialize_expectations
  PROMPTER_DEFAULT_FG_COLOR=79879
  PROMPTER_DEFAULT_BG_COLOR=23432
  prompter_modules=(first-module second-module third-module)
  
  # Setup expectations Phase
  expect_call first-module "97297" "2342" "true" "true \$RANDOM" -- "false \$RANDOM"


  # Run test Phase
  prompter_drive_modules first-module --bg 2342 --fg 97297 --foo --bar "true \$RANDOM" "false \$RANDOM"
 

  # Remove simulated module colors
  unset prompter_mod_first_module_default_fg_color
  unset prompter_mod_first_module_default_bg_color


  # Verify expectations Phase
  ${_ASSERT_EQUALS_} '"prompter_drive_modules had incorrect return value"' '"0"' '"$?"'
  verify_expectations
}


SHUNIT_PARENT=$0 ; . $SHUNIT