# The shell evaluates its own builtins here so cd, functions, aliases, and
# variables have the usual lifetime. Python has its own persistent namespace.
nw_load_shell_rc() {
    nw_rc=$NSH_HOME/etc/nsh.bash
    nw_rc_current=
    if [ -r "$nw_rc" ]; then
        nw_rc_current=$(cat "$nw_rc") || return
        if [ "$nw_rc_current" != "${nw_rc_loaded:-}" ]; then
            "$nw_shell" -n "$nw_rc" && . "$nw_rc" || return
        fi
    fi
    nw_rc_loaded=$nw_rc_current
}

case $nw_language in
    nsh)
        nw_config=$NSH_HOME
        if [ -n "${BASH_VERSION:-}" ]; then shopt -s expand_aliases; fi
        nw_load_shell_rc || exit
        ;;
    shn) nw_config=$SHN_HOME ;;
    nhs) nw_config=${NHS_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/nhs} ;;
esac
nw_history=$nw_config/history
nw_readline=
if [ -n "${BASH_VERSION:-}" ]; then
    nw_readline=-e
    if [ "${BASH_VERSINFO[0]}" -gt 5 ] ||
        { [ "${BASH_VERSINFO[0]}" -eq 5 ] && [ "${BASH_VERSINFO[1]}" -ge 3 ]; }; then
        nw_readline=-E
    fi
    if [ -r "$nw_history" ]; then builtin history -r "$nw_history"; fi
fi
nw_color=no
if [ -t 2 ] && [ -n "${TERM:-}" ] && [ "$TERM" != dumb ] && [ -z "${NO_COLOR:-}" ]; then
    nw_color=yes
fi
if [ "$nw_language" = nsh ] && [ -t 2 ] && [ "${TERM:-dumb}" != dumb ]; then
    if [ "$nw_color" = yes ]; then printf '\033[1;33mTHE NEW WORLD\033[0m  ·  ' >&2
    else printf 'THE NEW WORLD  ·  ' >&2; fi
    if [ -n "$nw_readline" ]; then
        printf '%s\n' ':help  ·  Tab completes  ·  Ctrl+R searches' >&2
    else
        printf '%s\n' ':help lists REPL commands' >&2
    fi
fi
nw_native_status=0
nw_source_line=0
nw_pending=
nw_compiled=
nw_last=
trap 'nw_interrupted=yes' INT

nw_read_line() {
    nw_interrupted=
    # Give Readline its own process so Ctrl+C can discard input without
    # losing the working directory, definitions, or history in the REPL.
    (
        trap 'exit 130' INT
        nw_line=
        nw_status=0
        if [ -n "$nw_readline" ]; then
            IFS= read "$nw_readline" -r -p "$1" nw_line || nw_status=$?
        else
            printf '%s' "$1" >&2
            IFS= read -r nw_line || nw_status=$?
        fi
        printf '%s' "$nw_line" > "$nw_work/line"
        exit "$nw_status"
    )
    nw_read_status=$?
    if [ "$nw_read_status" -eq 130 ] || [ -n "$nw_interrupted" ]; then
        nw_line=
        return 130
    fi
    nw_line=$(cat "$nw_work/line")
    [ "$nw_read_status" -eq 0 ] || [ -n "$nw_line" ]
}

nw_remember() {
    case $1 in
        ''|' '*) return ;;
    esac
    if [ -n "${BASH_VERSION:-}" ]; then builtin history -s "$1"; fi
    (umask 077; mkdir -p "$nw_config"; printf '%s\n' "$1" >> "$nw_history")
}

nw_reply() {
    nw_agent "$nw_turn_primer" "$nw_original" < "$nw_work/context" > "$nw_work/reply" || return
    IFS= read -r nw_marker < "$nw_work/reply"
    case $nw_marker in
        @ask)
            nw_pending=yes
            sed '1d' "$nw_work/reply" >&2
            printf 'Agent question:\n' >> "$nw_work/context"
            sed '1d' "$nw_work/reply" >> "$nw_work/context"
            return 0 ;;
        @code)
            case $nw_mode in c|a) ;; *) cat "$nw_work/reply"; return ;; esac
            sed '1d' "$nw_work/reply" > "$nw_work/correction"
            if [ -s "$nw_work/correction" ] && nw_native_check "$nw_work/correction"; then
                nw_compiled=yes
                cat "$nw_work/correction"
                printf '%s\n' 'Use :run to execute this correction or :link NAME to save it.' >&2
                return 0
            fi
            printf '%s\n' 'The correction failed native validation.' >&2
            return 2 ;;
        @fail)
            sed '1d' "$nw_work/reply" >&2
            return 1 ;;
        *)
            if [ "$nw_mode" = c ] || [ "$nw_mode" = a ]; then
                printf '%s\n' 'The backend did not follow the turn protocol.' >&2
                return 2
            fi
            cat "$nw_work/reply" || return
            if [ "$nw_language" = nsh ] && [ "$nw_permission" = write ]; then
                nw_load_shell_rc && hash -r
            fi ;;
    esac
}

nw_restore_status() { return "$1"; }
nw_run_native() {
    nw_native_status_before=$nw_native_status
    nw_native_status=0
    nw_source_invalid=no
    printf '%s\n' "$1" > "$nw_work/source"
    if nw_native_check "$nw_work/source" "$nw_source_offset" "<repl>" 2> "$nw_work/error"; then
        case $nw_language in
            nsh)
                nw_restore_status "$nw_native_status_before"
                eval "$1" 2> "$nw_work/error"
                nw_native_status=$? ;;
            *)
                case $nw_language in
                    shn) speech_program '<repl>' no "$nw_source_offset" 3< "$nw_work/source" 2> "$nw_work/error" ;;
                    *) nw_native_run "$nw_work/source" 2> "$nw_work/error" ;;
                esac
                nw_native_status=$? ;;
        esac
    else
        nw_source_invalid=yes
        nw_native_status=65
    fi
    cat "$nw_work/error" >&2
}

nw_count_source() {
    nw_source_offset=$nw_source_line
    case $1 in
        *'
'*) nw_source_line=$((nw_source_line + $(printf '%s\n' "$1" | wc -l))) ;;
        *) nw_source_line=$((nw_source_line + 1)) ;;
    esac
}

while :; do
    nw_shown_permission=$nw_permission
    case $nw_mode in c|a) nw_shown_permission=text ;; esac
    nw_prompt="$nw_name[$nw_mode:$nw_strictness:$nw_effort:$nw_shown_permission]"
    if [ "$nw_language" = shn ]; then nw_prompt="$nw_prompt $((nw_source_line + 1))"; fi
    if [ -n "$nw_pending" ]; then nw_prompt="$nw_prompt?"; fi
    if [ "$nw_language" = nsh ]; then
        nw_directory=$PWD
        case $nw_directory in
            "$HOME") nw_directory='~' ;;
            "$HOME"/*) nw_directory="~/${nw_directory#"$HOME"/}" ;;
        esac
        if [ -n "$nw_readline" ]; then
            case $nw_directory in *[[:cntrl:]]*) nw_directory=$(printf '%q' "$nw_directory") ;; esac
        fi
        nw_status_label=
        if [ "$nw_native_status" -ne 0 ]; then nw_status_label=" [$nw_native_status]"; fi
        if [ "$nw_color" = yes ] && [ -n "$nw_readline" ]; then
            PS1=$(printf '\001\033[1;33m\002%s\001\033[0;36m\002 %s\001\033[0m\002%s> ' \
                "$nw_prompt" "$nw_directory" "$nw_status_label")
        else
            PS1="$nw_prompt $nw_directory$nw_status_label> "
        fi
    else
        PS1="$nw_prompt> "
    fi
    if nw_read_line "$PS1"; then :
    else
        nw_read_status=$?
        printf '\n' >&2
        if [ "$nw_read_status" -ne 130 ]; then exit "$nw_native_status"; fi
        nw_pending= nw_compiled= nw_native_status=130
        continue
    fi

    case $nw_line in
        :help) nw_usage; continue ;;
        :quit|:exit) exit "$nw_native_status" ;;
        :cancel) nw_pending= nw_compiled=; nw_native_status=0; continue ;;
        c|a|r|l|:mode\ *)
            nw_choice=${nw_line#* }
            case $nw_choice in
                c|a|r|l) nw_mode=$nw_choice; nw_pending= ;;
                *) printf '%s\n' 'Use c, a, r, or l for the mode.' >&2 ;;
            esac
            continue ;;
        up)
            if [ "$nw_effort" -lt 5 ]; then nw_effort=$((nw_effort + 1)); fi
            continue ;;
        dn)
            if [ "$nw_effort" -gt 0 ]; then nw_effort=$((nw_effort - 1)); fi
            continue ;;
        :nitpick\ *)
            nw_choice=${nw_line#* }
            case $nw_choice in
                0|1|2) nw_strictness=$nw_choice; nw_pending= ;;
                *) printf '%s\n' 'Use a nitpick level from 0 to 2.' >&2 ;;
            esac
            continue ;;
        :effort\ *)
            nw_set_effort "${nw_line#* }" || printf '%s\n' 'Use an effort level from 0 to 5.' >&2
            continue ;;
        :permission\ *)
            nw_choice=${nw_line#* }
            case $nw_choice in
                text|read|write) nw_permission=$nw_choice ;;
                *) printf '%s\n' 'Use text, read, or write for permission.' >&2 ;;
            esac
            continue ;;
        :answer\ *)
            if [ -z "$nw_pending" ]; then printf '%s\n' 'There is no pending question.' >&2; continue; fi
            nw_line=${nw_line#* } ;;
        :link\ *)
            if [ -n "$nw_compiled" ]; then nw_target=$nw_work/correction
            elif [ -n "$nw_last" ]; then nw_target=$nw_work/last
            else printf '%s\n' 'There is no source to link.' >&2; continue; fi
            nw_link "${nw_line#* }" "$nw_target"
            nw_native_status=$?
            continue ;;
        :run)
            if [ -n "$nw_compiled" ]; then
                nw_line=$(cat "$nw_work/correction")
                nw_count_source "$nw_line"
                nw_run_native "$nw_line"
                if [ "$nw_native_status" -eq 0 ]; then cp "$nw_work/correction" "$nw_work/last"; nw_last=yes; fi
                nw_compiled=
            else
                printf '%s\n' 'There is no correction to run.' >&2
            fi
            continue ;;
        :paste)
            nw_paste=
            while nw_read_line '... ' && [ -n "$nw_line" ]; do
                nw_paste=${nw_paste:+$nw_paste
}$nw_line
            done
            if [ "$nw_read_status" -eq 130 ] || [ -n "$nw_interrupted" ]; then
                nw_pending= nw_compiled= nw_native_status=130
                printf '\n' >&2
                continue
            fi
            nw_line=$nw_paste
            ;;
        lord\ auth\ login|lord\ auth\ login\ *|lord\ auth\ status|lord\ auth\ status\ *)
            if [ "$nw_language" = nsh ]; then
                nw_count_source "$nw_line"
                (nw_restore_status "$nw_native_status"; eval "$nw_line")
                nw_native_status=$?
                continue
            fi ;;
        ld.so\ *)
            if [ "$nw_language" = nsh ]; then
                nw_source_line=$((nw_source_line + 1))
                nw_restore_status "$nw_native_status"
                eval "${nw_line#* }"
                nw_native_status=$?
                continue
            fi ;;
        :*) printf '%s\n' 'Unknown REPL command. Use --help for commands.' >&2; continue ;;
    esac

    [ -n "$nw_line" ] || continue
    nw_remember "$nw_line"
    if [ -n "$nw_pending" ]; then
        nw_pending=
        printf 'User answer:\n%s\n' "$nw_line" >> "$nw_work/context"
        nw_reply
        nw_native_status=$?
        continue
    fi

    nw_count_source "$nw_line"
    nw_compiled=
    nw_last=yes
    printf '%s\n' "$nw_line" > "$nw_work/last"
    nw_original=$nw_line
    nw_turn_primer=$nw_primer
    if [ "$nw_language" = nsh ] && nw_infix "$nw_line"; then
        if [ "$nw_mode" = r ]; then
            nw_run_infix 3< "$nw_work/stages"
            nw_native_status=$?
            continue
        fi
        nw_turn_primer=@
        printf 'Directory: %s\nSource line: %s\nNative result: not run (semantic stages)\n' \
            "$PWD" "$((nw_source_offset + 1))" > "$nw_work/context"
        nw_reply
        nw_native_status=$?
        continue
    fi
    nw_run_native "$nw_line"
    if [ -n "$nw_interrupted" ]; then nw_native_status=130; continue; fi
    if [ "$nw_native_status" -eq 0 ] || [ "$nw_strictness" = 2 ] || [ "$nw_mode" = l ]; then continue; fi
    if [ "$nw_strictness" = 1 ] && [ "$nw_source_invalid" = no ]; then
        case "$nw_language:$nw_native_status" in nsh:126|nsh:127) ;; *) continue ;; esac
    fi
    {
        printf 'Directory: %s\nSource line: %s\nNative status: %s\nDiagnostic:\n' "$PWD" "$((nw_source_offset + 1))" "$nw_native_status"
        tail -c 4096 "$nw_work/error"
    } > "$nw_work/context"
    nw_reply
    nw_native_status=$?
done
