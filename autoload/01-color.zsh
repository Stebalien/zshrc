#!/bin/zsh
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors

    # ls
    eval $(dircolors -b)

    # Diff
    function diff() {
        if [[ -t 1 ]]; then
            colordiff $@
        else
            command diff $@
        fi
    }

    function ip() {
        if [[ -t 1 ]]; then
            command ip -c $@
        else
            command ip $@
        fi
    }
    # Less
    export LESS_TERMCAP_mb=$'\E[01;31m'
    export LESS_TERMCAP_md=$'\E[01;38;5;74m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[38;5;246m'
    export LESS_TERMCAP_ue=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[04;38;5;146m'

    export LS_COLORS="$LS_COLORS:di=36:*.swp=37:*.pyo=37:*.pyc=37:*.java=32:*.py=32:*.lua=32:*.c=32:*.html=32:*.css=32:*.js=32:*.rst=32"
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

    command_not_found_handler() {
        print "\e[1;31mcommand not found:\e[0m $@"
        return 0
    }
fi

