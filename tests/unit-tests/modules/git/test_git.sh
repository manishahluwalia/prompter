#!/bin/bash

. `dirname $0`/../../harness.sh

. $SRC_DIR/modules/mod_git.sh

# Mocks
function prompter_mod_git_status()
{
  echo "$GIT_STATUS_OUTPUT"
  return $GIT_STATUS_EXIT_CODE
}

function prompter_mod_git_describe()
{
  echo "$GIT_DESCRIBE_OUTPUT"
  return $GIT_DESCRIBE_EXIT_CODE
}

function prompter_emit()
{
  record_call prompter_emit "$@"
}


# Helper functions
function expect_emit()
{
  text=$1
  color_name=$2
  eval expect_call prompter_emit \"\$text\" \"\$prompter_mod_git_arg_${color_name}_fg_color\" \"\$prompter_mod_git_arg_${color_name}_bg_color\"
}
function expect_symbol()
{
  symbol=$1
  color_name=$2
  eval expect_call prompter_emit \$PROMPTER_MOD_GIT_SYMBOL_${symbol} \$prompter_mod_git_arg_${color_name}_fg_color \$prompter_mod_git_arg_${color_name}_bg_color
}

# Some fake 'colors' so we can see that the correct one is being used.
# Pretend these were provided as module args, e.g. --clean-fg-color 25829
prompter_mod_git_arg_clean_fg_color=25829
prompter_mod_git_arg_clean_bg_color=13174
prompter_mod_git_arg_dirty_fg_color=14111
prompter_mod_git_arg_dirty_bg_color=3518
prompter_mod_git_arg_ahead_fg_color=30065
prompter_mod_git_arg_ahead_bg_color=1386
prompter_mod_git_arg_behind_fg_color=11127
prompter_mod_git_arg_behind_bg_color=18338
prompter_mod_git_arg_staged_fg_color=28616
prompter_mod_git_arg_staged_bg_color=25448
prompter_mod_git_arg_not_staged_fg_color=30928
prompter_mod_git_arg_not_staged_bg_color=13326
prompter_mod_git_arg_untracked_fg_color=17393
prompter_mod_git_arg_untracked_bg_color=16604
prompter_mod_git_arg_conflicted_fg_color=25109
prompter_mod_git_arg_conflicted_bg_color=28411

# Tests!

# These tests were generated as follows:
# Manually, a git repo was reated. Several operations were performed manually
# After each, the git status and git describe output was captured and stored
# These were used to create the skeletons for the tests, including the mocked
# values for the git outputs. The rest of the logic was then filled in by hand.
# The different git states created were saved as subdirs in a directory called
# 'saved-states', which contained a file with the output of git status and git
# describe.
#
# The code for generating the skeletons is:
#
#  $ ( cd saved-states ; ls -drt * | while read a ; do ; echo "
#  
#  function test_${a//-/_}()
#  {
#    # Initialization Phase
#    initialize_expectations
#    GIT_STATUS_OUTPUT="$(cat $a/git-status.out)"
#    GIT_STATUS_EXIT_CODE=0
#    GIT_DESCRIBE_OUTPUT="$(cat $a/git-describe.out)"
#    GIT_DESCRIBE_EXIT_CODE=0
#  
#  
#    # Setup expectations Phase
#    expect_emit master
#  
#    # Run test Phase
#    prompter_mod_git_main
#  
#  
#    # Verify expectations Phase
#    verify_expectations
#  
#  }
#  "
#  
#  done
#  )


function test_not_a_repo()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="fatal: Not a git repository (or any of the parent directories): .git"
  GIT_STATUS_EXIT_CODE=128
  GIT_DESCRIBE_OUTPUT="fatal: Not a git repository (or any of the parent directories): .git"
  GIT_DESCRIBE_EXIT_CODE=128


  # Setup expectations Phase
  # None!

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}

function test_fresh()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="93315e3"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}





function test_file_created()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master
?? foo"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="93315e3"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master dirty
  expect_symbol UNTRACKED untracked

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_file_added()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master
A  foo"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="93315e3"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master dirty
  expect_symbol STAGED staged

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_file_committed()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [ahead 1]"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="dce493f"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean
  expect_symbol AHEAD ahead

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_pulled_external_change()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="39475bc"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean
 
  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_fetched_external_change()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [behind 1]"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="39475bc"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean
  expect_symbol BEHIND behind

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_fetch_another_external_change()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [behind 2]"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="39475bc"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean
  expect_emit "2$PROMPTER_MOD_GIT_SYMBOL_BEHIND" behind

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_create_another_file()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [behind 2]
?? bar"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="39475bc"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master dirty
  expect_emit "2$PROMPTER_MOD_GIT_SYMBOL_BEHIND" behind
  expect_symbol UNTRACKED untracked

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_commit_2nd_file()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [ahead 1, behind 2]"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="61d62d6"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean
  expect_symbol AHEAD ahead
  expect_emit "2$PROMPTER_MOD_GIT_SYMBOL_BEHIND" behind

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}


# When ahead and behind colors are the same, a display optimization kicks in
# where both the ahead and behind parts are combined into the same segment.
# Repeat the above test with the colors temporarily modified
function test_commit_2nd_file_same_ahead_and_behind_colors()
{
  # Copy original colors into local variables
  local orig_behind_fg_color=$prompter_mod_git_arg_behind_fg_color
  local orig_behind_bg_color=$prompter_mod_git_arg_behind_bg_color
  prompter_mod_git_arg_behind_fg_color=$prompter_mod_git_arg_ahead_fg_color
  prompter_mod_git_arg_behind_bg_color=$prompter_mod_git_arg_ahead_bg_color

  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [ahead 1, behind 2]"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="61d62d6"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean
  expect_emit "$PROMPTER_MOD_GIT_SYMBOL_AHEAD  2$PROMPTER_MOD_GIT_SYMBOL_BEHIND" behind

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

  # Reset colors
  prompter_mod_git_arg_behind_fg_color=$orig_behind_fg_color
  prompter_mod_git_arg_behind_bg_color=$orig_behind_bg_color
}


function test_modify_file()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [ahead 1, behind 2]
 M bar"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="61d62d6"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master dirty
  expect_symbol AHEAD ahead
  expect_emit "2$PROMPTER_MOD_GIT_SYMBOL_BEHIND" behind
  expect_symbol NOT_STAGED not_staged

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_commit_and_modify_bar_again()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [ahead 1, behind 2]
MM bar"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="61d62d6"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master dirty
  expect_symbol AHEAD ahead
  expect_emit "2$PROMPTER_MOD_GIT_SYMBOL_BEHIND" behind
  expect_symbol STAGED staged
  expect_symbol NOT_STAGED not_staged

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_merge()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [ahead 3]"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="cdee5b6"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean
  expect_emit "3$PROMPTER_MOD_GIT_SYMBOL_AHEAD" ahead


  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_confict()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [ahead 1, behind 1]
UU foo"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="02d3e9c"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master dirty
  expect_symbol AHEAD ahead
  expect_symbol BEHIND behind
  expect_symbol CONFLICTED conflicted

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_conflict_resolved()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## master...origin/master [ahead 2]"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="62f466a"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit master clean
  expect_emit "2$PROMPTER_MOD_GIT_SYMBOL_AHEAD" ahead

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_detached()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## HEAD (no branch)"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="02d3e9c"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit "${PROMPTER_MOD_GIT_SYMBOL_DETACHED}02d3e9c" clean

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_modify_detached_stage()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## HEAD (no branch)
 M bar"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="02d3e9c"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit "${PROMPTER_MOD_GIT_SYMBOL_DETACHED}02d3e9c" dirty
  expect_symbol NOT_STAGED not_staged

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}



function test_new_local_branch()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## local/branch"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="02d3e9c"
  GIT_DESCRIBE_EXIT_CODE=0


  # Setup expectations Phase
  expect_emit "local/branch" clean

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}


function test_fresh_git_repo()
{
  # Initialization Phase
  initialize_expectations
  GIT_STATUS_OUTPUT="## Initial commit on master"
  GIT_STATUS_EXIT_CODE=0
  GIT_DESCRIBE_OUTPUT="fatal: Not a valid object name HEAD"
  GIT_DESCRIBE_EXIT_CODE=128


  # Setup expectations Phase
  expect_emit "${PROMPTER_MOD_GIT_SYMBOL_DETACHED}<fresh repo>" clean

  # Run test Phase
  prompter_mod_git_main


  # Verify expectations Phase
  verify_expectations

}

SHUNIT_PARENT=$0 ; . $SHUNIT