export ZSH=/usr/share/oh-my-zsh # from aur repo

export DISABLE_MAGIC_FUNCTIONS=true
export DISABLE_UNTRACKED_FILES_DIRTY=true
plugins=(docker sudo)

source $ZSH/oh-my-zsh.sh

export HISTSIZE=5000000
export SAVEHIST=5000000
unsetopt nomatch

function optional_source() { [ -s "$1" ] && source "$1" }
optional_source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
optional_source /usr/share/fzf/completion.zsh
optional_source /usr/share/fzf/key-bindings.zsh

local ret_status="%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%})"

function get_pwd(){
  git_root=$PWD
  while [[ $git_root != / && ! -e $git_root/.git ]]; do
    git_root=$git_root:h
  done
  if [[ $git_root = / ]]; then
    unset git_root
    prompt_short_dir=%~
  else
    parent=${git_root%\/*}
    prompt_short_dir=${PWD#$parent/}
  fi
  echo $prompt_short_dir
}

PROMPT='$ret_status%n@%m %{$fg[white]%}$(get_pwd)$(git_prompt_info)%{$reset_color%}%{$reset_color%} λ '
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[cyan]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}✓%{$reset_color%}"

alias g="git"
alias gs="git status -sb"
alias t="tig"
alias ts="tig status"
alias tw="timew"

# muscle memory ftw
alias vim=$EDITOR
alias vi=$EDITOR

alias dk="docker"
alias dkc="docker-compose"
alias dogger="docker-compose down -v && docker-compose pull && docker-compose up -d"

alias xc="xclip -sel clip"

if which fasd > /dev/null; then
  eval "$(fasd --init auto)"
  alias c="fasd_cd -d"
fi
if which exa > /dev/null; then
  alias ll="exa -la"
else
  alias ll="ls -lah"
fi
