#!/bin/zsh

setopt PROMPT_SUBST

# GIT
autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{8}+%F{3}s'
zstyle ':vcs_info:*' unstagedstr '%F{8}+%F{1}u'
zstyle ':vcs_info:*' actionformats '%F{8} • [%F{10}%b%c%u%F{8}|%F{1}%a%F{8}]%f'
zstyle ':vcs_info:*' formats       '%F{8} • [%F{10}%b%c%u%F{8}]%f'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git

mode_info() {
    case $KEYMAP in
        vicmd) mode_color="$ZSH_PROMPT_MODE_NORMAL" ;;
        *) mode_color="$ZSH_PROMPT_MODE_INSERT" ;;
    esac
}

zle-keymap-select() {
    mode_info
    zle reset-prompt
}

zle-line-finish() {
    mode_color="$ZSH_PROMPT_MODE_RO"
    RPROMPT=""
    unset _prompt_line_inited

    zle reset-prompt
}

zle-line-init() {
    if [[ "$_prompt_line_inited" ]]; then
        tput rc
    fi

    mode_info

    zle reset-prompt
    _prompt_line_inited=1
}

function TRAPINT {
    if [[ "$_prompt_line_inited" ]]; then
        # Do this up-down dance to prevent problems on the last line...
        tput cud1
        tput cuu1
        tput sc
    fi
    return $(( 128 + $1 ))
}

preexec() {
    _prompt_command_has_run=1
}

precmd() {
    local saved_result=$?
    if [[ ! "$_prompt_command_has_run" ]]; then
        # Only show errors for actual commands
        saved_result=0
    fi
    unset _prompt_command_has_run

    # Reset term.
    tput -S <<EOF
sgr0
rmacs
EOF
    stty sane


    # Update vcs stuff
    case "$(stat -f -c '%T' .)" in
        nfs|afs|fuse|proc|sysfs) : ;;
        *) vcs_info ;;
    esac

    # Prompt stuff
    if [[ -n "$_prompt_seen_first" ]]; then
        # Hack to restore status
        function { return $1 } $saved_result
        print -rP "$ZSH_PROMPT_STATUS"
    else
        _prompt_seen_first=1
    fi

    print -rP "$ZSH_PROMPT_PRE"
    RPROMPT="$ZSH_PROMPT_JOBS"
    return 0
}

zle -N zle-keymap-select
zle -N zle-line-finish
zle -N zle-line-init


case "${TTY}" in
    /dev/tty[0-9]*)
        ZSH_PROMPT_LBRACE="["
        ZSH_PROMPT_RBRACE="]"
        ZSH_PROMPT_SEP="•"
        ZSH_PROMPT_LAMBDA=">"
        ;;
    *)
        ZSH_PROMPT_LBRACE="["
        ZSH_PROMPT_SEP="»"
        ZSH_PROMPT_RBRACE="]"
        ZSH_PROMPT_LAMBDA="𝝺"
        ;;
esac

ZSH_PROMPT_STATUS="%(?..$fg_bold[red]⛔$reset_color
)"
ZSH_PROMPT_PRE="$fg_bold[black]$ZSH_PROMPT_LBRACE$fg_bold[cyan]%n$fg_bold[blue]@%m$fg_bold[black]:$fg_bold[blue]%~$fg_bold[black]$ZSH_PROMPT_RBRACE\${vcs_info_msg_0_}"
ZSH_PROMPT_JOBS="%{$fg[green]%}%(1j: %j:)%{$reset_color%}"
#ZSH_PROMPT_TIMESTAMP="%{$fg[magenta]•%}%*%{$reset_color%}"
ZSH_PROMPT_MODE_NORMAL="%{$fg_bold[yellow]%}"
ZSH_PROMPT_MODE_INSERT="%{$fg[green]%}"
ZSH_PROMPT_MODE_RO="%{$fg[magenta]%}"

PROMPT="\${mode_color}$ZSH_PROMPT_LAMBDA: %{$reset_color%}"
PROMPT2="\${mode_color}$ZSH_PROMPT_LAMBDA. %{$reset_color%}"
