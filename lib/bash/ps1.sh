#!/usr/bin/env bash

clip_prompt_if_its_super_long() {
    # If we're starting-up in a directory with a really-long
    # pathname, then switch to a shorter prompt automatically.
    if [[ "$(pwd | wc -c)" > 30 ]]; then
        export PS1="$(echo "$PS1" | sed 's@w@W@g')";
    fi
}

# make prompt shorter or longer
shorter_prompt() {
    export PS1="$(echo "$PS1" | sed "s@w@W@g")"
}
longer_prompt() {
    export PS1="$(echo "$PS1" | sed "s@W@w@g")"
}
alias sp='shorter_prompt'
alias lp='longer_prompt'
