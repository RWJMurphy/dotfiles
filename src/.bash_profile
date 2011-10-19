export PATH=$HOME/bin:$PATH
export EDITOR=vim
export VISUAL=vim

export CLICOLOR=1

PS1='\[\e[0;32m\]\u@\h:\[\e[1;34m\]\w \[\e[1;32m\]\$ \[\e[0;37m\]'
if [ "`id -u`" -eq 0 ]; then
        PS1='\[\e[0;31m\]\u@\h \[\e[1;34m\]\w \[\e[0;31m\]\$ \[\e[0;37m\]'
fi

shopt -s cdspell histappend checkwinsize

alias ls='ls -AF'

if [ -e $HOME/.mac_bash_profile ]; then
    . $HOME/.mac_bash_profile
fi
