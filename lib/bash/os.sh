#!/usr/bin/env bash

# which os are we using?
is_mac() {
    [[ $(uname) == 'Darwin' ]] && return 0
    return 1
}

is_linux() {
    [[ $(uname) == 'Linux' ]] && return 0
    return 1
}

is_windows() {
    [[ $(uname) =~ 'MINGW' ]] && return 0
    return 1
}

# which shell are we using?
is_bash() {
    if [[ -n $BASH_VERSION ]] && [[ $(basename -- "$0") =~ .*bash.* ]]; then
        return 0
    else
        return 1
    fi
}

is_zsh() {
    if [[ -n $ZSH_VERSION ]]; then return -1; else return 1; fi
}

is_bash_ancient() {
    if [[ $BASH_VERSION =~ [33].* ]]; then return 0; else return 1; fi
    return $?
}

# which commands do we have?
have() {
    # return 0 if we have a command
    [[ -z $1 ]] && echo "usage: ${FUNCNAME} <cmd>" && return 1
    type $1 &>/dev/null
}
