#!/bin/zsh

umask 077

m="/run/media/$USER"
: ~m
r="${XDG_RUNTIME_DIR:-/run/user/$UID}"
: ~m

setopt no_hup
