#!/bin/bash

add_to_path () {
    # taken from /etc/profile on archlinux
    case ":$PATH:" in
        # if $1 is in the PATH, do nothing
        *:"$1":*) ;;
        # otherwise, add it to the end of PATH, keeping things
        # syntactically correct in the case where PATH is unset
        *) PATH="${PATH:+$PATH:}$1";;
    esac
}


add_to_python_path () {
    case ":$PYTHONPATH:" in
        *:"$1":*) ;;
        *) PYTHONPATH="${PYTHONPATH:+$PYTHONPATH:}$1";;
    esac
}

add_to_ld_library_path () {
    case ":$LD_LIBRARY_PATH:" in
        *:"$1":*) ;;
        *) LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$1";;
    esac
}
