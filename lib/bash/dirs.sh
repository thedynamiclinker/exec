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

    case "$1" in
        -|..) cd "$1"; return 0;;
    esac

    # Check to see if the argument is in the list of available dirs
    key="$1"
    val="${dirs["$key"]}"
    if dir_in_dirs "$key" && dir_exists "$key"; then
        pushd "$val" >/dev/null
        clip_prompt_if_its_super_long
        return 0
    elif dir_in_dirs "$key"; then
        echo "The key '$key' is in the dirs array,"
        echo "but this path doesn't exist: '$val'" >&2
        return 1
    elif dir_exists_raw "$key"; then
        pushd "$key" >/dev/null
        return 0
    else
        echo "error: ${FUNCNAME} could not figure out how to cd to: $key." >&2
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
    local possible_keys=($(echo ${!dirs[@]}))
    local curr_word="${COMP_WORDS[COMP_CWORD]}"
    local prev_word="${COMP_WORDS[COMP_CWORD - 1]}"
    COMPREPLY=($(compgen -W "${possible_keys[*]}" -- ${curr_word}))
}

_EXPERIMENTAL_bash_complete_using_dirs_array() {
    local possible_keys=($(echo ${!dirs[@]}))
    local curr_word="${COMP_WORDS[COMP_CWORD]}"
    local prev_word="${COMP_WORDS[COMP_CWORD - 1]}"
    if [[ ! ${curr_word} =~ .*/.* ]]; then
        # act normal for keys that don't end with a slash
        COMPREPLY=($(compgen -W "${possible_keys[*]}" -- ${curr_word}))
        return
    elif [[ ${curr_word} =~ .*/ ]]; then
        key="${curr_word%%/*}"     # turns 'a/b/c' into 'a'
        sub="${curr_word#$key/}"   # turns 'a/b/c' into 'b/c'
        val="${dirs["$key"]}"
        loc="$val$sub"
        rel=($(for path in $(ls $loc/); do echo /${path#$val}; done))
        #echo "key=$key"
        #echo "val=$val"
        #echo "sub=$sub"
        #echo "loc=$loc"
        #echo "abs=${abs[*]}"
        #echo
        for x in "${rel[*]}"; do echo "$x"; done
        #COMPREPLY=($(compgen -W "${abs[*]}" -- ${curr_word}))
        COMPREPLY=($(compgen -W "${rel[*]}" -- ${curr_word}))
    else
        key="${curr_word%%/*}"     # turns 'a/b/c' into 'a'
        sub="${curr_word#$key/}"   # turns 'a/b/c' into 'b/c'
        val="${dirs["$key"]}"
        loc="$val$sub"
        rel=($(for path in $(ls $loc/); do echo ${path#${val}/}; done))
        #echo "key=$key"
        #echo "val=$val"
        #echo "sub=$sub"
        #echo "loc=$loc"
        #echo "abs=${abs[*]}"
        echo
        for x in "${rel[*]}"; do echo "$x"; done
        #COMPREPLY=($(compgen -W "${abs[*]}" -- ${curr_word}))
        COMPREPLY=($(compgen -W "${rel[*]}" -- ${curr_word}))
    fi
}

is_bash && {
    complete -F _bash_complete_using_dirs_array p
    complete -F _bash_complete_using_dirs_array o
    complete -F _bash_complete_using_dirs_array c

    complete -F _bash_complete_using_dirs_array push
    complete -F _bash_complete_using_dirs_array pop # for fairness (lol)
}

