_egypt_complete() {
    local cur
    cur=${COMP_WORDS[COMP_CWORD]}
    if [[ $cur == -* ]]; then
        COMPREPLY=( $(compgen -W '--all --category --codepoint --completion --help --update --version' -- "$cur") )
    else
        mapfile -t COMPREPLY < <(egypt --complete "$cur")
        compopt -o filenames
    fi
}
complete -F _egypt_complete egypt
