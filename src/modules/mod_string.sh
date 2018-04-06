function prompter_mod_string_short_desc()
{
  echo "Dump a given literal string"
}

function prompter_mod_string_usage()
{
  cat <<EOF
Usage:
string <a-string-to-print>
Prints the given string as part of the prompt, in the given (or default) colors
--fg      Foreground color to use for this module. Defaults to $prompter_mod_string_default_fg_color
--bg      Background color to use for this module. Defaults to $prompter_mod_string_default_bg_color
EOF
}

function prompter_mod_string_main()
{
  string="$1"
  prompter_emit "$string"
}

# Define default colors, used if user doesn't choose color explicitly
prompter_mod_string_default_fg_color=39
prompter_mod_string_default_bg_color=10
