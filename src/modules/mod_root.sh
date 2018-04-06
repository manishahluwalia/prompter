function prompter_mod_root_short_desc()
{
  echo "Show an indication in the prompt if the user is root or not"
}

function prompter_mod_root_usage()
{
  cat <<EOF
Usage:
root
Show a '#' indication in the prompt if the user is root. Otherwise show a '%'
--fg      Foreground color to use for this module. Defaults to $prompter_mod_root_default_fg_color
--bg      Background color to use for this module. Defaults to $prompter_mod_root_default_bg_color
EOF
}

function prompter_mod_root_main()
{
  case $prompter_shell in
  zsh)
    prompter_emit '%#'
    ;;

  bash)
    prompter_emit '\$'
    ;;

  *)
    prompter_emit '$'
    ;;
  esac
}

# Define default colors, used if user doesn't choose color explicitly
prompter_mod_root_default_fg_color=0
prompter_mod_root_default_bg_color=196
