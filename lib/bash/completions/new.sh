#!/usr/bin/env bash

_new() {
    local finddir="$HOME/Templates/"
    if [[ ! -e "$finddir" ]]; then
        return
    fi
    local files=( $(find -L "$finddir" -maxdepth 1 -type f | sed "s@${finddir}@@" | sort) )
    local aliases=( $(new --list) )
    local completions=()
    completions+=(${files[@]})
    completions+=(${aliases[@]})
    local cur_word="${COMP_WORDS[COMP_CWORD]}"
    local prev_word="${COMP_WORDS[COMP_CWORD-1]}"
    COMPREPLY=($(compgen -W "${completions[*]}" -- ${cur_word}))
}

complete -F _new new
