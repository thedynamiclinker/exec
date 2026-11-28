# Git calls a directory a tree and a file a blob.

git_id() {
    "${git_command:-git}" rev-parse --verify -q --end-of-options "$1" 2>/dev/null
}

git_revision() {
    local ref=$1
    [[ $ref && $ref != /* && $ref != . && $ref != ./* && $ref != .. && $ref != ../* ]] || return 1
    if [[ $tags ]]; then
        git_id "refs/tags/$ref" && return
    fi
    git_id "refs/heads/$ref" || git_id "$ref"
}

# Bash's idea of a relative pathname, measured from the root of the worktree.
git_path() {
    local path=$1 root prefix part result=
    prefix=$("${git_command:-git}" rev-parse --show-prefix 2>/dev/null) || return
    if [[ $path == /* ]]; then
        root=$("${git_command:-git}" rev-parse --show-toplevel 2>/dev/null) || return
        case $path in
            "$root") path= ;;
            "${root%/}/"*) path=${path#"${root%/}/"} ;;
            *) return 1 ;;
        esac
    else
        path=$prefix$path
    fi
    while [[ $path ]]; do
        part=${path%%/*}
        if [[ $path == */* ]]; then path=${path#*/}; else path=; fi
        case $part in
            ''|.) ;;
            ..) [[ $result ]] || return 1; result=${result%/*} ;;
            *) result+=/$part ;;
        esac
    done
    printf '%s\n' "${result#/}"
}

git_object_type() {
    kind=$("${git_command:-git}" cat-file -t "$object" 2>/dev/null) || return
    if [[ $kind == tag ]]; then
        object=$(git_id "$object^{}") || return
        kind=$("${git_command:-git}" cat-file -t "$object" 2>/dev/null) || return
    fi
    if [[ $kind == commit ]]; then
        object=$(git_id "$object^{tree}") || return
        kind=tree
    fi
    [[ $kind == tree || $kind == blob ]]
}

git_object_at() {
    # A trailing slash means directory.
    local tree=$1 path=$2
    object=$(git_id "$tree:${path%/}") && git_object_type || return
    [[ $path != */ || $kind == tree ]] || return
    object_parent=$tree object_path=${path%/}
}

git_object() {
    local arg=$1 ref path tree head_path
    object_parent= object_path=
    if [[ $arg == *:* && $arg != /* && $arg != ./* && $arg != ../* ]]; then
        ref=${arg%%:*}
        path=${arg#*:}
        if [[ $ref ]]; then
            if tree=$(git_revision "$ref"); then
                git_object_at "$tree" "$path"
                return
            fi
        else
            object=$(git_id "$arg") && git_object_type && return
        fi
    fi
    if object=$(git_revision "${arg%/}") && git_object_type &&
        [[ $arg != */ || $kind == tree ]]; then
        return
    fi
    if [[ $arg != /* && $arg != ./* && $arg != ../* ]]; then
        ref=${arg%/}
        while [[ $ref == */* ]]; do
            ref=${ref%/*}
            path=${arg#"$ref/"}
            if tree=$(git_revision "$ref"); then
                git_object_at "$tree" "$path"
                return
            fi
        done
    fi
    # Keep a trailing newline in a filename through command substitution.
    head_path=$(git_path "$arg" && printf .) || return
    head_path=${head_path%$'\n.'}
    git_object_at HEAD "$head_path" && [[ $arg != */ || $kind == tree ]]
}

# One record is either a quoted argument or four words from xargs.
git_operand() {
    local record='^[0-7]{6}[[:blank:]]+(blob|tree|commit)[[:blank:]]+([0-9a-f]{40}|[0-9a-f]{64})([[:blank:]]|$)'
    local hash='^([0-9a-f]{40}|[0-9a-f]{64})$'
    operand=$1
    consumed=1
    if [[ $1 =~ $record ]]; then
        operand=${BASH_REMATCH[2]}
    elif [[ $# -ge 4 && $1 =~ ^[0-7]{6}$ && $2 == @(blob|tree|commit) && $3 =~ $hash ]]; then
        operand=$3
        consumed=4
    fi
}

git_record() {
    local path=$2
    case $path in
        *$'\n'*|*$'\r'*) printf -v path '%q' "$path" ;;
    esac
    case $path in
        *[![:alnum:]_./:+,=@%-]*)
            # A single xargs word, even when the name contains quotes.
            path="'${path//\'/\'\\\'\'}'"
            ;;
    esac
    printf '%s\t%s\n' "$1" "$path"
}

git_object_error() {
    printf '%s: %s: expected %s\n' "${0##*/}" "$1" "$2" >&2
}

# Identify grep options that take a value, including -inA2 and --file=PATH.
git_grip_option() {
    local opt=$1 letter
    grep_arg= grep_prefix= grep_value=
    case $opt in
        --*)
            case ${opt%%=*} in
                --regexp) grep_arg=pattern ;;
                --file) grep_arg=file ;;
                --exclude-from) grep_arg=path ;;
                --after-context|--before-context|--binary-files|--context|--devices|--directories|--exclude|--exclude-dir|--group-separator|--include|--label|--max-count)
                    grep_arg=value ;;
            esac
            if [[ $opt == *=* ]]; then
                grep_prefix=${opt%%=*}=
                grep_value=${opt#*=}
            fi
            ;;
        -?*)
            for ((letter=1; letter<${#opt}; letter++)); do
                case ${opt:letter:1} in
                    e) grep_arg=pattern ;;
                    f) grep_arg=file ;;
                    [ABCDdm]) grep_arg=value ;;
                    *) continue ;;
                esac
                if ((letter+1 < ${#opt})); then
                    grep_prefix=${opt:0:letter+1}
                    grep_value=${opt:letter+1}
                fi
                break
            done
            ;;
    esac
    return 0
}
