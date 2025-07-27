#!/usr/bin/env bash

if [[ -n $LIB_MIME_SH ]]; then
    return
fi

LIB_MIME_SH=1

get_default_application() {
    [[ -z $1 ]] && echo "usage: ${FUNCNAME} <mimetype>" && return 1
    DOT_DESKTOP_FILE="$(xdg-mime query default "${1}")"
    DEFAULT_APP=$(
        cat "/usr/share/applications/$DOT_DESKTOP_FILE" \
        | grep -Po '(?<=Exec=)[^ ]+(?=[ ])' \
        | sort | uniq | head -1
    )
    echo "$DEFAULT_APP"
    return 0
}
