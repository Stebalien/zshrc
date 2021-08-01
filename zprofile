if [ -r ~/.profile ]; then
    . ~/.profile
elif [ -r $XDG_CONFIG_HOME/profile ]; then
    . $XDG_CONFIG_HOME/profile
fi
