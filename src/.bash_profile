# useful
function __source_if_exists() {
    [ -f $1 ] && . $1
}

# Environment vars
export HISTFILESIZE=4000000000
export HISTSIZE=10000
export HISTCONTROL="ignorespace:ignoredups"
export PROMPT_COMMAND="history -a"

export AWS_CONFIG_FILE=~/.awsrc
export CLICOLOR=1
export EDITOR=vim
export PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
export VISUAL=vim
[ -d ~/gocode ] && export GOPATH=~/gocode

# Shell options
shopt -s cdspell
shopt -s checkwinsize
shopt -s histappend
shopt -s extglob
set -o vi

# Per-host $PS1
case "$(hostname -f)" in
    @(*.eqx.*|*.gyr.*))
    ;;
    *)
        PS1='\[\e[0;32m\]\u@\h:\[\e[1;34m\]\w \[\e[1;32m\]\$ \[\e[0;37m\]'
        if [ "$(id -u)" -eq 0 ]; then
            PS1='\[\e[0;31m\]\u@\h \[\e[1;34m\]\w \[\e[0;31m\]\$ \[\e[0;37m\]'
        fi
    ;;
esac

# Aliases
alias ls='ls -AF'
alias tree='tree -CF --dirsfirst'

alias be='bundle exec'

# Misc includes
if [ -e $HOME/.mac_bash_profile ]; then
    . $HOME/.mac_bash_profile
fi

[ -e $HOME/.bash_functions ] && . $HOME/.bash_functions

__source_if_exists /usr/local/opt/chruby/share/chruby/chruby.sh && chruby 1.9

# Finally, per-host stuff
case "$(hostname -f)" in
    www.reedmurphy.net)
        # Personal VPS greeting
        ddate_format="Today is %{%A, the %e of %B%}, %Y. %. %N%nCelebrate %H!"
        fortune_files="bofh-excuses definitions goedel hitchhiker magic tao ascii-art"
        cat <(ddate +"$ddate_format") <(echo) <(fortune $fortune_files) | cowsay -n
    ;;
    shell01.*)
        # Auto-tmux on bastion hosts
        [ "$TMUX" == "" ] && (tmux attach || tmux)
    ;;
    *)
    ;;
esac

# Really finally (shh), include any local, non-git-managed config
__source_if_exists $HOME/.bash_profile_local
