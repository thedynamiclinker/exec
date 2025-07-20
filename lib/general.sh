#!/bin/bash

# dirname functions
cddn() {
    pushd "$(dirname "$1")" >/dev/null;
}      # stands for "cd dirname"

# chmod functions
chx() { chmod +x "$@" 2>/dev/null || sudo chmod +x "$@"; }
chX() { chmod -x "$@" 2>/dev/null || sudo chmod -x "$@"; }

# enter a directory, creating it if necessary
enter() {
    [[ -z "$1" ]] && echo "usage: ${FUNCNAME} <new-dir>" && return
    mkdir -p "$1" && pushd "$1" 2>/dev/null
}

# silly
unixjoke() {
    cat << "EOF"
    unzip; strip; touch; grep;
    finger; mount; fsck;
    more; yes; umount; sleep;
EOF
}

