is_being_sourced() {
    if [[ "${BASH_SOURCE[0]}" != "${BASH_ARGV0}" ]]; then
        return 0
    else
        return 1
    fi
}

isatty() {
    local funcname="$FUNCNAME"
    _isatty_help() {
        echo "usage: ${funcname} [-h|--help] <0|1|2>"
        echo ""
        echo "Tells us if its argument file descriptor is a tty."
        echo "If no argument given, defaults to stdin."
        unset -f "${FUNCNAME}"
        return 2
    }
    case "$1" in
        -h|--help)  _isatty_help; return $?;;
    esac
    arg="$1"
    fd=${arg:-0}
    if [ -t "$fd" ]; then
        return 0
    else
        return 1
    fi
}

