#!/usr/bin/env bash

# bash completion hacks

# On gentoo and arch, completions are in: /usr/share/bash-completion/completions/

# Note: When we type:
# $ mycommand cake and pi<Tab>
# We will have
# COMP_CWORD=3
# COMP_WORDS=(mycommand cake and pi)
# 
# We can use this knowledge to modify the COMP_WORDS array
# and the COMP_CWORD index in transit, in order to "inherit"
# from the big hairy bash completions provided by packages
# like systemd. This allows us to provide customized bash
# completions to aliases, bash functions, or whatever we want.

fn_exists() {
    # This works...
    # type $1 2>/dev/null | head -n 1 | grep -q 'function'
    # ...but apparently this is a hell of a lot faster
    # Source: http://stackoverflow.com/questions/85880/determine-if-a-function-exists-in-bash
    declare -f $1 > /dev/null
}

# Note: The files in /usr/share/bash-completion/completions/systemctl seem to be
# sourced lazily. That is, they're not sourced until a completion is needed.
# This is a good implementation, but it means _systemctl won't be pre-loaded into
# our environment unless we've called a systemctl tab-completion since we opened
# our terminal. In order to make sure we have the _systemctl function no matter
# what, let's check to see if it's defined, and load it if it isn't.

# Now here's a funny bug...
# I ran into a problem where I could start any of my window managers
# through startx, but not through lightdm. Reinstalled lightdm, and
# the problem persisted. Finally, I checked ~/.xsession-errors, and
# saw an error message that said:
#   /usr/share/bash-completion/completions/systemctl: line 46: syntax error near unexpected token `<'
#   /usr/share/bash-completion/completions/systemctl: line 46: `            <(__systemctl $mode show --property "$property" -- "${units[@]}")'
# After some exploring, here's what I figured out.
# When we login with lightdm, the script /etc/lightdm/Xsession is executed.
# The shebang in that file is #!/bin/sh.
# One of the things that file does is source $HOME/.profile
# (That may have been something I added to it awhile back. Not sure.)
# Now, my ~/.profile had this line in it:
#
## if running bash
#if [ -n "$BASH_VERSION" ]; then
#    # include .bashrc if it exists
#    if [ -f "$HOME/.bashrc" ]; then
#	. "$HOME/.bashrc"
#    fi
#fi
#
# What does this mean?
# Well, when people write "#!/bin/sh" shebangs on linux these days,
# they're not actually calling some old-timey version of UNIX sh.
# What they're calling is *bash's implementation of a shell with the sh syntax!*
# However, that shell is really a restricted version of bash, not sh, and so it
# has no compunctions about going right ahead and defining $BASH_VERSION,
# (because after all, it's bash!). So, when /etc/lightdm/Xsession asked
# /bin/sh to run it, it then sourced my ~/.profile, which noticed that the
# environment variable $BASH_VERSION was indeed a nonempty string, and so
# it proceeded to source my ~/.bashrc. Now, my ~/.bashrc sources my bash completions
# in ~/bin/bash_completions, and as of yesterday, my customized bash completion for
# my systemd aliases (i.e., this file) accomplishes its goal by sourcing from:
# /usr/share/bash-completion/completions/systemctl
# which contains the native systemd bash_completions. Now, that file apparently
# contains some bash specific syntax that isn't in bash's implementation of sh,
# which is why sourcing that script blew up, which blew up the sourcing of my bash
# completions, which blew up the sourcing of my ~/.bashrc, which blew up the
# sourcing of my ~/.profile, which blew up the "/bin/sh"-ish execution of
# /etc/lightdm/Xsession, which proceeded to prevent me from logging into anything.
# Thank god for .xsession-errors. If it weren't for that file, I'd be totally fucking
# baffled. Apparently lightdm saw no use in reporting all this bullshit in its logs.
# Chalk one up for startx.
# Thus ends the story of why I added the following line:

# I'm gonna add this line to ~/.profile too, which is the proper way to solve the problem
# if echo "$SHELLOPTS" | grep -cq posix; then 
if [ ${SHELLOPTS/posix} != ${SHELLOPTS} ]; then
    # echo "$0 sourced my systemd bash completion" >> /home/jason/Desktop/dear-self_fix-your-code
    return
fi

if ! fn_exists _systemctl; then
    path="/usr/share/bash-completion/completions/systemctl"
    [[ -f "$path" ]] && source "$path"
    unset path
fi

__steal_completion() {
    local verb="$1"
    local current="${COMP_WORDS[COMP_CWORD]}"
    COMP_WORDS=(systemctl "$verb" "$current")
    COMP_CWORD=2
    _systemctl
    return
}

_ssia() {
    __steal_completion "is-active"
}

_ssie() {
    __steal_completion "is-enabled"
}

_sss() {
    __steal_completion "start"
}

_ssS() {
    __steal_completion "stop"
}

_ssr() {
    __steal_completion "restart"
}

_sst() {
    __steal_completion "status"
}

complete -F _systemctl  ss
complete -F _ssia       ssia
complete -F _ssie       ssie
complete -F _sss        sss
complete -F _ssS        ssS
complete -F _ssr        ssr
complete -F _sst        sst

return
