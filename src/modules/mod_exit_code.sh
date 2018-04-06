function prompter_mod_exit_code_short_desc()
{
  echo "Interpets the exit code of the last shell command or pipeline"
}

function prompter_mod_exit_code_usage()
{
  cat <<EOF
Usage:
exit-code [--hide-if-success] <exit-code>
Interpets the exit code of the last shell command (or pipeline) and displays it
in a friendly manner.
--fg             Foreground color to use for this module. Defaults to $prompter_mod_exit_code_default_fg_color
--bg             Background color to use for this module. Defaults to $prompter_mod_exit_code_default_bg_color
--hide-if-sucess If the exit code is 0 (indicates success), then don't display
                 anything
<exit-code>   The exit code of the previous process. Typically obtained from \$?
EOF
}

# Define signal names for signal numbers

case $(uname -s) in
  Darwin)
    prompter_mod_exit_signal_name_1=HUP
    prompter_mod_exit_signal_name_2=INT
    prompter_mod_exit_signal_name_3=QUIT
    prompter_mod_exit_signal_name_4=ILL
    prompter_mod_exit_signal_name_5=TRAP
    prompter_mod_exit_signal_name_6=ABRT
    prompter_mod_exit_signal_name_7=EMT
    prompter_mod_exit_signal_name_8=FPE
    prompter_mod_exit_signal_name_9=KILL
    prompter_mod_exit_signal_name_10=BUS
    prompter_mod_exit_signal_name_11=SEGV
    prompter_mod_exit_signal_name_12=SYS
    prompter_mod_exit_signal_name_13=PIPE
    prompter_mod_exit_signal_name_14=ALRM
    prompter_mod_exit_signal_name_15=TERM
    prompter_mod_exit_signal_name_16=URG
    prompter_mod_exit_signal_name_17=STOP
    prompter_mod_exit_signal_name_18=TSTP
    prompter_mod_exit_signal_name_19=CONT
    prompter_mod_exit_signal_name_20=CHLD
    prompter_mod_exit_signal_name_21=TTIN
    prompter_mod_exit_signal_name_22=TTOU
    prompter_mod_exit_signal_name_23=IO
    prompter_mod_exit_signal_name_24=XCPU
    prompter_mod_exit_signal_name_25=XFSZ
    prompter_mod_exit_signal_name_26=VTALRM
    prompter_mod_exit_signal_name_27=PROF
    prompter_mod_exit_signal_name_28=WINCH
    prompter_mod_exit_signal_name_29=INFO
    prompter_mod_exit_signal_name_30=USR1
    prompter_mod_exit_signal_name_31=USR2
  ;;

  Linux)
    # All the architecture independent ones
    prompter_mod_exit_signal_name_1=HUP
    prompter_mod_exit_signal_name_2=INT
    prompter_mod_exit_signal_name_3=QUIT
    prompter_mod_exit_signal_name_4=ILL
    prompter_mod_exit_signal_name_5=TRAP
    prompter_mod_exit_signal_name_6=ABRT
    prompter_mod_exit_signal_name_8=FPE
    prompter_mod_exit_signal_name_9=KILL
    prompter_mod_exit_signal_name_11=SEGV
    prompter_mod_exit_signal_name_13=PIPE
    prompter_mod_exit_signal_name_14=ALRM
    prompter_mod_exit_signal_name_15=TERM
  ;;  
esac

function prompter_mod_exit_code_main()
{
  local exit_code="$1"
  if [[ -z "$exit_code" ]]
  then
    prompter_error "Need to provide an exit code"
  fi

  if [[ $exit_code == "0" && $prompter_mod_exit_code_arg_hide_if_success == "true" ]]
  then
    return
  fi

  if [[ $exit_code -gt 128 ]]
  then
    local signal=$(( exit_code-128 ))
    if [[ -n $(eval echo \$prompter_mod_exit_signal_name_${signal}) ]]
    then
      signal=$(eval echo \$prompter_mod_exit_signal_name_${signal})
    fi
    exit_code=$'\xf0\x9f\x9a\xa6 '"$signal" # U0001f6a6 traffic light (needs a space after the symbol since it takes up 2 columns in the output)
  elif [[ $exit_code -gt 0 ]]
  then
    exit_code=$'\xe2\x9c\x98'"$exit_code" # u2718 cross 
  else
    exit_code=$'\xe2\x9c\x93' # u2713 check mark
  fi
  
  prompter_emit "$exit_code"
}

# Define default colors, used if user doesn't choose color explicitly
prompter_mod_exit_code_default_fg_color=39
prompter_mod_exit_code_default_bg_color=10

prompter_mod_exit_code_options=("hide-if-success")