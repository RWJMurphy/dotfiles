# vim: ft=sh sw=4 ts=4
function note() {
    NOTE_DIR=~/notes
    [ ! -d $NOTE_DIR ] && mkdir -p $NOTE_DIR

    subject=$*
    timestamp=$(date +'%Y/%m/%d %H:%M:%S')
    TEMPLATE="# ${subject:nil}
**Date**: ${timestamp}

"
    notefile=$NOTE_DIR/notes_$(date +'%Y_%m_%d').md
    line_no=$(grep -nF "# ${subject:nil}" $notefile 2>/dev/null | cut -d:  -f1 | head -1)
    [ "$line_no" == "" ] && line_no=0
    [ -f $notefile ] && TEMPLATE="\n$TEMPLATE"

    if [ "$line_no" == "0" ]; then
        echo -e "$TEMPLATE" >> $notefile
        line_no=
    else
        let line_no+=3
    fi
    $EDITOR $notefile +$line_no
}

function mcd() {
    exit_code=1
    [ $# == 0 ] && return $exit_code

    shopt nocaseglob >/dev/null
    nocase=$?
    [ $nocase = 1 ] && shopt -s nocaseglob >/dev/null

    magic=$(echo $1 | sed 's/\(.\)/\/\1*/g')/
    declare -a directories=($(\ls -1d $magic 2>/dev/null))
    directory_count=${#directories[*]}
    if [[ ${directory_count} == 0 ]]; then
        echo "No match for ${1}"
        exit_code=1
    elif [[ ${directory_count} == 1 ]]; then
        echo cd ${magic}
        cd ${magic}
        exit_code=$?
    else
        if [ -z "$2" ]; then
            i=0
            for dir in "${directories[@]}"; do
                echo $i $dir
                let "i += 1"
            done;
            exit_code=$i
        else
            echo cd ${directories[$2]}
            cd ${directories[$2]}
            exit_code=$?
        fi
    fi
    [ $nocase = 1 ] && shopt -u nocaseglob >/dev/null
    return $exit_code
}

function ffind() {
    if hash locate 2>/dev/null; then
        locate -i "$@" | grep -E "^${PWD}"
    else
        echo "Requires locate, sorry :(" >&2
    fi
}

# Syntax checks

function syntax-json() {
    while [[ $# > 0 ]]; do
        result=$(jq . <$1 2>&1 >/dev/null)
        if [ "$result" != "" ]; then
            echo $1 - $result
        fi
        shift
    done
}

function syntax-sh() {
    exit_code=0
    while [[ $# > 0 ]]; do
        for shell in sh bash dash zsh; do
            if hash $shell 2>/dev/null; then
                errors=$($shell -n $1 2>&1)
                if [ "$errors" != "" ]; then
                    let exit_code++
                    echo -e "$shell -n $1\n$errors"
                fi
            fi
        done
        shift
    done
    return $exit_code
}

syntax-vcl() {
    exit_code=0
    check="/usr/local/opt/varnish/sbin/varnishd -C -f "
    while [[ $# > 0 ]]; do
        if ! $check $1 > /dev/null; then
            let exit_code++
        fi
        shift
    done
    return $exit_code
}
