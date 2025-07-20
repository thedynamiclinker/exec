#!/bin/bash

# resolve aliases before passing them to cw, ew
resolve() {
    cmd_type="$(type -t "$1")"
    if [[ $cmd_type == 'alias' ]]; then
        fullname="$(alias "$1" | grep -Po "(?<=').*(?=')")"
    else
        fullname="$1"
    fi
    echo "$fullname"
}

# bash which
ew() { "$EDITOR" "$(which "$(resolve "$1")")"; }    # stands for "edit which"
cw() { cat "$(which "$(resolve "$1")")"; }          # stands for "cat which"
cddn() {
    loc="$(which "$(resolve "$1")")"
    dir="$(dirname "$loc")"
    pushd "$dir" >/dev/null
}

# python which
pw() { which.py "$1"; }
pew() { "$EDITOR" "$(which.py "$1")"; }
pcw() { cat "$(which.py "$1")"; }
pcddn() {
    loc="$(which.py "$1")"
    if [[ ! -d "$loc" ]]; then
        dir="$(dirname "$loc")"
    else
        dir="$loc"
    fi
    pushd "$dir" >/dev/null
}
