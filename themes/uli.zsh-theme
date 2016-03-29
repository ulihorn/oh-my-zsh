
# Outputs current branch info in prompt format
function git_prompt_info() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(parse_git_dirty_pre)${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}


# Checks if working tree is dirty
function parse_git_dirty_pre() {
  local STATUS=''
  local FLAGS
  FLAGS=('--porcelain')
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [[ $POST_1_7_2_GIT -gt 0 ]]; then
      FLAGS+='--ignore-submodules=dirty'
    fi
    if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
      FLAGS+='--untracked-files=no'
    fi
    STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  fi
  if [[ -n $STATUS ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY_PRE"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN_PRE"
  fi
}

function git_prompt_infos() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(parse_git_dirty)\ue0a0$(current_branch)$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function get_pwd() {
  print -D $PWD
}

function get_cwd() {
  basename $PWD
}

function battery_charge() {
  if [ -e ~/bin/batcharge.py ]
  then
    echo `python ~/bin/batcharge.py`
  else
    echo ''
  fi
}

function put_spacing() {
  local git=$(git_prompt_info)
  if [ ${#git} != 0 ]; then
    ((git=${#git} - 10))
  else
    git=0
  fi

  local bat=$(battery_charge)
  if [ ${#bat} != 0 ]; then
    ((bat = ${#bat} - 18))
  else
    bat=0
  fi

  local termwidth
  (( termwidth = ${COLUMNS} - 3 - ${#HOST} - ${#$(get_pwd)} - ${bat} - ${git} ))

  local spacing=""
  for i in {1..$termwidth}; do
    spacing="${spacing} " 
  done
  echo $spacing
}

#function precmd() {
#print -rP '
#$fg[cyan]%m: $fg[yellow]$(get_pwd)$(git_prompt_info)' 
#}

PROMPT='$fg[cyan]$USER@%m:$fg[yellow]%1~$(git_prompt_info)%{$reset_color%} '
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX="$reset_color"
ZSH_THEME_GIT_PROMPT_DIRTY_PRE="$fg[red]"
ZSH_THEME_GIT_PROMPT_CLEAN_PRE="$fg[green]"
ZSH_THEME_GIT_PROMPT_DIRTY="✘ "
ZSH_THEME_GIT_PROMPT_CLEAN="✔ "
