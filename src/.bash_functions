function mcd() {
    cd=$(echo $1 | sed 's/\(.\)/\/\1*/g')/
    dirs=`\ls -1d $cd 2>/dev/null`
    dira=($dirs)
    dircount=${#dira[*]}
    if [[ $dircount == 0 ]]; then
        echo "No match for ${cd}"
    elif [[ $dircount == 1 ]]; then
        echo cd ${dirs}
        cd "${dirs}"
    else
        if [ -z "$2" ]; then
            i=0
            for dir in $dirs; do
                echo $i $dir
                let "i += 1"
            done;
        else
            echo cd ${dira[$2]}
            cd "${dira[$2]}"
        fi
    fi
}
