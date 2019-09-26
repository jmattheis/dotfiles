alias cd..="cd .."

alias g="git"
alias gs="git status"
alias ts="tig status"
alias t="tig"
alias jeff="git commit --fixup $1"
alias yolo="git commit -amUFF"
alias gg="g ll; gs"

alias vim=$EDITOR
alias vi=$EDITOR

alias dk="docker"
alias dkc="docker-compose"
alias dogger="docker-compose down -v && docker-compose pull && docker-compose up -d"

eval $(thefuck --alias)
alias f=fuck

alias xc="xclip -sel clip"

alias ssh="TERM=xterm-color ssh"

eval "$(fasd --init auto)"
alias v="f -e $EDITOR"
alias c="fasd_cd -d"
