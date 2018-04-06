function prompter_mod_read_only_short_desc()
{
  echo "If the current working directory is read-only, print a lock icon"
}

function prompter_mod_read_only_usage()
{
  cat <<EOF
Usage:
read-only
If the current working directory is read-only, print a lock icon
--fg      Foreground color to use for this module. Defaults to $prompter_mod_read_only_default_fg
--bg      Background color to use for this module. Defaults to $prompter_mod_read_only_default_bg
EOF
}

function prompter_mod_read_only_main()
{
  if [[ ! -w $PWD ]]
  then
    prompter_emit $'\xee\x82\xa2' # uE0A2 Lock
  fi
}

# Define default colors, used if user doesn't choose color explicitly
prompter_mod_read_only_default_fg_color=254
prompter_mod_read_only_default_bg_color=124
