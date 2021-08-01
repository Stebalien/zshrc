#!/bin/zsh

[[ -n "$INSIDE_EMACS" ]] || return 0

if [[ -n "$WINDOWID" ]] && [[ -n "$EXWM" ]]; then
    __exwm_chpwd() {
        # Only apply directory changes in the root shell.
        [[ "$ZSH_SUBSHELL" -eq 0 ]] || return
        # Emacsclient sets the 'default-directory' to the caller's CWD, so
        # this always works and saves us from having to pass it in (and escape
        # it).
        emacsclient -e "(exwm-set-window-directory $WINDOWID default-directory)" \
                    > /dev/null
    }
    __exwm_chpwd
    chpwd_functions+=(__exwm_chpwd)
fi

if [[ -n "$EXWM" ]]; then
    # CTRL-R - Paste the selected command from history into the command line
    emacs-history-widget() {
        local selected num
        setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
        selected=( $(fc -rl 1 | dmenu -p "Reverse-i-search:") )

        local ret=$?
        if [ -n "$selected" ]; then
            num=$selected[1]
            if [ -n "$num" ]; then
                zle vi-fetch-history -n $num
            fi
        fi
        zle reset-prompt
        return $ret
    }
    zle     -N   emacs-history-widget
    bindkey '^R' emacs-history-widget
fi
