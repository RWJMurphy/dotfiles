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

function syntax-json() {
    while [[ $# > 0 ]]; do
        result=$(jq . <$1 2>&1 >/dev/null)
        if [ "$result" != "" ]; then
            echo $1 - $result
        fi
        shift
    done
}
