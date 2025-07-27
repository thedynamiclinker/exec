#!/usr/bin/env bash

# array functions
contains() {

    # usage:
    #
    # $ array=(a b c d)
    # $ contains a "${array[@]}" && echo yes || echo no
    # yes
    # $ contains g "${array[@]}" && echo yes || echo no
    # no
    # $ contains ab "${array[@]}" && echo yes || echo no
    # no

    match="$1"
    shift
    for x in "$@"; do
        if [[ "$x" == "$match" ]]; then
            return 0
        fi
    done
    return 1
}

containsmatch() {

    # usage:
    #
    # $ array=(a b c d)
    # $ containsmatch a "${array[@]}" && echo yes || echo no
    # yes
    # $ containsmatch g "${array[@]}" && echo yes || echo no
    # no
    # $ containsmatch "a b" "${array[@]}" && echo yes || echo no
    # yes

    match="$1"
    shift
    if [[ "$@" =~ "$match" ]]; then
        return 0
    else
        return 1
    fi
}

