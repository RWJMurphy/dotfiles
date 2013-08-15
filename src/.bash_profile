# Environment vars
export AWS_CONFIG_FILE=~/.awsrc
export CLICOLOR=1
export EDITOR=vim
export PATH=$HOME/bin:$PATH
export VISUAL=vim


PS1='\[\e[0;32m\]\u@\h:\[\e[1;34m\]\w \[\e[1;32m\]\$ \[\e[0;37m\]'
if [ "`id -u`" -eq 0 ]; then
        PS1='\[\e[0;31m\]\u@\h \[\e[1;34m\]\w \[\e[0;31m\]\$ \[\e[0;37m\]'
fi

# Shell options
shopt -s cdspell histappend checkwinsize
set -o vi

# Aliases
alias ls='ls -AF'

# Misc includes
if [ -e $HOME/.mac_bash_profile ]; then
    . $HOME/.mac_bash_profile
fi

[ -e $HOME/.bash_functions ] && . $HOME/.bash_functions

if [ "$(hostname)" == "www.reedmurphy.net" ]; then
    ddate_format="Today is %{%A, the %e of %B%}, %Y. %. %N%nCelebrate %H!"
    fortune_files="bofh-excuses definitions goedel hitchhiker magic tao ascii-art"

    cat <(ddate +"$ddate_format") <(echo) <(fortune $fortune_files) | cowsay -n
fi

export AWS_CONFIG_FILE=~/.awsrc
