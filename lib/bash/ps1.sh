#!/usr/bin/env bash

clip_prompt_if_its_super_long() {
    # If we're starting-up in a directory with a really-long
    # pathname, then switch to a shorter prompt automatically.
    if [[ "$(pwd | wc -c)" > 50 ]]; then
        export PS1="$(echo "$PS1" | sed 's@w@W@g')";
    fi
}

# make prompt shorter or longer
sp() {
    export PS1="$(echo "$PS1" | sed "s@w@W@g")"
}
lp() {
    export PS1="$(echo "$PS1" | sed "s@W@w@g")"
}

