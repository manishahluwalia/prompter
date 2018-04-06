function prompter_mod_term_title_short_desc()
{
  echo "Sets the terminal title to the username@hostname: pwd | pty size"
}

function prompter_mod_term_title_usage()
{
  cat <<EOF
Usage:
  term-title [options]

On terminals that support escape sequences for setting the terminal window
title (e.g. xterm*), it sets the terminal title window. The title is set to
the username,  thehostname and the current working directory. Optionally, it
also sets the pty name, and the terminal size

Options:
  --pty                 If set, display the pty number
  --size                If set, display the window size in cols x rows
  --username <username> If given, use this username, else let the shell get it
  --hostname <hostname> If given, use this hostname, else let the shell get
                        the full hostname
EOF
}

function prompter_mod_term_title_main()
{
  local userName=$prompter_mod_term_title_arg_username
  local hostName=$prompter_mod_term_title_arg_hostname
  local pty=$prompter_mod_term_title_arg_pty
  local size=$prompter_mod_term_title_arg_size
  local title=
  local shell=$prompter_shell
  if [[ $shell == 'bash' ]]
  then
    if [[ -z "$userName" ]]
    then
      title+="\\u"
    else
      title+="$userName"
    fi
    if [[ -z "$hostName" ]]
    then
      title+="@\\H"
    else
      title+="@$hostName"
    fi
    title+=": \\w"
    local sep=" | "
    if [[ -n $pty ]]
    then
      title+="${sep}\\l"
      sep=" "
    fi
    if [[ -n $size ]]
    then
      title+="${sep}${COLUMNS}x${LINES}"
    fi
  elif [[ $shell == 'zsh' ]]
  then
    if [[ -z "$userName" ]]
    then
      title+="%n"
    else
      title+="$userName"
    fi
    if [[ -z "$hostName" ]]
    then
      title+="@%M"
    else
      title+="@$hostName"
    fi
    title+=": %~"
    local sep=" | "
    if [[ -n $pty ]]
    then
      title+="${sep}%y"
      sep=" "
    fi
    if [[ -n $size ]]
    then
      title+="${sep}${COLUMNS}x${LINES}"
    fi
  else
    if [[ -z "$userName" ]]
    then
      title+="$USER"
    else
      title+="$userName"
    fi
    title+="@"
    if [[ -z "$hostName" ]]
    then
      title+="$(hostname)"
    else
      title+="$hostName"
    fi
    title+=": $PWD"
    local sep=" | "
    if [[ -n $pty ]]
    then
      title+="${sep}$(tty)"
      sep=" "
    fi
    if [[ -n $size ]]
    then
      title+="${sep}${COLUMNS}x${LINES}"
    fi
  fi

  printf "$prompter_hide_from_shell_template" "${PROMPTER_ESCAPE_CHAR}]0;${title}"$'\007'
}

prompter_mod_term_title_options=("username:" "hostname:" "pty" "size")