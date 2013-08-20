#!/bin/bash

# Be strict.
set -e
set -u

SRCDIR=$(cd "$(dirname "${0}")/src"; pwd -P)
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')

warn() {
    echo $* >&2
}

backup() {
    while [[ "$#" ]]; do
        backup_dest=$1.$TIMESTAMP
        warn "Moving $1 to $backup_dest"
        mv $1 $backup_dest
        shift
    done
}

find $SRCDIR -mindepth 1 -print | while read file; do
    dest=${HOME}/${file#${SRCDIR}/}
    basename=$(basename $file)

    # Directories
    if [ -d $file ]; then
        case $basename in
            .git)
            continue
            ;;
            *)
            ;;
        esac

        if [ -e $dest ]; then
            # Ignore directories that exist already
            if [ -d $dest ]; then
                continue
            else
                backup $dest
            fi
        fi
        mkdir -p $dest

    # Files
    elif [ -f $file ]; then
        case $basename in
            .mac_bash_profile)
            if [ "$(uname)" != "Darwin" ]; then
                warn "Not on a mac - not installing $file"
                continue
            fi
            ;;
            *)
            ;;
        esac

        if [ -e $dest ]; then
            # Ignore files that are linked correctly already
            if [ -h $dest -a "$(readlink $dest)" == $file ]; then
                continue
            else
                backup $dest
            fi
        fi
        ln -s $file $dest
    fi
done
