#!/usr/bin/env bash

source ps1.sh
source colors.sh

userprompt() {
    export PS1="$(echo "$PS1" | sed 's@\\u@user@')";
}

USERprompt() {
    export PS1="$(echo "$PS1" | sed 's@user@\\u@')";
}

dir_in_dirs() {
    local key="$1"
    local val="${dirs[$key]}"
    [[ -n "$val" ]]
}

dir_exists() {
    # returns true if dirs[$1] exists in the filesystem
    local key="$1"
    local val="${dirs[$key]}"
    [[ -d "$val" ]]
}

dir_exists_raw() {
    local key="$1"
    [[ -d "$key" ]]
}

dir_is_available() {
    local key="$1"
    local val="${dirs[$key]}"
    # need double bracket [[ ]] for the first one.
    [[ -n "$val" ]] && [[ -d "$val" ]]
}

c() {
    #################################
    ### This has to be a function ###
    #################################

    # Some things we'd like to add to ${dirs[@]}, but we don't
    # want it polluting the bash completion output, and we don't
    # want to make the code more complicated to compensate
    [[ -z $1 ]] && cd && return 0

    case $1 in
        -|..) cd "$1"; return 0;;
    esac

    # Check to see if the argument is in the list of available dirs
    key="$1"
    val="${dirs[$key]}"
    if dir_in_dirs $1 && dir_exists $1; then
        pushd "${dirs[$1]}" >/dev/null
        clip_prompt_if_its_super_long
        return 0
    elif dir_in_dirs $1; then
        echo "The key '${key}' is in the dirs array but this path doesn't exist: '$val'" >&2
        return 1
    elif dir_exists_raw "$1"; then
        # the dir exists but isn't in the dirs array
        pushd "$1" >/dev/null
        return 0
    else
        echo "The key ${key} is not in the list of available dirs." >&2
        return 2
    fi
}

p() {
    # prints the path corresponding to a key in the dirs array
    key="$1"
    val="${dirs[$key]}"
    if dir_in_dirs $1 && dir_exists $1; then
        echo "$val"
        return 0
    elif dir_in_dirs $1; then
        echo "The key ${key} is in the dirs array but this path doesn't exist: $val" >&2
        return 1
    else
        echo "The key ${key} is not in the list of available dirs." >&2
        return 2
    fi
}

ensure_in() {
    # a version of c that doesn't re-push "$1" onto dir stack if we're already in there
    if [[ "$(realpath "$PWD")" != "$(realpath "${dirs["$1"]}")" ]]; then c "$1"; fi
}

push() {
    local d="$1"
    pushd "${dirs[$d]}" >/dev/null
    dir="$(basename "$PWD")"
    printf "${whi}...${red}(${blu}${dir}${whi}${end}\n" >&2
}
pop() {
    dir="$(basename "$PWD")"
    popd >/dev/null
    printf "${whi}...${blu}${dir}${red})${end}\n\n" >&2
}


# bash completions

_bash_complete_using_dirs_array() {
    local possible_dirs=($(echo ${!dirs[@]}))
    local curr_word="${COMP_WORDS[COMP_CWORD]}"
    local prev_word="${COMP_WORDS[COMP_CWORD - 1]}"
    COMPREPLY=($(compgen -W "${possible_dirs[*]}" -- ${curr_word}))
}

is_bash && {
    complete -F _bash_complete_using_dirs_array p
    complete -F _bash_complete_using_dirs_array o
    complete -F _bash_complete_using_dirs_array c
    complete -F _bash_complete_using_dirs_array push
    complete -F _bash_complete_using_dirs_array pop # useless completion, but it's only fair
}

