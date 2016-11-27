#!/usr/bin/zsh

_email-lbdbq() {
    reply=(${(f)"$(notmuch-addrlookup $PREFIX | awk -F'\t' '(NR!=1) {print($2 ":" $1);}')"})
    return 300
}

fpath=("$XDG_CONFIG_HOME/zsh/Completion" $fpath)
