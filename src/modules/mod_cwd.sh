function prompter_mod_cwd_short_desc()
{
  echo "Print the current working directory"
}

function prompter_mod_cwd_usage()
{
  cat <<EOF
Usage:
cwd [--depth <num-dir-levels>]
Prints the current working directory (or a part of it) as part of the prompt,
in the given (or default) colors.
--depth For zsh, the number of directory levels to display. For bash, the only
        supported value is 1. Default is to display the full path.
--fg    Foreground color to use for this module. Defaults to $prompter_mod_cwd_default_fg_color
--bg    Background color to use for this module. Defaults to $prompter_mod_cwd_default_bg_color
EOF
}

function prompter_mod_cwd_main()
{
  local depth=$prompter_mod_cwd_arg_depth
  local shell=$prompter_shell
  local cwd
  if [[ $shell == 'bash' ]]
  then
    if [[ -z "$depth" ]]
    then
      cwd="\\w"
    elif [[ "$depth" == "1" ]]
    then
      cwd="\\W"
    else
      prompter_warn "Depth $depth is not supported for shell bash"
      cwd="\\W"
    fi
  elif [[ $shell == 'zsh' ]]
  then
    if [[ -n "depth" ]]
    then
      cwd="%${depth}~"
    else
      cwd='%~'
    fi
  else
    cwd="$PWD"
  fi

  prompter_emit "$cwd"
}

# Define default colors, used if user doesn't choose color explicitly
prompter_mod_cwd_default_fg_color=0
prompter_mod_cwd_default_bg_color=39

prompter_mod_cwd_options=("depth:")