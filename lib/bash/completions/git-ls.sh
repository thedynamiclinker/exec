#!/usr/bin/env bash

# Use the commands' resolver so completion browses the same historical trees.
source "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../../../bin/git-ls"

_git_ls_complete() {
    local cur cword start=1 base=HEAD directory first parent prefix= leaf ref object
    local entry mode type hash name candidate trim dequoted_word i
    local -a words
    COMPREPLY=()
    compopt +o default +o bashdefault 2>/dev/null || :
    if declare -F _get_comp_words_by_ref >/dev/null; then
        _get_comp_words_by_ref -n =: cur words cword
    else
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
        cur=${words[cword]}
    fi
    # Readline replaces only the text after a word break such as ':' or '='.
    trim=${cur%"${COMP_WORDS[COMP_CWORD]}"}
    if declare -F __git_dequote >/dev/null; then
        __git_dequote "$trim"
        trim=$dequoted_word
        for i in "${!words[@]}"; do
            __git_dequote "${words[i]}"
            words[i]=$dequoted_word
        done
        cur=${words[cword]}
    fi
    if [[ ${words[0]##*/} != git-ls && ${words[0]##*/} != git-cat ]]; then
        start=$((${__git_cmd_idx:-1} + 1))
    fi
    [[ ${words[start]:-} == -- ]] && ((start+=1))
    directory=$(git rev-parse --show-prefix 2>/dev/null)
    if ((cword > start)) && first=$(_git_ls_revision "${words[start]}") &&
            [[ $(git cat-file -t "$first") == tree ]]; then
        base=$first
        directory=
    fi
    if ((cword == start)); then
        while IFS= read -r ref; do
            [[ $ref == "$cur"* ]] && COMPREPLY+=("$ref/")
        done < <(
            printf '%s\n' HEAD
            if [[ $cur == refs/* ]]; then
                git for-each-ref --format='%(refname)'
            else
                git for-each-ref --format='%(refname:short)'
            fi
        )
    fi
    parent=.
    leaf=$cur
    if [[ $cur == */* ]]; then
        parent=${cur%/*}
        prefix=$parent/
        leaf=${cur##*/}
    elif [[ $cur == *:* ]]; then
        ref=${cur%%:*}
        if object=$(_git_ls_revision "$ref"); then
            parent=$ref:
            prefix=$parent
            leaf=${cur#*:}
        fi
    elif ((cword == start)) && [[ -n $cur ]] && object=$(_git_ls_revision "$cur") &&
            [[ $(git cat-file -t "$object") == tree && ! " ${COMPREPLY[*]} " == *" $cur/ "* ]]; then
        COMPREPLY+=("$cur/")
    fi
    if object=$(_git_ls_resolve "$parent" "$base" "$directory"); then
        while IFS= read -r -d '' entry; do
            read -r mode type hash <<< "${entry%%$'\t'*}"
            name=${entry#*$'\t'}
            [[ $name == .* && $leaf != .* ]] && continue
            candidate=$prefix$name
            [[ $type == tree ]] && candidate+=/
            [[ $name == "$leaf"* && " ${COMPREPLY[*]} " != *" $candidate/ "* ]] &&
                COMPREPLY+=("$candidate")
            if [[ ${#leaf} -ge 4 && $hash == "$leaf"* ]]; then
                candidate=$prefix$hash
                [[ $type == tree ]] && candidate+=/
                COMPREPLY+=("$candidate")
            fi
        done < <(git ls-tree --full-tree -z "$object" 2>/dev/null)
    fi
    compopt -o filenames +o nospace 2>/dev/null || :
    if ((${#COMPREPLY[@]} == 1)) && [[ ${COMPREPLY[0]} == */ ]]; then
        compopt -o nospace 2>/dev/null || :
    fi
    for i in "${!COMPREPLY[@]}"; do
        COMPREPLY[i]=${COMPREPLY[i]#"$trim"}
    done
}

# Git's dispatcher finds these for `git ls` and `git cat` too.
_git_ls() { _git_ls_complete; }
_git_cat() { _git_ls_complete; }
complete -F _git_ls git-ls
complete -F _git_cat git-cat
