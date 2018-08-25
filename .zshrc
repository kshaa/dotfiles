stty stop ""

# http://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout
#!/usr/bin/env zsh

precmd-color() {
    local -a colors
    (cat ~/.config/zsh/colors 2> /dev/null; echo '0 white white white' ) |
        ggrep -Em1 "^($(id -u)|$USER|$(hostname)) " | sed 's/^[^ ]* //'
}
precmdcolorcache="$(precmd-color)"
precmd-color() { echo "${precmdcolorcache}" }

precmd-realm() {
    local merightnow realm depth
    merightnow="$(pwd | sed "s:$HOME::")"
    realm="$(echo $merightnow | ggrep -Eo '^/[^/]+($|/[^/]+)' | cut -b2-)"
    depth="$(tr -cd '/' <<< "$merightnow" | wc -c)"

    if (( $depth < 2 )); then
        realm="%."
    elif (( $depth == 3 )); then
        realm="$realm/%."
    elif (( $depth > 3 )); then
        realm="$realm %."
    fi

    echo "$realm"
}

# PS1
precmd() {
    local fst snd thd git ruby
    git=""
    ruby="$(rbenv version 2> /dev/null | ggrep -Po '^\d\S+')"

    [ "$(id -u)" = "0" ] && sep=')' || sep='|'
    read fst snd thd <<< "$(precmd-color)"
    PS1="%F{${thd:-105}}%n$sep%F{$fst}%B$(precmd-realm)%b "

    if [ -n "$git" ]; then
        PS1="$PS1%F{$snd}$git%F{default} "
    fi

    if [ -n "$ruby" ]; then
        PS1="$PS1$ruby "
    fi

    PS1="$PS1%#%F{default} "
}
#!/usr/bin/env zsh

# ENV
export LANG=en_US.UTF-8 LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC=en_US.UTF-8
export EDITOR=vim
alias less=pager

# Git
export GITDIR="$HOME/.git"

alias phpd='php -dxdebug.remote_enable=1 -dxdebug.remote_mode=req -dxdebug.remote_port=9001 -dxdebug.remote_host=127.0.0.1'
alias ls='ls -G'
alias l='ls'
alias p='ping google.lv' # tired of writing this over and over again.

alias g=git
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gk='git checkout'
alias gr='git rebase'

alias tmux-alt-shell='tmux bind-key v new-window'

# Opts and history
DIRSTACKSIZE=8
setopt autocd autopushd pushdminus pushdsilent pushdtohome
setopt interactivecomments extendedglob
bindkey -e
HISTFILE=~/.histfile
HISTSIZE=1000000000
SAVEHIST=1000000000

# Completion:
# /^zstyle/: lets you complete `cd photos/2-party' into `photos/2015-party'.
autoload -Uz compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Fuzzy completion:
if [ -f /etc/profile.d/fzf.zsh ]; then
  . /etc/profile.d/fzf.zsh
  bindkey -r '^G'
  bindkey '^G^J' fzf-history-widget
  bindkey '^R' history-incremental-search-backward

  fzf-map-widget() {
    LBUFFER="$(eval "${LBUFFER}" | $(__fzfcmd))"
    hash xclip 2> /dev/null && xclip -se c <<< "${LBUFFER}"
    local ret=$?
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
    return $ret
  }
  zle     -N   fzf-map-widget
  bindkey '^G^K' fzf-map-widget
fi

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

