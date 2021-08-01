###########################################################################
# zsh mouse (and X clipboard) support v1.6
###########################################################################
#
# Copyright 2004-2011 Stephane Chazelas <stephane_chazelas@yahoo.fr>
#
# Permission to use, copy, modify, distribute, and sell this software and
# its documentation for any purpose is hereby granted without fee, provided
# that the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or
# implied warranty.

# SELECTION/CLIPBOARD FUNCTIONS

set-x-clipboard() { return 0; }
get-x-clipboard() { return 1; }

# find a command to read from/write to the X selections
if whence xclip > /dev/null 2>&1; then
  x_selection_tool="xclip -sel p"
  x_clipboard_tool="xclip -sel c"
elif whence xsel > /dev/null 2>&1; then
  x_selection_tool="xsel -p"
  x_clipboard_tool="xsel -b"
else
  x_clipboard_tool=
  x_selection_tool=
fi
if [[ -n $x_clipboard_tool ]]; then
    # FIXME: WTF? EVAL?
  eval '
    get-x-clipboard() {
      (( $+DISPLAY )) || return 1
      local r
      r=$('$x_clipboard_tool' -o < /dev/null 2> /dev/null && print .)
      r=${r%.}
      if [[ -n $r && $r != $CUTBUFFER ]]; then
	killring=("$CUTBUFFER" "${(@)killring[1,-2]}")
	CUTBUFFER=$r
      fi
    }
    set-x-clipboard() {
      (( ! $+DISPLAY )) ||
	print -rn -- "$1" | '$x_clipboard_tool' -i 2> /dev/null
    }
    push-x-cut_buffer0() {
      # retrieve the CUT_BUFFER0 property via xprop and store it on the
      # CLIPBOARD selection
      (( $+DISPLAY )) || return 1
      local r
      r=$(xprop -root -notype 8s \$0 CUT_BUFFER0 2> /dev/null) || return 1
      r=${r#CUT_BUFFER0\"}
      r=${r%\"}
      r=${r//\'\''/\\\'\''}
      eval print -rn -- \$\'\''$r\'\'' | '$x_clipboard_tool' -i 2> /dev/null
    }
    push-x-selection() {
      # puts the PRIMARY selection onto the CLIPBOARD
      # failing that call push-x-cut_buffer0
      (( $+DISPLAY )) || return 1
      local r
      if r=$('$x_selection_tool' -o < /dev/null 2> /dev/null && print .) &&
	r=${r%?} &&
	[[ -n $r ]]; then
	print -rn -- $r | '$x_clipboard_tool' -i 2> /dev/null
      else
	push-x-cut_buffer0
      fi
    }
  '
  # redefine the copying widgets so that they update the clipboard.
  for w in copy-region-as-kill vi-delete vi-yank vi-yank-eol vi-yank-whole-line vi-change vi-change-whole-line vi-change-eol vi-delete-char; do
    eval '
      '$w'() {
	zle .'$w'
	set-x-clipboard $CUTBUFFER
      }
      zle -N '$w
  done

  # that's a bit more complicated for those ones as we have to
  # re-implement the special behavior that does that if you call several
  # of those widgets in sequence, the text on the clipboard is the
  # whole text cut, not just the text cut by the latest widget.
  for w in ${widgets[(I).*kill-*]}; do
    if [[ $w = *backward* ]]; then
      e='$CUTBUFFER$scb'
    else
      e='$scb$CUTBUFFER'
    fi
    eval '
      '${w#.}'() {
	local scb=$CUTBUFFER
	local slw=$LASTWIDGET
	local sbl=${#BUFFER}

	zle '$w'
	(( $sbl == $#BUFFER )) && return
	if [[ $slw = (.|)(backward-|)kill-* ]]; then
	  killring=("${(@)killring[2,-1]}")
	  CUTBUFFER='$e'
	fi
	set-x-clipboard $CUTBUFFER
      }
      zle -N '${w#.}
  done
  
  zle -N push-x-selection
  zle -N push-x-cut_buffer0

  # put the current selection on the clipboard upon <Ctrl-Insert>
  # <Meta-Insert> <Ctrl-X>X or X:
  if (( $+terminfo[kSI] )); then
    bindkey -M emacs "$terminfo[kSI]" push-x-selection
    bindkey -M viins "$terminfo[kSI]" push-x-selection
    bindkey -M vicmd "$terminfo[kSI]" push-x-selection
  fi
  if (( $+terminfo[kich1] )); then
    # <Meta-Insert> according to terminfo
    bindkey -M emacs "\e$terminfo[kich1]" push-x-selection
    bindkey -M viins "\e$terminfo[kich1]" push-x-selection
    bindkey -M vicmd "\e$terminfo[kich1]" push-x-selection
  fi
  # hardcode ^[[2;3~ which is sent by <Meta-Insert> on xterm
  bindkey -M emacs '\e[2;3~' push-x-selection
  bindkey -M viins '\e[2;3~' push-x-selection
  bindkey -M vicmd '\e[2;3~' push-x-selection
  # hardcode ^[^[[2;5~ which is sent by <Meta-Insert> on some terminals
  bindkey -M emacs '\e\e[2~' push-x-selection
  bindkey -M viins '\e\e[2~' push-x-selection
  bindkey -M vicmd '\e\e[2~' push-x-selection

  # hardcode ^[[2;5~ which is sent by <Ctrl-Insert> on xterm
  # some terminals have already such a feature builtin (gnome/KDE
  # terminals), others have no distinguishable character sequence sent
  # by <Ctrl-Insert>
  bindkey -M emacs '\e[2;5~' push-x-selection
  bindkey -M viins '\e[2;5~' push-x-selection
  bindkey -M vicmd '\e[2;5~' push-x-selection

  # same for rxvt:
  bindkey -M emacs '\e[2^' push-x-selection
  bindkey -M viins '\e[2^' push-x-selection
  bindkey -M vicmd '\e[2^' push-x-selection

  # for terminals without an insert key:
  bindkey -M vicmd X push-x-selection
  bindkey -M emacs '^XX' push-x-selection

  # the convoluted stuff below is to work around two problems:
  #  1- we can't just redefine the widgets as then yank-pop would
  #  stop working
  #  2- we can't just rebind the keys to <Ctrl-Insert><other-key> as
  #  then we'll loose the numeric argument
  propagate-numeric() {
    # next key (\e[0-dum) is mapped to <Ctrl-Insert>, plus the
    # targeted widget with NUMERIC restored.
    case $KEYMAP in
      vicmd)
	bindkey -M vicmd -s '\e[0-dum' $'\e[1-dum'$NUMERIC${KEYS/x/};;
      *)
	bindkey -M $KEYMAP -s '\e[0-dum' $'\e[1-dum'${NUMERIC//(#m)?/$'\e'$MATCH}${KEYS/x/};;
    esac
  }
  zle -N get-x-clipboard
  zle -N propagate-numeric
  bindkey -M emacs '\e[1-dum' get-x-clipboard
  bindkey -M vicmd '\e[1-dum' get-x-clipboard
  bindkey -M emacs '\e[2-dum' yank
  bindkey -M emacs '\e[2-xdum' propagate-numeric
  bindkey -M emacs -s '^Y' $'\e[2-xdum\e[0-dum'
  bindkey -M vicmd '\e[3-dum' vi-put-before
  bindkey -M vicmd '\e[3-xdum' propagate-numeric
  bindkey -M vicmd -s 'P' $'\e[3-xdum\e[0-dum'
  bindkey -M vicmd '\e[4-dum' vi-put-after
  bindkey -M vicmd '\e[4-xdum' propagate-numeric
  bindkey -M vicmd -s 'p' $'\e[4-xdum\e[0-dum'
fi


