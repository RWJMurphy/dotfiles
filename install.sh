#!/bin/sh
srcdir=$HOME/code/dotfiles/src

for file in $srcdir/.??*; do
    dest=$HOME/$(basename $file)
    if [ "$(basename $file)" = ".mac_bash_profile" ]; then
        if [ "$(uname)" != "Darwin" ]; then
            echo "Not on a mac - not installing $file" >&2
            continue
        fi
    fi
    if [ -e $dest ]; then
        if [ -h $dest ]; then
            echo "Not touching $dest - exists and is link" >&2
            continue
        else
            bak=$dest.$(date '+%Y%m%d')
            mv $dest $bak
            echo "Moved existing $dest to $bak" >&2
        fi
    fi
    ln -s $file $HOME/$(basename $file)
done
