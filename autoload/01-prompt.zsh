#!/bin/zsh

setopt PROMPT_SUBST

# GIT
autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{8}+%F{3}s'
zstyle ':vcs_info:*' unstagedstr '%F{8}+%F{1}u'
zstyle ':vcs_info:*' actionformats '%F{8} • [%F{13}%b%c%u%F{8}|%F{1}%a%F{8}]%f'
zstyle ':vcs_info:*' formats       '%F{8} • [%F{13}%b%c%u%F{8}]%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git

case "$TERM" in
    linux-vt)
        # Broken with white themes for some reason.
        _zsh_prompt_cursor_insert() {
            #print -n '[?16;5;32;c'
        }

        _zsh_prompt_cursor_normal() {
            #print -n '[?16;5;96;c'
        }
        ;;
    xterm-*|alacritty|termite)
        _zsh_prompt_cursor_insert() {
            print -n '[6 q]12;#813e00\a'
        }

        _zsh_prompt_cursor_normal() {
            print -n '[2 q]12;#005e00\a'
        }
        ;;
    *)
        _zsh_prompt_cursor_insert() {}
        _zsh_prompt_cursor_normal() {}
        ;;
esac


_zsh_prompt_mode_info() {
    case $KEYMAP in
        vicmd) _zsh_prompt_mode_color="$ZSH_PROMPT_MODE_NORMAL" ;;
        *) _zsh_prompt_mode_color="$ZSH_PROMPT_MODE_INSERT" ;;
    esac
}

zle-keymap-select() {
    _zsh_prompt_mode_info
    zle reset-prompt
    case $KEYMAP in
        vicmd) _zsh_prompt_cursor_normal ;;
        *) _zsh_prompt_cursor_insert ;;
    esac
}

zle-line-finish() {
    _zsh_prompt_mode_color="$ZSH_PROMPT_MODE_RO"
    RPROMPT=""
    unset _zsh_prompt_line_inited

    zle reset-prompt
}

zle-line-init() {
    if [[ "$_zsh_prompt_line_inited" ]]; then
        echoti rc
    fi

    _zsh_prompt_cursor_insert

    _zsh_prompt_mode_info

    zle reset-prompt
    _zsh_prompt_line_inited=1
}

function TRAPINT {
    if [[ "$_zsh_prompt_line_inited" ]]; then
        # Do this up-down dance to prevent problems on the last line...
        echoti cud1
        echoti cuu1
        echoti sc
    fi
    return $(( 128 + $1 ))
}

preexec() {
    _zsh_prompt_command_has_run=1
    # Save the STTY before running anything so we can restore it.
    _zsh_saved_stty="$(stty -g)"
    # DO NOT CHANGE TO DOUBLE QUOTES. THAT WILL INTRODUCE A SECURITY VULNERABILITY !!!!!!
    if echoti tsl; then
       print -nP '%~: '
       printf "$1"
       echoti fsl
    fi
    _zsh_prompt_cursor_normal
}

precmd() {
    local saved_result=$?
    if [[ ! "$_zsh_prompt_command_has_run" ]]; then
        # Only show errors for actual commands
        saved_result=0
    fi
    unset _zsh_prompt_command_has_run

    # Reset term.
    echoti sgr0
    echoti rmacs

    # Restore the last saved STTY setting after running a command.
    if [[ -n "$_zsh_saved_stty" ]]; then
        stty "$_zsh_saved_stty"
        unset _zsh_saved_stty
    fi

    # Update title
    if echoti tsl; then
       print -nP "%~: _"
       echoti fsl
    fi

    # Update vcs stuff
    case "$(stat -f -c '%T' .)" in
        nfs|afs|fuse|proc|sysfs)
            vcs_info_msg_0_=""
            vcs_info_msg_1_=""
        ;;
        *) vcs_info ;;
    esac

    # Prompt stuff
    if [[ -n "$_zsh_prompt_seen_first" ]]; then
        # Hack to restore status
        function { return $1 } $saved_result
        print -rP "$ZSH_PROMPT_STATUS"
    else
        _zsh_prompt_seen_first=1
    fi

    print -rP "$ZSH_PROMPT_PRE"
    RPROMPT="$ZSH_PROMPT_JOBS"
    return 0
}

zle -N zle-keymap-select
zle -N zle-line-finish
zle -N zle-line-init

ZSH_PROMPT_LBRACE="["
ZSH_PROMPT_RBRACE="]"
if [[ "${TTY}" = /dev/tty[0-9]* ]]; then
        ZSH_PROMPT_LAMBDA=">:"
        ZSH_PROMPT_CONTINUE=".."
else
        ZSH_PROMPT_LAMBDA="᚛:"
        ZSH_PROMPT_CONTINUE="… "
fi

ZSH_PROMPT_STATUS="%(0?..%F{red,bold}⚠ %(1?..%F{8}%?)%f
)"
ZSH_PROMPT_PRE="%F{8}$ZSH_PROMPT_LBRACE%F{blue}%~%F{8}$ZSH_PROMPT_RBRACE\${vcs_info_msg_0_}"
ZSH_PROMPT_JOBS="%F{green}%(1j: %j:)%f"
ZSH_PROMPT_MODE_NORMAL="%F{yellow,bold}"
ZSH_PROMPT_MODE_INSERT="%F{green,bold}"
ZSH_PROMPT_MODE_RO="%F{magenta,bold}"

PROMPT="\${_zsh_prompt_mode_color}$ZSH_PROMPT_LAMBDA %f"
PROMPT2="\${_zsh_prompt_mode_color}$ZSH_PROMPT_CONTINUE %f"
