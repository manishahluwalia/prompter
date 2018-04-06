# Set default colors for fb and bg for clean, dirty, ahead, behind, staged, not_staged, untracked and conflicted states
PROMPTER_MOD_GIT_DEFAULT_CLEAN_FG_COLOR=0
PROMPTER_MOD_GIT_DEFAULT_CLEAN_BG_COLOR=148
PROMPTER_MOD_GIT_DEFAULT_DIRTY_FG_COLOR=15
PROMPTER_MOD_GIT_DEFAULT_DIRTY_BG_COLOR=161
PROMPTER_MOD_GIT_DEFAULT_AHEAD_FG_COLOR=250
PROMPTER_MOD_GIT_DEFAULT_AHEAD_BG_COLOR=240
PROMPTER_MOD_GIT_DEFAULT_BEHIND_FG_COLOR=250
PROMPTER_MOD_GIT_DEFAULT_BEHIND_BG_COLOR=240
PROMPTER_MOD_GIT_DEFAULT_STAGED_FG_COLOR=15
PROMPTER_MOD_GIT_DEFAULT_STAGED_BG_COLOR=22
PROMPTER_MOD_GIT_DEFAULT_NOT_STAGED_FG_COLOR=15
PROMPTER_MOD_GIT_DEFAULT_NOT_STAGED_BG_COLOR=130
PROMPTER_MOD_GIT_DEFAULT_UNTRACKED_FG_COLOR=15
PROMPTER_MOD_GIT_DEFAULT_UNTRACKED_BG_COLOR=52
PROMPTER_MOD_GIT_DEFAULT_CONFLICTED_FG_COLOR=15
PROMPTER_MOD_GIT_DEFAULT_CONFLICTED_BG_COLOR=9

# Symbols
PROMPTER_MOD_GIT_SYMBOL_DETACHED=$'\xe2\x9a\x93 ' # u2693  Anchor (needs a space after the symbol since it takes up 2 columns in the output)
PROMPTER_MOD_GIT_SYMBOL_AHEAD=$'\xe2\xac\x86' # u2B06 Up Arrow
PROMPTER_MOD_GIT_SYMBOL_BEHIND=$'\xe2\xac\x87' # u2B07 Down Arrow
PROMPTER_MOD_GIT_SYMBOL_STAGED=$'\xe2\x9c\x94' # u2714  Check mark
PROMPTER_MOD_GIT_SYMBOL_NOT_STAGED=$'\xe2\x9c\x8e' # u270E  Pencil
PROMPTER_MOD_GIT_SYMBOL_UNTRACKED=$'\xe2\x9d\x93' # u2753  Question mark
PROMPTER_MOD_GIT_SYMBOL_CONFLICTED=$'\xe2\x9c\xbc' # u273C  Asterix

function prompter_mod_git_short_desc()
{
  echo "Show the current status of the git repo at pwd, if any"
}

function prompter_mod_git_usage()
{
  cat <<EOF
Usage:
git [options]
Options:
--clean-fg-color       Foreground color to use for a repo that is clean
--clean-bg-color       Background color to use for a repo that is clean
--dirty-fg-color       Foreground color to use for a repo that is dirty
--dirty-bg-color       Background color to use for a repo that is dirty
--ahead-fg-color       Foreground color to use for a repo that is ahead
--ahead-bg-color       Background color to use for a repo that is ahead
--behind-fg-color      Foreground color to use for a repo that is behind
--behind-bg-color      Background color to use for a repo that is behind
--staged-fg-color      Foreground color to use when repo has staged files
--staged-bg-color      Background color to use when repo has staged files
--not-staged-fg-color  Foreground color to use when repo has not-staged files
--not-staged-bg-color  Background color to use when repo has not-staged files
--untracked-fg-color   Foreground color to use when has untracked files
--untracked-bg-color   Background color to use when repo has untracked files
--conflicted-fg-color  Foreground color to use for a repo that is conflicted
--conflicted-bg-color  Background color to use for a repo that is conflicted
EOF
}

# Wrapper around git binary to setup environment
function prompter_mod_git_exec_git()
{
  env -i LANG=C HOME=$HOME PATH=$PATH git "$@" 2>&1
  return $?
}

# Get git status. Add -b to get branch info. Written as a function to aid testability
function prompter_mod_git_status()
{
  prompter_mod_git_exec_git status --porcelain -b
}

# Get git tag. Written as a function to aid testability
function prompter_mod_git_describe()
{
  prompter_mod_git_exec_git describe --tags --always
}

function prompter_mod_git_emit_num()
{
  local num="$1"
  [[ -z $num || $num -eq 0 ]] && return

  [[ $num -eq 1 ]] && num=
  prompter_emit "$num$2" "$3" "$4"
}

function prompter_mod_git_main()
{
  # Extract arguments, use defaults if not given.
  # Get fg and bg colors for clean, dirty, ahead, behind, staged, not_staged, untracked and conflicted states
  local clean_fg_color=$PROMPTER_MOD_GIT_DEFAULT_CLEAN_FG_COLOR
  [[ -n $prompter_mod_git_arg_clean_fg_color ]] && clean_fg_color=$prompter_mod_git_arg_clean_fg_color
  local clean_bg_color=$PROMPTER_MOD_GIT_DEFAULT_CLEAN_BG_COLOR
  [[ -n $prompter_mod_git_arg_clean_bg_color ]] && clean_bg_color=$prompter_mod_git_arg_clean_bg_color
  local dirty_fg_color=$PROMPTER_MOD_GIT_DEFAULT_DIRTY_FG_COLOR
  [[ -n $prompter_mod_git_arg_dirty_fg_color ]] && dirty_fg_color=$prompter_mod_git_arg_dirty_fg_color
  local dirty_bg_color=$PROMPTER_MOD_GIT_DEFAULT_DIRTY_BG_COLOR
  [[ -n $prompter_mod_git_arg_dirty_bg_color ]] && dirty_bg_color=$prompter_mod_git_arg_dirty_bg_color
  local ahead_fg_color=$PROMPTER_MOD_GIT_DEFAULT_AHEAD_FG_COLOR
  [[ -n $prompter_mod_git_arg_ahead_fg_color ]] && ahead_fg_color=$prompter_mod_git_arg_ahead_fg_color
  local ahead_bg_color=$PROMPTER_MOD_GIT_DEFAULT_AHEAD_BG_COLOR
  [[ -n $prompter_mod_git_arg_ahead_bg_color ]] && ahead_bg_color=$prompter_mod_git_arg_ahead_bg_color
  local behind_fg_color=$PROMPTER_MOD_GIT_DEFAULT_BEHIND_FG_COLOR
  [[ -n $prompter_mod_git_arg_behind_fg_color ]] && behind_fg_color=$prompter_mod_git_arg_behind_fg_color
  local behind_bg_color=$PROMPTER_MOD_GIT_DEFAULT_BEHIND_BG_COLOR
  [[ -n $prompter_mod_git_arg_behind_bg_color ]] && behind_bg_color=$prompter_mod_git_arg_behind_bg_color
  local staged_fg_color=$PROMPTER_MOD_GIT_DEFAULT_STAGED_FG_COLOR
  [[ -n $prompter_mod_git_arg_staged_fg_color ]] && staged_fg_color=$prompter_mod_git_arg_staged_fg_color
  local staged_bg_color=$PROMPTER_MOD_GIT_DEFAULT_STAGED_BG_COLOR
  [[ -n $prompter_mod_git_arg_staged_bg_color ]] && staged_bg_color=$prompter_mod_git_arg_staged_bg_color
  local not_staged_fg_color=$PROMPTER_MOD_GIT_DEFAULT_NOT_STAGED_FG_COLOR
  [[ -n $prompter_mod_git_arg_not_staged_fg_color ]] && not_staged_fg_color=$prompter_mod_git_arg_not_staged_fg_color
  local not_staged_bg_color=$PROMPTER_MOD_GIT_DEFAULT_NOT_STAGED_BG_COLOR
  [[ -n $prompter_mod_git_arg_not_staged_bg_color ]] && not_staged_bg_color=$prompter_mod_git_arg_not_staged_bg_color
  local untracked_fg_color=$PROMPTER_MOD_GIT_DEFAULT_UNTRACKED_FG_COLOR
  [[ -n $prompter_mod_git_arg_untracked_fg_color ]] && untracked_fg_color=$prompter_mod_git_arg_untracked_fg_color
  local untracked_bg_color=$PROMPTER_MOD_GIT_DEFAULT_UNTRACKED_BG_COLOR
  [[ -n $prompter_mod_git_arg_untracked_bg_color ]] && untracked_bg_color=$prompter_mod_git_arg_untracked_bg_color
  local conflicted_fg_color=$PROMPTER_MOD_GIT_DEFAULT_CONFLICTED_FG_COLOR
  [[ -n $prompter_mod_git_arg_conflicted_fg_color ]] && conflicted_fg_color=$prompter_mod_git_arg_conflicted_fg_color
  local conflicted_bg_color=$PROMPTER_MOD_GIT_DEFAULT_CONFLICTED_BG_COLOR
  [[ -n $prompter_mod_git_arg_conflicted_bg_color ]] && conflicted_bg_color=$prompter_mod_git_arg_conflicted_bg_color

  local git_local_branch=
  local ahead_count=0
  local behind_count=0
  local untracked_count=0
  local staged_count=0
  local not_staged_count=0
  local conflicted_count=0
  local is_dirty=0

  # This has to be split in 2. local x=$(foo) means that in bash $? will be 0, irrespective of the return value of foo
  local git_status
  git_status=$(prompter_mod_git_status)
  [[ $? -eq 0 ]] || return 0
  
  # Get the first line from git_status
  local line=${git_status%%
*}

  if [[ "$line" != "## "* ]]
  then
    # git status seems to not be in the correct format. Abort
    return 0
  fi
  
  # Parse git status line. First remove leading '## '
  line=${line:3}
  if [[ "$line" == *"..."* ]]
  then
    git_local_branch=${line%%...*}
    line+=" "
    line=${line#* }
    if [[ -n $line ]]
    then
      if [[ $line == "[ahead "* ]]
      then
        line=${line#"[ahead "}
        if [[ $line == *"behind"* ]]
        then
          ahead_count=${line%%, *}
          line="["${line#*, }
        else
          ahead_count=${line%%"] "}
          line=
        fi
      fi
      if [[ -n $line ]]
      then
        line=${line#"[behind "}
        behind_count=${line%%"] "}
      fi
    fi
  elif [[ "$line" != *" "* ]]
  then
    git_local_branch=$line
  fi

  if [[ -z $git_local_branch ]]
  then
    # We are in detached state
    git_local_branch=$(prompter_mod_git_describe)
    [[ $? -eq 0 ]] || git_local_branch="<fresh repo>"
    git_local_branch="$PROMPTER_MOD_GIT_SYMBOL_DETACHED$git_local_branch"
  fi

  local first_line=1
  while IFS= read -r line
  do
    # Ignore the first line
    if [[ $first_line == "1" ]]
    then
      first_line=
      continue
    fi

    local code=${line:0:2}
    local first_char=${code:0:1}
    local second_char=${code:1:1}
    if [[ $code == "??" ]]
    then
      ((untracked_count++))
      is_dirty=1
    elif [[ $code == "DD" || $code == "AU" || $code == "UD" || $code == "UA" || $code == "DU" || $code == "AA" || $code == "UU" ]]
    then
      ((conflicted_count++))
      is_dirty=1
    else
      if [[ $second_char != " " ]]
      then
        ((not_staged_count++))
        is_dirty=1
      fi
      if [[ $first_char != " " ]]
      then
        ((staged_count++))
        is_dirty=1
      fi
    fi
  done <<< "$git_status"

  # Print the branch name, in the appropriate color if its clean or dirty
  if [[ $is_dirty == "1" ]]
  then
    prompter_emit "$git_local_branch" "$dirty_fg_color" "$dirty_bg_color"
  else
    prompter_emit "$git_local_branch" "$clean_fg_color" "$clean_bg_color"
  fi

  # Print the stats for different things (ahead, behind, untracked, etc.). Omit the segment if the number is 0. Hide the number itself if the number is 1.

  # Print aheah and behind stats
  # Special case the condition where we are both ahead and behind, and the colors are the same. since we don't want 2 prompt segments
  if [[ $ahead_count -gt 0 && $behind_count -gt 0 && $ahead_fg_color == $behind_fg_color && $ahead_bg_color == $behind_bg_color ]]
  then
    [[ $ahead_count -gt 1 ]] || ahead_count=
    [[ $behind_count -gt 1 ]] || behind_count=
    prompter_emit "$ahead_count$PROMPTER_MOD_GIT_SYMBOL_AHEAD  $behind_count$PROMPTER_MOD_GIT_SYMBOL_BEHIND" "$ahead_fg_color" "$ahead_bg_color"
  else
    prompter_mod_git_emit_num "$ahead_count" "$PROMPTER_MOD_GIT_SYMBOL_AHEAD" "$ahead_fg_color" "$ahead_bg_color"
    prompter_mod_git_emit_num "$behind_count" "$PROMPTER_MOD_GIT_SYMBOL_BEHIND" "$behind_fg_color" "$behind_bg_color"
  fi
  # Print the rest of the stats
  prompter_mod_git_emit_num "$staged_count" "$PROMPTER_MOD_GIT_SYMBOL_STAGED" "$staged_fg_color" "$staged_bg_color"
  prompter_mod_git_emit_num "$not_staged_count" "$PROMPTER_MOD_GIT_SYMBOL_NOT_STAGED" "$not_staged_fg_color" "$not_staged_bg_color"
  prompter_mod_git_emit_num "$untracked_count" "$PROMPTER_MOD_GIT_SYMBOL_UNTRACKED" "$untracked_fg_color" "$untracked_bg_color"
  prompter_mod_git_emit_num "$conflicted_count" "$PROMPTER_MOD_GIT_SYMBOL_CONFLICTED" "$conflicted_fg_color" "$conflicted_bg_color"
}

prompter_mod_git_options=("clean-fg-color:" "clean-bg-color:" "dirty-fg-color:" "dirty-bg-color:" "ahead-fg-color:" "ahead-bg-color:" "behind-fg-color:" "behind-bg-color:" "staged-fg-color:" "staged-bg-color:" "not_staged-fg-color:" "not_staged-bg-color:" "untracked-fg-color:" "untracked-bg-color:" "conflicted-fg-color:" "conflicted-bg-color:")