#!/usr/bin/env bash

# Git's completion dispatch also finds _git_ls for `git ls`.
_git_ls() {
    local cur=${COMP_WORDS[COMP_CWORD]} parent= prefix= entry mode type hash name candidate
    COMPREPLY=()
    if [[ $cur == */* ]]; then
        parent=${cur%/*}/
        prefix=$parent
    fi
    while IFS= read -r -d '' entry; do
        read -r mode type hash <<< "${entry%%$'\t'*}"
        [[ $type == tree ]] || continue
        name=${entry#*$'\t'}
        candidate=$prefix$name/
        [[ $candidate == "$cur"* ]] && COMPREPLY+=("$candidate")
        # ./ requests the hashes alongside the directory names being listed.
        [[ $hash == "${cur##*/}"* ]] && COMPREPLY+=("$hash")
    done < <(git ls-tree --full-tree -z "HEAD:./${parent#./}" 2>/dev/null)
    compopt -o filenames -o nospace 2>/dev/null || :
}
complete -F _git_ls git-ls
