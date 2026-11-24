# Native line-oriented speech. The vocabulary, including aliases, is data.
speech_diagnostic() {
    printf '%s:%s: %s\n' "$speech_source" "$speech_number" "$*" >&2
}

define() (
    case $1 in
        ''|.*|/*|*/.*|*//*|*[!a-zA-Z0-9_./\ -]*|*/) exit 2 ;;
        */*) ;;
        *) exit 2 ;;
    esac
    remaining=$SHN_DICT_PATH:
    while [ -n "$remaining" ]; do
        dir=${remaining%%:*}
        remaining=${remaining#*:}
        [ -n "$dir" ] && [ -r "$dir/$1.md" ] || continue
        [ "$speech_check" = yes ] || cat "$dir/$1.md"
        exit
    done
    exit 2
)

speech_line() (
    text=$1
    [ "${#text}" -le "$SHN_MAX_LINE" ] || {
        speech_diagnostic "line exceeds $SHN_MAX_LINE characters"
        exit 65
    }
    case ${text%%:*} in
        ''|*[!0-9]*) ;;
        *) case $text in *:*) text=${text#*:} ;; esac ;;
    esac
    hops=0
    tab=$(printf '\t')
    while :; do
        IFS=" $tab" read -r verb rest <<EOF_LINE
$text
EOF_LINE
        case $verb in ''|'#'*) exit 0 ;; esac
        [ -r "$SHN_HOME/etc/aliases" ] || break
        expansion=$(awk -F '\t' -v alias_name="$verb" '$1 == alias_name { sub(/^[^\t]*\t/, ""); value=$0 } END { print value }' "$SHN_HOME/etc/aliases")
        [ -n "$expansion" ] || break
        hops=$((hops + 1))
        [ "$hops" -le 16 ] || { speech_diagnostic "alias cycle at $verb"; exit 65; }
        text="$expansion $rest"
    done

    case $verb in
        say) [ "$speech_check" = yes ] || printf '%s\n' "$rest"; exit ;;
        input)
            [ -z "$rest" ] || { speech_diagnostic 'input takes no arguments'; exit 65; }
            [ "$speech_check" = yes ] || cat
            exit ;;
        define)
            define "$rest" || { speech_diagnostic "unknown dictionary entry: $rest"; exit 65; }
            exit ;;
        run)
            IFS=" $tab" read -r verb rest <<EOF_ACTION
$rest
EOF_ACTION
            ;;
    esac

    case $verb in
        ''|.*|*[!a-zA-Z0-9_.-]*) speech_diagnostic "invalid command: $verb"; exit 65 ;;
    esac
    remaining=$SHN_PATH:
    while [ -n "$remaining" ]; do
        dir=${remaining%%:*}
        remaining=${remaining#*:}
        [ -n "$dir" ] && [ -f "$dir/$verb" ] && [ -x "$dir/$verb" ] || continue
        [ "$speech_check" = yes ] && exit 0
        # Speech commands take whitespace-separated words. Use native sh
        # when a program needs shell quoting, globbing, or expansion.
        set -f
        IFS=" $tab"
        exec "$dir/$verb" $rest
    done
    speech_diagnostic "undefined command: $verb"
    exit 65
)

speech_program() {
    speech_source=$1 speech_check=$2
    speech_number=${3:-0}
    # Program text stays on fd 3 so input is available to each statement.
    while IFS= read -r verse <&3 || [ -n "$verse" ]; do
        speech_number=$((speech_number + 1))
        speech_line "$verse" 3<&- || return
    done
}

speech_setup() {
    SHN_HOME=${SHN_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/shn}
    SHN_MAX_LINE=${SHN_MAX_LINE:-120}
    SHN_PATH=${SHN_PATH:-"$SHN_HOME/bin:$HOME/bin:$nw_share/../speech/bin"}
    SHN_DICT_PATH=${SHN_DICT_PATH:-"$SHN_HOME/dict:$nw_share/../dict:$nw_share/../dict/sudocode:/usr/local/share/dict/sudocode:/usr/share/dict"}
    if [ -r "$SHN_HOME/etc/shnrc" ]; then . "$SHN_HOME/etc/shnrc"; fi
    case $SHN_MAX_LINE in ''|*[!0-9]*) nw_fail 'SHN_MAX_LINE must be a positive integer' ;; esac
    [ "$SHN_MAX_LINE" -gt 0 ] || nw_fail 'SHN_MAX_LINE must be a positive integer'
}
