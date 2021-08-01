if ! [[ "$INSIDE_EMACS" =~ "comint" ]]; then
    bindkey -v
    bindkey "\e[A" history-beginning-search-backward
    bindkey "\e[B" history-beginning-search-forward
    bindkey -a "k" history-beginning-search-backward
    bindkey -a "j" history-beginning-search-forward
    bindkey "^R" history-incremental-search-backward
    bindkey '^A' vi-beginning-of-line
    bindkey '^E' vi-end-of-line
    bindkey '^Y' yank
    bindkey -a 'u' undo
    bindkey -a '^r' redo
    bindkey "^W" backward-kill-word    # vi-backward-kill-word
    bindkey "^H" backward-delete-char  # vi-backward-delete-char
    bindkey "^U" backward-kill-line    # vi-kill-line
    bindkey "^?" backward-delete-char  # vi-backward-delete-char

    # remap Y to yank to EOL, like it always should have been.
    bindkey -a 'Y' vi-yank-eol

    export KEYTIMEOUT=1
fi
