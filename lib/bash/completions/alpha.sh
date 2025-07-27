#!/usr/bin/env bash

_alpha() {
    local longopts=(  $(alpha --list longopts ) )
    local shortopts=( $(alpha --list shortopts) )
    local charsets=(  $(alpha --list charsets)  )
    local cur_word="${COMP_WORDS[COMP_CWORD]}"
    local prev_word="${COMP_WORDS[COMP_CWORD-1]}"

    # Complete to module names when the previous word is an option
    local listables=(charsets longopts shortopts)
    case $prev_word in
        -l|--list)  COMPREPLY=( $(compgen -W "${listables[*]}"  -- ${cur_word}) ); return;;
    esac

    # Completions for everything else
    case $cur_word in
        --*)        COMPREPLY=( $(compgen -W "${longopts[*]}"  -- ${cur_word}) ); return;;
        -*)         COMPREPLY=( $(compgen -W "${shortopts[*]}" -- ${cur_word}) ); return;;
        *)          COMPREPLY=( $(compgen -W "${charsets[*]}"  -- ${cur_word}) ); return;;
    esac
}

complete -F _alpha alpha
