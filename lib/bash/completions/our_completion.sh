#!/usr/bin/env bash

# This is arguably the paradigmatic minimal bash completion.
_our() {
    local things=($(our --list))
    local cur_word="${COMP_WORDS[COMP_CWORD]}"
    local prev_word="${COMP_WORDS[COMP_CWORD - 1]}"
    COMPREPLY=( $(compgen -W "${things[*]}" -- ${cur_word}) )
}
complete -F _our our
