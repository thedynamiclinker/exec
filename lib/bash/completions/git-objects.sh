# Git's completion dispatch calls _git_<command> for external commands too.
source "${BASH_SOURCE[0]%/*}/../git-objects.sh"

_git_ls()   { _git_objects_complete ls; }
_git_cat()  { _git_objects_complete cat; }
_git_find() { _git_objects_complete find; }
_git_grip() { _git_objects_complete grip; }

_git_objects_add() {
    local candidate=$1 existing
    [[ $candidate == "$word"* ]] || return 0
    candidate=${candidate#"$trim"}
    for existing in "${COMPREPLY[@]}"; do
        [[ $candidate == "$existing" ]] && return 0
    done
    COMPREPLY+=("$candidate")
}

_git_objects_refs() {
    local ref type peeled
    local namespaces=(refs/heads) strip=refs/heads/
    if [[ $word == refs/* ]]; then
        namespaces=(refs/heads refs/remotes refs/tags)
        strip=
    elif [[ $tags ]]; then
        namespaces=(refs/tags)
        strip=refs/tags/
    elif [[ $word == */* ]]; then
        namespaces+=(refs/remotes)
    fi
    [[ $tags || $word == */* ]] || _git_objects_add HEAD/
    while IFS=$'\t' read -r ref type peeled; do
        ref=${ref#"$strip"}
        if [[ $strip == refs/heads/ ]]; then ref=${ref#refs/remotes/}; fi
        case ${peeled:-$type} in
            blob) [[ $tool == ls ]] || _git_objects_add "$ref" ;;
            commit|tree|tag) _git_objects_add "$ref/" ;;
        esac
    done < <("$git_command" for-each-ref --format='%(refname)%09%(objecttype)%09%(*objecttype)' "${namespaces[@]}" 2>/dev/null)
}

_git_objects_entries() {
    local entry mode type hash path
    while IFS= read -r -d '' entry; do
        read -r mode type hash <<< "${entry%%$'\t'*}"
        path=${entry#*$'\t'}
        case $type in
            tree) _git_objects_add "$parent$path/" ;;
            blob) [[ $tool == ls ]] || _git_objects_add "$parent$path" ;;
        esac
        if [[ $want_hashes && $type == @(blob|tree) ]] &&
            [[ $tool != ls || $type == tree ]] && [[ $tool != cat || $type == blob ]]; then
            _git_objects_add "$hash"
        fi
    done < <("$git_command" ls-tree --full-tree -z "$object" 2>/dev/null)
}

_git_objects_files() {
    local i path CDPATH=
    if [[ $git_command == __git && ${__git_C_args[*]:-} ]]; then
        for ((i=1; i<${#__git_C_args[@]}; i+=2)); do
            [[ ! ${__git_C_args[i]} ]] || builtin cd -- "${__git_C_args[i]}" 2>/dev/null || return
        done
    fi
    while IFS= read -r path; do
        [[ ! -d $path ]] || path=${path%/}/
        printf '%s\n' "$path"
    done < <(compgen -f -- "$word")
}

_git_objects_paths() {
    local parent= spec=. object kind object_parent object_path path hash type want_hashes=
    [[ $word == +([0-9a-f]) ]] && want_hashes=1
    case $word in
        */*) parent=${word%/*}/; spec=$parent ;;
        *:*) parent=${word%%:*}:; spec=$parent ;;
    esac
    [[ $spec == '~/'* ]] && spec=$HOME/${spec#\~/}

    if [[ $tool == grip ]]; then
        while IFS= read -r path; do
            _git_objects_add "$path"
        done < <(_git_objects_files)
    fi

    if [[ $word != /* && $word != ./* && $word != ../* && $word != *:* ]]; then
        _git_objects_refs
    fi
    if git_object "$spec" && [[ $kind == tree ]]; then
        _git_objects_entries
    fi
    if [[ $anchor && $word != /* && $word != *:* ]] &&
        git_object_at "$anchor" "$parent" && [[ $kind == tree ]]; then
        _git_objects_entries
    fi
    if [[ $want_hashes && ${#word} -ge 4 ]]; then
        while read -r hash type; do
            case $type in
                tree) [[ $tool == cat ]] || _git_objects_add "$hash" ;;
                blob) [[ $tool == ls ]] || _git_objects_add "$hash" ;;
            esac
        done < <("$git_command" rev-parse --disambiguate="$word" 2>/dev/null |
                 "$git_command" cat-file --batch-check='%(objectname) %(objecttype)' 2>/dev/null)
    fi
}

_git_objects_complete() {
    local tool=$1 git_command=git word arg trim= i start
    local tags= options=1 pending= pattern= anchor= first= count=0
    local grep_arg grep_prefix grep_value dequoted_word choices=

    if [[ ${__git_cmd_idx:-0} -gt 0 ]]; then
        git_command=__git
        start=$((__git_cmd_idx+1))
    else
        local words=("${COMP_WORDS[@]}") cword=$COMP_CWORD cur=${COMP_WORDS[COMP_CWORD]}
        if declare -F _get_comp_words_by_ref >/dev/null; then
            _get_comp_words_by_ref -n =: cur words cword
        fi
        start=1
    fi
    word=$cur
    if declare -F __git_dequote >/dev/null; then
        __git_dequote "$word"
        word=$dequoted_word
    fi
    COMPREPLY=()
    compopt +o default +o bashdefault +o nospace -o filenames 2>/dev/null || :

    for ((i=start; i<cword; i++)); do
        arg=${words[i]}
        if [[ $pending ]]; then pending=; continue; fi
        if [[ $options ]]; then
            case $arg in
                -t|--tags) tags=1; continue ;;
                --) options=; continue ;;
            esac
            case $tool in
                find)
                    case $arg in
                        -type|-name|-iname|-path|-ipath|-maxdepth|-mindepth) pending=$arg ;;
                    esac ;;
                grip)
                    if [[ $arg == -?* ]]; then
                        git_grip_option "$arg"
                        case $grep_arg in pattern|file) pattern=1 ;; esac
                        if [[ ! $grep_prefix ]]; then pending=$grep_arg; fi
                        continue
                    fi ;;
            esac
        fi
        if [[ $tool == grip ]]; then
            pattern=1
            [[ ${POSIXLY_CORRECT+x} ]] && options=
        elif [[ $arg != -* || ! $options ]]; then
            ((count++))
            [[ $first ]] || first=$arg
            [[ $tool == @(ls|cat) ]] && options=
        fi
    done

    if [[ $options && ! $pending && $word == -* ]]; then
        case $tool in
            ls) choices='-R --recursive' ;;
            find) choices='-type -name -iname -path -ipath -maxdepth -mindepth -print' ;;
            grip)
                git_grip_option "$word"
                if [[ $grep_prefix ]]; then
                    [[ $grep_arg == @(file|path) ]] || return
                    pending=file
                    word=$grep_value
                else
                    choices='-e -f -i -v -n -l -L -c -q -F -E -P -r -R -A -B -C -H -h --color --include --exclude --exclude-dir --file= --regexp='
                fi ;;
        esac
        if [[ ! $pending ]]; then
            for arg in -t --tags -h --help $choices; do _git_objects_add "$arg"; done
            return
        fi
    fi

    case $pending in
        -type)
            for arg in f d; do _git_objects_add "$arg"; done
            return ;;
        file|path)
            # A short option and its attached value are one readline word.
            if [[ $grep_prefix != *= ]]; then
                local attached=${grep_prefix:-}
            fi ;;
        '') [[ $tool != grip || $pattern ]] || return ;;
        *) return ;;
    esac

    if [[ $tool == @(ls|cat) && $count == 1 ]]; then
        if declare -F __git_dequote >/dev/null; then
            __git_dequote "$first"
            first=$dequoted_word
        fi
        anchor=$(git_revision "$first")
    fi
    if [[ $word == *:* && $COMP_WORDBREAKS == *:* ]]; then trim=${word%:*}:; fi
    if [[ $word == *=* && $COMP_WORDBREAKS == *=* && ${word##*=} != *:* ]]; then trim=${word%=*}=; fi
    _git_objects_paths
    if [[ ${attached:-} && ! $trim ]]; then
        for i in "${!COMPREPLY[@]}"; do COMPREPLY[i]=$attached${COMPREPLY[i]}; done
    fi
    if ((${#COMPREPLY[@]} == 1)) && [[ ${COMPREPLY[0]} == */ ]]; then
        compopt -o nospace 2>/dev/null || :
    fi
    return 0
}

complete -F _git_ls git-ls
complete -F _git_cat git-cat
complete -F _git_find git-find
complete -F _git_grip git-grip
