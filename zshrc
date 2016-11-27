#!/bin/zsh
stty stop undef -echo # Get rid of annoying C-S and turn off echo while loading

# source plugins
function {
    local file
    for file in "$XDG_CONFIG_HOME/zsh/plugins/"*/*.plugin.zsh; do
        . "$file"
    done
}

# Config Plugins
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=blue,bold"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=blue"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=green"
ZSH_HIGHLIGHT_STYLES[alias]="fg=cyan,bold"
ZSH_HIGHLIGHT_STYLES[command]="fg=cyan,bold"
ZSH_HIGHLIGHT_STYLES[function]="fg=cyan,bold"

# {{{ Completion
# Custom completions
fpath=("$XDG_CONFIG_HOME/zsh/completions" $fpath)

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*:-tilde-:*' tag-order named-directories
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache

zstyle ':completion:*' menu select

# Kill and killall
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always
zstyle ':completion:*:*:kill:*:processes' command 'ps haxopid:5,user:4,%cpu:4,ni:2,stat:3,etime:8,args'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*'   force-list always


# }}}

# {{{ Glob completion etc.

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zcompdump"

compdef -d adb # Broken
# }}}

# {{{ History
HISTFILE="$XDG_DATA_HOME/shell/history"
HISTSIZE=1000
SAVEHIST=1000
# }}}

# {{{ Remove sudo tty ticket on exit
zshexit() {
    cd /
    sudo -k
}
# }}}

# {{{ Source external configs
function {
    local file=
    # Source anything for zsh (color functions etc)
    for file in $XDG_CONFIG_HOME/zsh/autoload/*.zsh; do
        . $file
    done
}
# }}}

# Disable globbing on some commands
alias pkg='noglob pkg'
alias git='noglob git'
alias find='noglob find'
alias pacman='noglob pacman'

# Override
alias wcalc='noglob wcalc -C'
alias calc='noglob wcalc -C'

# Re-enable echoing
stty echo

# vim: set foldmethod=marker:
