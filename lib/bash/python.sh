#!/usr/bin/env bash

venv() {
    local PYTHON=${PYTHON:-python}
    if [[ -z $1 ]]; then
        echo "usage: $FUNCNAME <name>"
        return
    fi
    env="$HOME/env/$1"
    if [[ ! -e "$env" ]]; then
        mkdir -p "$(dirname "$env")"
        $PYTHON -m venv "$env"
    fi
    source "$env/bin/activate"
    "$PYTHON" -m pip install --upgrade pip ipython > /dev/null
}

venv14() {
    PYTHON=python3.14 venv $@
}

venv15() {
    PYTHON=python3.15 venv $@
}

venv13t() {
    PYTHON=python3.13t venv $@
}

venv14t() {
    PYTHON=python3.14t venv $@
}

venv15t() {
    PYTHON=python3.15t venv $@
}

penv() {
    local PYTHON=${PYTHON:-python}
    if [[ -z $1 ]]; then
        echo "usage: $FUNCNAME <name>"
        return
    fi
    env="$HOME/env/$1"
    if [[ ! -e "$env" ]]; then
        mkdir -p "$(dirname "$env")"
        $PYTHON -m venv --system-site-packages "$env"
    fi
    source "$env/bin/activate"
    "$PYTHON" -m pip install --upgrade pip ipython > /dev/null
}

penv14() {
    PYTHON=python3.14 penv $@
}

penv15() {
    PYTHON=python3.15 penv $@
}

penv14t() {
    PYTHON=python3.14t penv $@
}

penv15t() {
    PYTHON=python3.15t penv $@
}

rmenv() {
    if [[ -n "$VIRTUAL_ENV" ]] \
    && [[ -d "$VIRTUAL_ENV" ]] \
    && [[ $(which python) =~ "$VIRTUAL_ENV".* ]] \
    && [[ $(which python) =~ "$HOME".* ]] \
    then
        echo "${FUNCNAME}: removing env ${VIRTUAL_ENV} and deactivating"
        rm -r "$VIRTUAL_ENV" && deactivate
    else
        echo "${FUNCNAME}: doing nothing."
    fi
}

wenv() {
    echo "$VIRTUAL_ENV"
}

senv() {
    if [[ -d "$PWD/.venv" ]]; then
        source .venv/bin/activate
    fi
    clip_prompt_if_its_super_long
}

fenv() {
    deactivate
}

activate() {
    if [[ -z "$1" ]]; then
        echo "usage: activate <env>"
        return 1
    fi
    if [[ ! -d "$HOME/env" ]]; then
        echo "directory does not exist: $HOME/env"
        return 1
    fi
    source "$HOME/env/${1}/bin/activate"
}

python_venv_prompt_off() {
    export VIRTUAL_ENV_DISABLE_PROMPT=1
}

python_venv_prompt_on() {
    export VIRTUAL_ENV_DISABLE_PROMPT=
}

import() {
    # save yourself from pasting python code into the shell lol
    die "This is the shell."
}

# python locations
cdusp() {
    pushd $(python -c "import site; print(site.getusersitepackages())")
}

# bash completions

_bash_complete_using_venvs() {
    local possible_dirs=($(ls "$HOME/env"))
    local curr_word="${COMP_WORDS[COMP_CWORD]}"
    local prev_word="${COMP_WORDS[COMP_CWORD - 1]}"
    COMPREPLY=($(compgen -W "${possible_dirs[*]}" -- ${curr_word}))
}

is_bash && {
    complete -F _bash_complete_using_venvs activate
    complete -F _bash_complete_using_venvs venv
    complete -F _bash_complete_using_venvs penv
}

