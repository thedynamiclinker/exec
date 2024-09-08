#!/bin/bash

source colors.sh

log() {
    local EOL='\n'
    [[ $1 == '--no-newline' ]] && EOL='' && shift
    printf "${blu}[${whi}*${blu}]${whi} $@${end}${EOL}"
}

log2() {
    local EOL='\n'
    [[ $1 == '--no-newline' ]] && EOL='' && shift
    printf "  ${yel}->${whi} $@${end}${EOL}"
}

glog() {
    local EOL='\n'
    [[ $1 == '--no-newline' ]] && EOL='' && shift
    if which zenity &>/dev/null; then
        GLOG=(zenity --info --title "Bitch please" --width 300 --text)
    elif which xcowsay &>/dev/null; then
        GLOG=(xcowsay)
    else
        GLOG=(printf)
    fi
    "${GLOG[@]}" "${1}"
}

die() {
    # A die function that works:
    # (1) interactively, (2) in scripts, (3) in shell functions.
    # This is surprisingly harder than it sounds.

    # Note: At first I thought I could just eval "return 1" here,
    # but it turns out that just exits from the *current*
    # function, which essentially means die becomes a colorful
    # printf that doesn't actually alter the flow of the program.
    # However, sending the SIGINT signal to $$ does actually work.

    if [[ $- == *i* ]]; then
        exit_str="kill -SIGINT $$"
        str_end=''
    else
        exit_str="exit 1"
        str_end='\n'
    fi

    # If the user passed us a message, print it all pretty-like.
    if [[ -n $1 ]]; then
        printf "${red}ERROR${whi}: $@${end}${str_end}"
    fi
    # Then either way, exit smoothly
    eval "${exit_str}"
}
