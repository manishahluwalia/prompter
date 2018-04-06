#!/bin/bash

. `dirname $0`/../../../src/core.sh

. `dirname $0`/../harness.sh

function test_is_function()
{
  prompter_is_function prompter_is_function
  ${_ASSERT_TRUE_} '"prompter_is_function is a function"' $?

  prompter_is_function function
  ${_ASSERT_FALSE_} '"function is not a function"' $?

  prompter_is_function bash
  ${_ASSERT_FALSE_} '"bash is not a function"' $?

  prompter_is_function some_undefined_thing
  ${_ASSERT_FALSE_} '"an undefined identifier is not a function"' $?

  prompter_is_function 0
  ${_ASSERT_FALSE_} '"a number is not a function"' $?

  prompter_is_function 1
  ${_ASSERT_FALSE_} '"a number is not a function"' $?

  prompter_is_function "hello"
  ${_ASSERT_FALSE_} '"a string is not a function"' $?

  prompter_is_function ""
  ${_ASSERT_FALSE_} '"a string is not a function"' $?

  prompter_is_function
  ${_ASSERT_FALSE_} '"undefined is not a function"' $?
}

function test_friendlyName_to_symbolicName()
{
  ${_ASSERT_EQUALS_} '""' '"$(prompter_friendlyName_to_symbolicName "")"'
  ${_ASSERT_EQUALS_} '"foobar"' '"$(prompter_friendlyName_to_symbolicName foobar)"'
  ${_ASSERT_EQUALS_} '"foo_bar"' '"$(prompter_friendlyName_to_symbolicName foo_bar)"'
  ${_ASSERT_EQUALS_} '"_foo_bar"' '"$(prompter_friendlyName_to_symbolicName _foo_bar)"'
  ${_ASSERT_EQUALS_} '"_"' '"$(prompter_friendlyName_to_symbolicName -)"'
  ${_ASSERT_EQUALS_} '"foo_bar"' '"$(prompter_friendlyName_to_symbolicName foo-bar)"'
  ${_ASSERT_EQUALS_} '"_foo"' '"$(prompter_friendlyName_to_symbolicName -foo)"'
  ${_ASSERT_EQUALS_} '"foo_"' '"$(prompter_friendlyName_to_symbolicName foo-)"'
  ${_ASSERT_EQUALS_} '"_a_long_name_"' '"$(prompter_friendlyName_to_symbolicName -a-long-name-)"'
}

export SHUNIT_PARENT=$0 ; . $SHUNIT