# vim: ft=sh sw=4 ts=4
function kid() {
    query="$*"
    q_b64=$(echo -n "$*" | base64 | tr -d "\n")
    curl -s http://www.commandlinefu.com/commands/matching/$query/$q_b64/json | jq -r 'sort_by(.votes | tonumber) | reverse | .[:5][] | "#" + .summary + " (" + .votes + ")", .command, ""'

}
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

function notev() {
    NOTE_DIR=~/notes
    if [ "$1" != "" ]; then
        notefile=$(grep -il "$*" $NOTE_DIR/notes_*.md | tail -1)
    fi
    if [ "$notefile" == "" ]; then
        notefile=$(ls $NOTE_DIR/notes_*.md | tail -1)
    fi
    md_preview $notefile
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
        db=$(locate -S | grep -E "^Database" | cut -d\  -f2 | sed 's/://')
        db_modtime=$(date -r $(stat -f '%m' $db) +'%Y-%m-%d %H:%M:%S')
        echo "Using db $db, $db_modtime" >&2
        locate -i "$@" | grep -E "^${PWD}"
    else
        find "$PWD" -iname "*$@*"
    fi
}

function retry() {
    # retry [--limit,-l] [--delay,-d] [--] command args..
    [ $# -lt 1 ] && echo "return [--limit MAX_TRIES] [--delay SECONDS] [--] commands [args...]" >&2 && return

    LIMIT=5
    DELAY=5
    while [[ $# > 0 ]]; do
        case $1 in
            --limit|-l)
                shift
                LIMIT=$1
                ;;
            --delay|-d)
                shift
                DELAY=$1
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
        shift
    done
    command=$1;shift
    args="$*"

    success=1
    while true; do
        $command $args
        success=$?
        [ $success -eq 0 ] && break
        let LIMIT--
        [ $LIMIT -eq 0 ] && break
        echo "failed -- sleeping for $DELAY" >&2
        sleep $DELAY
    done
}

function srm {
    while [[ $# > 0 ]]; do
        fsize=$(stat -f '%z' "$1")
        for x in {1..5}; do
            dd if=/dev/random of="$1" count=1 bs=$fsize conv=notrunc >/dev/null 2>&1
        done
        rm -f "$1"
        shift
    done
}

# Syntax checks

function syntax() {
    while [[ $# > 0 ]]; do
        case $1 in
            *.rb)
                syntax-ruby $1
                ;;
            *.sh)
                syntax-sh $1
                ;;
            *.json)
                syntax-json $1
                ;;
            *.vcl)
                syntax-vcl $1
                ;;
            *.pp)
                syntax-puppet $1
                ;;
            *)
                echo "Not sure how to validate $1" >&2
                ;;
        esac
        shift
    done
}

function syntax-puppet() {
    case $(puppet --version) in
        2.*)
            puppet="puppet --parseonly"
            ;;
        3.*)
            puppet="puppet parser validate"
            ;;
        *)
            echo "Unsupported puppet version." >&2
            return 1;
            ;;
    esac
    while [[ $# > 0 ]]; do
        $puppet $1
        shift
    done
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

function syntax-ruby() {
    while [[ $# > 0 ]]; do
        ruby -c $1 > /dev/null
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

akamai_curl() {
    curl -i -H "Pragma: akamai-x-cache-on, akamai-x-cache-remote-on, akamai-x-check-cacheable, akamai-x-get-cache-key, akamai-x-get-extracted-values, akamai-x-get-nonces, akamai-x-get-ssl-client-session-id, akamai-x-get-true-cache-key, akamai-x-serial-no" "$@"
    echo
}

json2yaml() {
    ruby -rJSON -rYAML -e 'puts YAML.dump(JSON.load(STDIN.read))'
}

yaml2json() {
    ruby -rJSON -rYAML -e 'puts JSON.pretty_generate(YAML.load(STDIN.read))'
}

git-filespark() {
    exit_code=0;
    path="$1";
    if [ -z "$path" ]; then
        exit_code=1;
        echo "$0 [path]";
        return $exit_code;
    fi;
    echo -n "+ ";
    git log --oneline --numstat --follow "$path" | grep -F "$path" | cut -f1 | spark;
    echo -n "- ";
    git log --oneline --numstat --follow "$path" | grep -F "$path" | cut -f2 | sed -e 's/^/-/' | spark;
    return $exit_code
}

gos() {
    # ahahaha wtf reed
    imports=()
    while [[ $# > 0 ]]; do
        case $1 in
            --import|-i)
                shift
                imports+=($1)
                ;;
            --)
                break
                ;;
            *)
                break
                ;;
        esac
        shift
    done
    f=$(mktemp -t goscript)
    mv $f ${f}.go
    f=${f}.go
    echo "package main" >> $f
    for i in "${imports[@]}"; do
        echo "import \"$i\"" >> $f
    done
    echo "func main() { " >> $f
    echo "$*" >> $f
    echo "}" >> $f
    go run $f
    if [ $? -eq 0 ]; then
        rm $f
    fi
}
