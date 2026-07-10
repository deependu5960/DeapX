# DeapX OS default user shell configuration
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export EDITOR=nano
export VISUAL=nano
