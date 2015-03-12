if [ "$BASH" != "" ]; then
    # useful
    function __source_if_exists() {
        [ -f $1 ] && . $1
    }

    ## http://aaroncrane.co.uk/2009/03/git_branch_prompt/
    function find_git_branch {
        local dir=. head
        until [ "$dir" -ef / ]; do
            if [ -f "$dir/.git/HEAD" ]; then
                head=$(< "$dir/.git/HEAD")
                if [[ $head == ref:\ refs/heads/* ]]; then
                    git_branch="${head#*/*/}"
                elif [[ $head != '' ]]; then
                    git_branch='(detached)'
                else
                    git_branch='(unknown)'
                fi
                return
            fi
            dir="../$dir"
        done
        git_branch=''
    }

    # Reset
    Color_Off='\e[0m'       # Text Reset

    # Regular Colors
    Black='\e[0;30m'        # Black
    Red='\e[0;31m'          # Red
    Green='\e[0;32m'        # Green
    Yellow='\e[0;33m'       # Yellow
    Blue='\e[0;34m'         # Blue
    Purple='\e[0;35m'       # Purple
    Cyan='\e[0;36m'         # Cyan
    White='\e[0;37m'        # White

    # Bold
    BBlack='\e[1;30m'       # Black
    BRed='\e[1;31m'         # Red
    BGreen='\e[1;32m'       # Green
    BYellow='\e[1;33m'      # Yellow
    BBlue='\e[1;34m'        # Blue
    BPurple='\e[1;35m'      # Purple
    BCyan='\e[1;36m'        # Cyan
    BWhite='\e[1;37m'       # White

    # Underline
    UBlack='\e[4;30m'       # Black
    URed='\e[4;31m'         # Red
    UGreen='\e[4;32m'       # Green
    UYellow='\e[4;33m'      # Yellow
    UBlue='\e[4;34m'        # Blue
    UPurple='\e[4;35m'      # Purple
    UCyan='\e[4;36m'        # Cyan
    UWhite='\e[4;37m'       # White

    # Background
    On_Black='\e[40m'       # Black
    On_Red='\e[41m'         # Red
    On_Green='\e[42m'       # Green
    On_Yellow='\e[43m'      # Yellow
    On_Blue='\e[44m'        # Blue
    On_Purple='\e[45m'      # Purple
    On_Cyan='\e[46m'        # Cyan
    On_White='\e[47m'       # White

    # High Intensity
    IBlack='\e[0;90m'       # Black
    IRed='\e[0;91m'         # Red
    IGreen='\e[0;92m'       # Green
    IYellow='\e[0;93m'      # Yellow
    IBlue='\e[0;94m'        # Blue
    IPurple='\e[0;95m'      # Purple
    ICyan='\e[0;96m'        # Cyan
    IWhite='\e[0;97m'       # White

    # Bold High Intensity
    BIBlack='\e[1;90m'      # Black
    BIRed='\e[1;91m'        # Red
    BIGreen='\e[1;92m'      # Green
    BIYellow='\e[1;93m'     # Yellow
    BIBlue='\e[1;94m'       # Blue
    BIPurple='\e[1;95m'     # Purple
    BICyan='\e[1;96m'       # Cyan
    BIWhite='\e[1;97m'      # White

    # High Intensity backgrounds
    On_IBlack='\e[0;100m'   # Black
    On_IRed='\e[0;101m'     # Red
    On_IGreen='\e[0;102m'   # Green
    On_IYellow='\e[0;103m'  # Yellow
    On_IBlue='\e[0;104m'    # Blue
    On_IPurple='\e[0;105m'  # Purple
    On_ICyan='\e[0;106m'    # Cyan
    On_IWhite='\e[0;107m'   # White


    export PROMPT_COMMAND="history -a"

    function set_bash_prompt {
        last_exit_code=$?
        find_git_branch
        PS1="\\[${Black}${On_White}\\]\\t"
        PS1+=" \\[${Color_Off}\\]\\u@\\h:\\W"
        if [ "${git_branch}" != "" ]; then
            PS1+=" \\[${Blue}\\](${git_branch}"
            if ! git diff --quiet --ignore-submodules HEAD; then
                PS1+="\\[${BIPurple}\\]*"
            fi
            PS1+="\\[${Blue}\\])"
        fi

        if [ "${last_exit_code}" != "0" ]; then
            PS1+=" \\[${BIRed}\\]${last_exit_code}"
        fi
        PS1+="\\[${Color_Off}\\] \\$ "
        export PS1
    }
    export PROMPT_COMMAND+="; set_bash_prompt"

    # Environment vars
    export HISTFILESIZE=4000000000
    export HISTSIZE=10000
    export HISTCONTROL="ignorespace:ignoredups"

    export CLICOLOR=1
    export EDITOR=vim
    export PATH=$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
    export VISUAL=vim
    [ -d ~/gocode ] && export GOPATH=~/gocode && export GOBIN=${GOPATH}/bin && export PATH=${GOBIN}:$PATH

    # Shell options
    shopt -s cdspell
    shopt -s checkwinsize
    shopt -s histappend
    shopt -s extglob
    set -o vi

    # Bash completion
    complete -C aws_completer aws

    # Aliases
    alias ls='ls -AF'
    alias tree='tree -CF --dirsfirst'

    alias be='bundle exec'

    # Misc includes
    if [ -e $HOME/.mac_bash_profile ]; then
        . $HOME/.mac_bash_profile
    fi

    [ -e $HOME/.bash_functions ] && . $HOME/.bash_functions
    [ -e $HOME/.withenv.bash ] && . $HOME/.withenv.bash

    __source_if_exists /usr/local/opt/chruby/share/chruby/chruby.sh && chruby 2.1

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
fi
