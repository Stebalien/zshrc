#!/bin/zsh

quote_emacs() {
    echo "\"${1//\"/\\\"}\""
}

if [[ "$INSIDE_EMACS" =~ "\bcomint\b" ]]; then
    unsetopt zle
elif [[ "$TERM" =~ "^eterm\b" ]] ; then
    bindkey -e
elif [[ "$INSIDE_EMACS" == "vterm" ]]; then
    vterm_printf(){
        if [ -n "$TMUX" ]; then
            # Tell tmux to pass the escape sequences through
            # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
            printf "\ePtmux;\e\e]%s\007\e\\" "$1"
        elif [ "${TERM%%-*}" = "screen" ]; then
            # GNU screen (screen, screen-256color, screen-256color-bce)
            printf "\eP\e]%s\007\e\\" "$1"
        else
            printf "\e]%s\e\\" "$1"
        fi
    }
    alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
    vterm_prompt_end() {
        vterm_printf "51;A$(print -nP '%n@%m:%~')";
    }
    setopt PROMPT_SUBST
    PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'
fi

if [[ -n "$INSIDE_EMACS" ]]; then
    export PAGER=eless
    export GIT_EDITOR=emacsclient
    export PATH="$HOME/.config/emacs/bin:$PATH"

    man() {
        if [[ -t 1 ]]; then
            command emacsclient -n -e "(man $(quote_emacs "$*"))" >/dev/null
        else
            command man "$@"
        fi
    }
    cal() {
        if [[ -t 1 ]] && [[ "$#" -eq 0 ]]; then
            command emacsclient -n -e '(calendar)' >/dev/null
        else
            command cal "$@"
        fi
    }
fi
