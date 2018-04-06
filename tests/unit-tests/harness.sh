# Globals!

# As a crappy but easy solution, we keep the expected calls and recorded calls in globals
# This doesn't work if the calls happen in a sub-shell! i.e. $() or ``
harness_expectations=
harness_trace=

harness_simulateExit=false

if [[ -n $ZSH_VERSION ]]
then
  SRC_DIR="`dirname $0`"
else
  SRC_DIR="`dirname ${BASH_SOURCE[0]}`"
fi
SRC_DIR+="/../../src"

# expectations

function expect_call()
{
  method="$1"
  shift
  harness_expectations+="Execute: $method"$'\n'"Num args: $#"$'\n'
  for i in "$@"
  do
  	# Note: The following line is intentionally broken in 2. We are replacing all newlines with spaces
    harness_expectations+="Arg: ${i//
/ }"$'\n'
  done
}

function record_call()
{
  if $harness_simulateExit
  then
    return
  fi

  method="$1"
  shift
  harness_trace+="Execute: $method"$'\n'"Num args: $#"$'\n'
  for i in "$@"
  do
  	# Note: The following line is intentionally broken in 2. We are replacing all newlines with spaces
    harness_trace+="Arg: ${i//
/ }"$'\n'
  done
}

function initialize_expectations()
{
  harness_expectations=
  harness_trace=
  harness_simulateExit=false
}

function verify_expectations()
{
  # TODO: Make it more developer friendly
  diff <(echo "$harness_expectations") <(echo "$harness_trace")
  assertTrue "Verification failed" $?
  # Reset harness_expectations and state
  initialize_expectations
}

# Mocked functions

function prompter_fatal()
{
  record_call fatal "$@"
  harness_simulateExit=true
}

function prompter_error()
{
  record_call error "$@"
}

function prompter_warn()
{
  record_call warn "$@"
}

function printf()
{
  record_call printf "$@"
}

# zsh special handling
if [[ -n $ZSH_VERSION ]]
then
  # Needed by shunit2
  setopt shwordsplit
  # Makes shunit give the line number in the function in asserts
  unsetopt function_argzero
fi

# Define the global SHUNIT to refer to the shunit library
# We first have to find the path to this current script,
# and navigate from there to the shunit2 library. This
# is done differently in zsh and bash because of the different
# meanings of $0 in the 2 shells
if [[ -n $ZSH_VERSION ]]
then
  SHUNIT="`dirname $0`"
else
  SHUNIT="`dirname ${BASH_SOURCE[0]}`"
fi
SHUNIT+="/../../test-libs/shunit2/2.1.6/src/shunit2"


# Only for testing the harness itself
function testHarness()
{
	echo "set expectations"

	expect_call warn a warning
	expect_call printf format '$RANDOM'

    echo "run"
	warn a warning
	printf format '$RANDOM'

    echo "harness_expectations:"
    echo "$harness_expectations"
    echo
    echo "harness_trace:"
    echo "$harness_trace"
    echo

    echo "Verify"
	verify_harness_expectations
}