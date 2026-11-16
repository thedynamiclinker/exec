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
    [[ -z $1 ]] && cd && return 0

    case "$1" in
        -|..) cd "$1"; return 0;;
    esac

    local path
    path=$(p "$1") || return
    pushd "$path" >/dev/null || return
    clip_prompt_if_its_super_long
    cd "$(realpath "$PWD")" # jesus...
}

p() {
    # The longest matching key wins: an explicit exec/etc key can point
    # somewhere other than the etc directory beneath exec.
    local key="${1:-}" suffix= path=
    while [[ -n $key ]]; do
        path="${dirs[$key]}"
        [[ -n $path ]] && break
        [[ $key == */* ]] || break
        suffix="/${key##*/}$suffix"
        key="${key%/*}"
    done

    if [[ -n $path ]]; then
        [[ -n $suffix ]] && path="${path%/}$suffix"
    elif [[ -d ${1:-} ]]; then
        path="$1"
    else
        echo "The key ${1:-} is not in the list of available dirs." >&2
        return 2
    fi

    if [[ ! -d $path ]]; then
        echo "The path doesn't exist: $path" >&2
        return 1
    fi
    printf '%s\n' "$path"
}

o() {
    local path
    if [[ -f ${1:-} ]]; then
        path="$1"
    else
        path=$(p "${1:-}") || return
    fi
    xdg-open "$path"
}

with() {
    # creates a symlink in the current directory to a directory in dirs
    local path
    path=$(p "${1:-}") || return
    ln -s -- "$path" .
}

ensure_in() {
    # a version of c that doesn't re-push "$1" onto dir stack if we're already in there
    local path
    path=$(p "${1:-}") || return
    if [[ "$(realpath "$PWD")" != "$(realpath "$path")" ]]; then c "$1"; fi
}

push() {
    local path dir
    path=$(p "${1:-}") || return
    pushd "$path" >/dev/null || return
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
    local word="${2-${COMP_WORDS[COMP_CWORD]}}" key parent path
    COMPREPLY=()

    # $2 has its opening quote removed. Decode unquoted backslash escapes
    # without eval; ordinary filesystem paths use Bash's native completion.
    if [[ ${COMP_WORDS[COMP_CWORD]} != [\'\"]* ]]; then
        IFS= read word <<< "$word"
    fi

    for key in "${!dirs[@]}"; do
        [[ $key == "$word"* ]] || continue
        if [[ $word == */* ]]; then
            COMPREPLY+=("${dirs[$key]}")
        else
            COMPREPLY+=("$key/")
        fi
    done

    [[ $word == */* ]] || return 0
    parent=$(p "${word%/*}" 2>/dev/null) || return 0
    [[ $parent != "${word%/*}" ]] || return 0
    parent="${parent%/}"
    # A shortcut shadows any directory with the same name in PWD.
    compopt +o dirnames 2>/dev/null || :

    # Real paths let Readline recognize directories and quote their names.
    # Once expanded, subsequent Tabs fall through to native directory completion.
    for path in "$parent"/"${word##*/}"*/; do
        [[ -d $path ]] || continue
        path="${path%/}"
        key="${word%/*}/${path##*/}"
        [[ -n ${dirs[$key]} ]] && continue
        COMPREPLY+=("$path")
    done
}

if [[ -n ${BASH_VERSION:-} ]]; then
    complete -o dirnames -o filenames -o nospace -F _bash_complete_using_dirs_array \
        c o p with push ensure_in
fi
