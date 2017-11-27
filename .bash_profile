[ -r $HOME/.profile ] && source $HOME/.profile

# Source .bashrc if login shell is interactive
[[ $- =~ i ]] && [ -r $HOME/.bashrc ] && source $HOME/.bashrc
