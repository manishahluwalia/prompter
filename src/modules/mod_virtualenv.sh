function prompter_mod_virtualenv_short_desc()
{
  echo "Indicate with python virtualenv we are in (if any)"
}

function prompter_mod_virtualenv_usage()
{
  cat <<EOF
Usage:
virtualenv
If we are in a python virtualenv created by virtualenv, indicate
the name of the virtual environment.

--fg             Foreground color to use for this module. Defaults to $prompter_mod_exit_code_default_fg_color
--bg             Background color to use for this module. Defaults to $prompter_mod_exit_code_default_bg_color
EOF
}

function prompter_mod_virtualenv_main()
{
  [[ -z $VIRTUAL_ENV ]] && return 0

  prompter_emit "$(basename $VIRTUAL_ENV)"
}

# Define default colors, used if user doesn't choose color explicitly
prompter_mod_virtualenv_default_fg_color=0
prompter_mod_virtualenv_default_bg_color=35