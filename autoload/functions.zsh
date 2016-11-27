alias -g @C='$(xclip -o -selection CLIPBOARD)'
alias -g @S='$(xclip -o)'

# ls
#alias ls='ls -hF --color=auto --group-directories-first'
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'
alias exa='exa --group-directories-first'
alias ls='exa'
alias ll='ls -lg'
alias la='ls -a'

# Grep
alias grep='grep --color=auto --binary-files=without-match --directories=skip'

# ipython: awesome python interpreter
python() {
    if [ $# -eq 0 ]; then
        ipython
    else
        command python $@
    fi
}

# Update Pacman
alias uu='pkg u'

# tools
alias lsgroup='cat /etc/group'
alias lsuser='cat /etc/passwd'
alias spell='aspell -a <<< '
alias bc='bc -l'
alias wcalc="wcalc -C --remember"
alias calc="wcalc"
alias whois="whois -H"

alias open='xdg-open'

alias www='python -m http.server --bind 127.0.0.1 8888'

alias journalctl='SYSTEMD_PAGER="less -F" journalctl'

alias c='units -1t'
alias emacs='emacs -n'

p() {
    local PIDS
    if [ $# -gt 0 ]; then
        PIDS=($(pgrep -f "$@")) || return
        ps --forest -o user,pid,stime,cmd ${PIDS}
    else
        ps --forest -eo user,pid,stime,cmd
    fi
}

