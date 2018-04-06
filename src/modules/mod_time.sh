PROMPTER_MOD_TIME_DEFAULT_STRFTIME_FORMAT="%H:%M:%S"
function prompter_mod_time_short_desc()
{
  echo "Print the current time"
}

function prompter_mod_time_usage()
{
  cat <<EOF
Usage:
time [--format <strftime-format>]
Print the current time in HH:MM:SS (24hr) format, or the given strftime format
--fg              Foreground color to use for this module. Defaults to $prompter_mod_time_default_fg_color
--bg              Background color to use for this module. Defaults to $prompter_mod_time_default_bg_color
--strftime-format The given strftime format. Defaults to shell's own format
                  or '$PROMPTER_MOD_TIME_DEFAULT_STRFTIME_FORMAT'
EOF
}

function prompter_mod_time_main()
{
  local format=$prompter_mod_time_arg_format
  local shell=$prompter_shell
  if [[ $shell == 'bash' ]]
  then
    if [[ -n $format ]]
    then
      prompter_emit "\\D{$format}"
    else
      prompter_emit '\t'
    fi
  elif [[ $shell == 'zsh' ]]
  then
    if [[ -n $format ]]
    then
      prompter_emit "%D{$format}"
    else
      prompter_emit '%*'
    fi
  else
    format="${format:-$PROMPTER_MOD_TIME_DEFAULT_STRFTIME_FORMAT}"
    prompter_emit $(date "+$format")
  fi
}

# Define default colors, used if user doesn't choose color explicitly
prompter_mod_time_default_fg_color=15
prompter_mod_time_default_bg_color=21

prompter_mod_time_options=(format:)