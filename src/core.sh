 # Define defaults
PROMPTER_DEFAULT_FG_COLOR=0
PROMPTER_DEFAULT_BG_COLOR=7
PROMPTER_ZSH_HIDE_FROM_SHELL_TEMPLATE='%%{%s%%}'
PROMPTER_BASH_HIDE_FROM_SHELL_TEMPLATE='\\[\\e%s\\]'
PROMPTER_PLAIN_HIDE_FROM_SHELL_TEMPLATE='%s'

# Define and initialize globals
prompter_default_fg_color=$PROMPTER_DEFAULT_FG_COLOR
prompter_default_bg_color=$PROMPTER_DEFAULT_BG_COLOR
prompter_terminal_bg_color=0
prompter_shell="$(basename $SHELL)"
prompter_hide_from_shell_template=
prompter_numArgsGlobalOptions=0

prompter_modules=()

prompter_executing_module=
prompter_loading_module_source_file=

debug_level=0


# Define routines for output

# For testability
function _prompter_echo_wrapper
{
  echo "$@"
}

# The underlying function that prints messages
# Usage: _prompter_log_message <level-name> <message...>
#  e.g. _prompter_log_message "ERROR" "Module cwd" "Houston, we have a problem"
function _prompter_log_message
{
  local level="$1"
  shift

  local module_desc=
  if [[ -n $prompter_executing_module ]]
  then
    module_desc="Module $prompter_executing_module: "
  fi
  
  _prompter_echo_wrapper "${level}: ${module_desc}$@"
}

# Usage: prompter_fatal <args>
# Prints a FATAL message on stderr
function prompter_fatal
{
  _prompter_log_message "FATAL" "$@"
}

# Usage prompter_error <args>
# Prints an ERROR message on stderr
function prompter_error
{
  _prompter_log_message "ERROR" "$@"
}

# Usage prompter_warn <args>
# Prints a WARN message on stderr
function prompter_warn
{
  _prompter_log_message "WARN" "$@"
}

# Usage: prompter_is_function <symbol>
# Check if the given <symbol> is defined as a function
# Returns shell true or false
function prompter_is_function
{
  name="$1"
  type=$(type $name 2>&-)
  if [[ $type == "$name is a function"* || $type == "$name is a shell function"* ]]
  then
    return 0
  else
    return 1
  fi
}

# Usage:
# prompter_friendlyName_to_symbolicName <module-friendly-name>
# Every module has a "friendly" name (the name the user refers to the module by). This name can contain hyphens.
# The routine takes such a name and converts it to one that is usable as a sh symbol name: we convert - to _
# The mapping from friendly name to symbolic name is many to one.
function prompter_friendlyName_to_symbolicName
{
  echo ${1//-/_}
}

# Usage: prompter_module_usage <module-name>
# Print the usage for the module <module-name>
function prompter_module_usage
{
  local module="$(prompter_friendlyName_to_symbolicName $1)"
  if ! prompter_is_function prompter_mod_${module}_usage
  then
    prompter_fatal "No such module of name $module"
  fi

  prompter_mod_${module}_usage
}

# Print a list of all the modules, and their short descriptions
function prompter_list_modules
{
  local mod
  for mod in "${prompter_modules[@]}"
  do
    eval local desc=\"$(prompter_mod_$(prompter_friendlyName_to_symbolicName ${mod})_short_desc)\"
    printf "%-15s %s\n" "$mod" "$desc"
  done
}

# A global variable that captures how many of the argv[] elements were consumed to process global options
prompter_numArgsGlobalOptions=0

# Given a list of arguments, process the global options
# Return 0 if processing should continue
# Return 1 if processing should halt cleanly (e.g. --help was invoked)
# Return 2 if processing should halt with error
function prompter_evaluate_global_options
{
  # We get getopts to read long option names. We do this by treating '-'
  # as an option name, and treat the option name itself an an argument to 
  # the option named '-'! Check out Arvid Requat's answer to:
  # http://stackoverflow.com/questions/402377/using-getopts-in-bash-shell-script-to-get-long-and-short-command-line-options
  # for details
  while getopts -- -: _
  do
    case $OPTARG in
      debug)
        debug_level="${@:$OPTIND:1}"; OPTIND=$(( $OPTIND + 1 ))
        if [[ -z $debug_level ]]
        then
          prompter_fatal "Need a valid debug level"
          return 2
        fi
        ;;

      help)
        if [[ "${OPTIND}" -le $# ]]
        then
          prompter_module_usage "${@:$OPTIND:1}"; OPTIND=$(( $OPTIND + 1 ))
        else
          prompter_usage
        fi
        return 1
        ;;

      shell)
        prompter_shell="${@:$OPTIND:1}"; OPTIND=$(( $OPTIND + 1 ))
        if [[ -z $prompter_shell ]]
        then
          prompter_fatal "Need a valid shell name"
          return 2
        elif [[ "$prompter_shell" != "bash" && "$prompter_shell" != "zsh" ]]
        then
          prompter_fatal "Shell must be bash or zsh. $prompter_shell is not supported"
          return 2
        fi
        ;;

      terminal-bg)
        prompter_terminal_bg_color="${@:$OPTIND:1}"; OPTIND=$(( $OPTIND + 1 ))
        if [[ "$prompter_terminal_bg_color" != $(eval echo '$(( prompter_terminal_bg_color ))' 2>&- ) ]]
        then
          prompter_fatal "Need a valid terminal-bg (should be a color number). Got: $prompter_terminal_bg_color"
          return 2
        fi
        ;;

      list-modules)
        prompter_list_modules
        return 1
        ;;

      *)
        prompter_fatal "Unknown option $OPTARG"
        return 2
        ;;

    esac
  done

  # We can't shift the arguments we processed above, since we are in a function.
  # Pass this number to the caller and let them deal with it
  prompter_numArgsGlobalOptions=$((OPTIND-1))

  # Set up shell specific globals.
  case "$prompter_shell" in
    zsh)
      prompter_hide_from_shell_template=$PROMPTER_ZSH_HIDE_FROM_SHELL_TEMPLATE
      ;;

    bash)
      prompter_hide_from_shell_template=$PROMPTER_BASH_HIDE_FROM_SHELL_TEMPLATE
      ;;

    *)
      # If an invalid --shell arg was provided, we would have 'fatal'ed out above
      # We get here if NO --shell was provided and we got a default value from $SHELL
      prompter_warn "Shell $SHELL is not supported. Expect peculiar behavior."
      prompter_hide_from_shell_template=$PROMPTER_PLAIN_HIDE_FROM_SHELL_TEMPLATE
      ;;

  esac

  return 0
}

# The routine that invokes the modules with arguments and options, given a '::'
# separated list of module invocation 
function prompter_drive_modules
{
  while [[ $# -gt 0 ]] 
  do
    local module_friendlyName="$1"
    local module_symbolicName="$(prompter_friendlyName_to_symbolicName $1)"
    shift
    if prompter_is_function "prompter_mod_${module_symbolicName}_main"
    then
      # First set the default fg and bg colors. Order of preference:
      # 1) The --fg and --bg module options, if specified by the user
      # 2) The module defaults, if any, as specified in
      #    `prompter_mod_MODULENAME_default_fg_color' variables defined in
      #    the module
      # 3) Global defaults, e.g. PROMPTER_DEFAULT_FG_COLOR
      # Obviously, we evalute in the reverse order, assuming #3 and overriding
      # if we can
      prompter_fg_color=$PROMPTER_DEFAULT_FG_COLOR
      prompter_bg_color=$PROMPTER_DEFAULT_BG_COLOR
      local module_default_fg
      eval module_default_fg=\"\${prompter_mod_${module_symbolicName}_default_fg_color}\"
      if [[ -n $module_default_fg ]]
      then
        prompter_fg_color=$module_default_fg
      fi
      local module_default_bg
      eval module_default_bg=\"\${prompter_mod_${module_symbolicName}_default_bg_color}\"
      if [[ -n $module_default_bg ]]
      then
        prompter_bg_color=$module_default_bg
      fi

      unset args mod_options spec
      local args=()
      local mod_options
      eval mod_options=\(\"\${prompter_mod_${module_symbolicName}_options\[\@\]}\"\)
      local spec
      for spec in "${mod_options[@]}"
      do
        local varName="prompter_mod_${module_symbolicName}_arg_${spec//-/_}"
        eval unset ${varName%:}
      done
      # Use the same trick for using getopts to read long options as we used in
      # the function prompter_evaluate_global_options()
      OPTIND=1
      while getopts -- -: _
      do
        case $OPTARG in
          fg)
            local val="${@:$OPTIND:1}"; OPTIND=$(( $OPTIND + 1 ))
            if [[ "$val" == $(eval echo '$(( val ))' 2>&- ) ]]
            then
              prompter_fg_color=$val
            else
              prompter_fatal "Invalid value of --fg: $val: Needs to be a color number"
              return 2
            fi
            ;;

          bg)
            local val="${@:$OPTIND:1}"; OPTIND=$(( $OPTIND + 1 ))
            if [[ "$val" == $(eval echo '$(( val ))' 2>&- ) ]]
            then
              prompter_bg_color=$val
            else
              prompter_fatal "Invalid value of --bg: $val: Needs to be a color number"
              return 2
            fi
            ;;

          # We have some other option, perhaps an error, on one defined by the module
          *)
            unset matched mod_options spec
            # First get the list of options the module supports
            local mod_options
            eval mod_options=\(\"\${prompter_mod_${module_symbolicName}_options\[\@\]}\"\)
            
            # Empty if the given option did NOT match any of the options supported by the module
            local matched=
            local spec
            # Loop through all the module options
            for spec in "${mod_options[@]}"
            do
              # The value / setting of the option will be placed in the following global
              # variable, whose name is "prompter_mod_MODULENAME_arg_OPTIONNAME"
              # where MODULENAME and OPTIONNAME have '-' converted to '_'
              local varName="prompter_mod_${module_symbolicName}_arg_${OPTARG//-/_}"
              if [[ "$spec" == "$OPTARG" ]]
              then
                # This is indeed a boolean option supported by the module
                matched=true
                eval ${varName}=true
              elif [[ "$spec" == "$OPTARG": ]]
              then
                # This is an option with a value
                if [[ $OPTIND -gt $# ]]
                then
                  # ... And, we have no further input from the user
                  prompter_fatal "Argument $OPTARG for module $module_friendlyName needs a value"
                  return 2
                else
                  matched=true
                  eval ${varName%:}=\'"${@:$OPTIND:1}"\'
                  OPTIND=$(( OPTIND + 1 ))
                fi
              fi
            done
            if [[ -z $matched ]]
            then
              prompter_fatal "Module $module_friendlyName has no argument named $OPTARG"
              return 2
            fi
            ;;
        esac
      done
      shift $((OPTIND-1))
      # Read the rest of the arguments, till the end or till the separating
      # '::' terminator. Place them in the array args
      while [[ $# -gt 0 && "$1" != "::" ]]
      do
        args+=("$1")
        shift
      done
      if [[ "$1" == "::" ]]
      then
        shift
      fi
      # Invoke the module's main routine. While executing, set the
      # 'prompter_executing_module' global to the module's name, so
      # we can tell which module is executing if we have to (say, from logs)
      prompter_executing_module="$module_friendlyName"
      prompter_mod_${module_symbolicName}_main "${args[@]}"
      prompter_executing_module=
    else
      prompter_fatal "Unknown module $module_friendlyName"
      return 2
    fi
  done
}

# Globals and constants used by 'prompter_emit'
prompter_current_fg_color=
prompter_current_bg_color=
PROMPTER_ESCAPE_CHAR=$'\e'
PROMPTER_CHAR_PATCHED_THIN_SEPARATOR=$'\xee\x82\xb1' #UE0B1
PROMPTER_CHAR_PATCHED_SEPARATOR=$'\xee\x82\xb0' # UE0B0
prompter_thin_separator=$PROMPTER_CHAR_PATCHED_THIN_SEPARATOR
prompter_main_separator=$PROMPTER_CHAR_PATCHED_SEPARATOR
# Usage: [options] prompter_emit <text> [<fg-color> <bg-color>]
# Will emit text in the given foreground and background colors, adding
# separators as necessary
# Options:
#   prompter_use_main_separator=true
#           If set to true, uses the main separator whenever a separator
#           is needed, irrespective of other conditions
# For fg and bg colors, if nothing is specified, then the globals
# $prompter_fg_color and $prompter_bg_color are used
function prompter_emit()
{
  if [[ $# -ne 1 && $# -ne 3 ]]
  then
    prompter_fatal "Internal error: Invalid usage of emit()."
    return 2
  fi

  local text="$1"
  if [[ -n $text ]]
  then
    text="$text "
  fi

  local fg_color=${2:-$prompter_fg_color}
  local bg_color=${3:-$prompter_bg_color}

  if [[ -z $prompter_current_bg_color ]]
  then
    # This is the very first segment being displayed. Don't use any separator
    printf "$prompter_hide_from_shell_template" "${PROMPTER_ESCAPE_CHAR}[38;5;${fg_color}m${PROMPTER_ESCAPE_CHAR}[48;5;${bg_color}m"
    printf "%s" "$text"
  elif [[ "$prompter_current_bg_color" == "$bg_color" && -z "$prompter_use_main_separator" ]]
  then
    # The previous segment displayed had the same background color as this one. Use a thin separator.
    printf "$prompter_hide_from_shell_template" "${PROMPTER_ESCAPE_CHAR}[38;5;${fg_color}m${PROMPTER_ESCAPE_CHAR}[48;5;${bg_color}m"
    printf "%s %s" "$prompter_thin_separator" "$text"
  else
    # This segment has a different background color as the previous. Use the 'main' separator
    printf "$prompter_hide_from_shell_template" "${PROMPTER_ESCAPE_CHAR}[38;5;${prompter_current_bg_color}m${PROMPTER_ESCAPE_CHAR}[48;5;${bg_color}m"
    printf "%s" "$prompter_main_separator"
    printf "$prompter_hide_from_shell_template" "${PROMPTER_ESCAPE_CHAR}[38;5;${fg_color}m${PROMPTER_ESCAPE_CHAR}[48;5;${bg_color}m"
    printf " %s" "$text"
  fi

  prompter_current_fg_color="$fg_color"
  prompter_current_bg_color="$bg_color"
}

# We are done displaying all segments, end the prompt
function prompter_terminate_prompt()
{
  prompter_use_main_separator=true prompter_emit "" 0 $prompter_terminal_bg_color
  printf "$prompter_hide_from_shell_template" "${PROMPTER_ESCAPE_CHAR}[0m"
}

# The main driver routine
function prompter()
{
  local ret
  prompter_evaluate_global_options "$@"
  ret=$?
  [[ $ret == 1 ]] && return 0
  [[ $ret == 2 ]] && return 1

  shift $prompter_numArgsGlobalOptions

  prompter_drive_modules "$@"
  ret=$?
  [[ $ret == 2 ]] && return 1

  prompter_terminate_prompt

  return $ret
}

# Heredoc screws up line numbering in bash. That's why this function is at the end!
# Print the usage
function prompter_usage
{
  cat <<EOF
Usage:
  $0 [<global-options>] [<module1-with-args> [:: <module2-with-args>
       [:: <module3-with-args> [...]]]]

  Create a prompt for the given shell, based on the modules specifications
  given. Separate module (and its) specifications with '::'

Global Options:
  --debug <level>         Debug level. Default 0 - no debug logging
  --help                  Print this help message and exit
  --help [<module-name>]  Print the help for a specific module and exit
  --list-modules          List the modules available and exit
  --shell <shell>         Print the prompt using shell escape sequences for the
                          given shell (zsh, bash). Defaults to $SHELL.
  --terminal-bg <color>   The ANSI color that is the background of the terminal.
                          Used to end the prompt correctly. Default $prompter_terminal_bg_color.
                          Suggested values for terminal with background:
                            White           - 15
                            Black           - 0
                            Solarized Light - 15
                            Solarized Dark  - 8

Module With Args:
  <name-of-module> [--fg <color>] [--bg <color>] [<other-module-options>]
     [<other-module-args>]

  Every module accepts the following arguments:
  --fg <color>            The ANSI color to use as the foreground for this
                          module. Defaults to the value of --default-fg
  --bg <color>            The ANSI color to use as the background for this
                          module. Defaults to the value of --default-bg
  In addition, the module may accept some options and arguments specific to the
                          module. Check out the module's specifications via
                          --help <module-name>

EOF
  # For the following section, we want to print verbatim, without variable
  # expansion
  cat <<'EOF'
Example invocation:
First, either source the file 'prompter-sourceable', or add the file 'prompter'
to your PATH.

Then, set in your .zshrc or .bashrc:
  PS1="$(prompter --terminal-bg 15 term-title --pty :: time :: cwd :: git)"

If you'd like to modify the colors used, for, say, the 'time' module:
  PS1="$(prompter --terminal-bg 15 term-title --pty :: time --fg 15 --bg 54 :: cwd :: git)"

In some cases, you will need the prompt expression to be evaluated before every
prompt. For instance, the 'exit' module takes an argument which is the exit
value you want to render. This changes based on the last command run, so you
want to evaluate it every single time. Hence, you will need to do something like:
For zsh:
  function build_prompt() {
    PS1="$(prompter --terminal-bg 15 term-title --pty :: time :: cwd :: git :: exit-code $?)"
  }
  precmd_functions+=(build_prompt)

For bash:
(same function build_prompt() as above)
  PROMPT_COMMAND="build_prompt ; $PROMPT_COMMAND"
EOF
}
