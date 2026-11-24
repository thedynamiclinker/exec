# A port declares DEPS (organization/name or organization/name=URL), PROGRAMS,
# ALIASES (name=target), and DATA (paths relative to the installed prefix).
.DEFAULT_GOAL := help
PREFIX ?= /usr/local
GIT_ROOT ?= https://github.com
PORTS_CACHE ?= $(if $(XDG_CACHE_HOME),$(XDG_CACHE_HOME),$(HOME)/.cache)/new-world
PORTS_SOURCE ?= $(abspath ../..)
PORT_SCRIPT := $(firstword $(wildcard $(dir $(lastword $(MAKEFILE_LIST)))port $(dir $(lastword $(MAKEFILE_LIST)))../../port $(dir $(lastword $(MAKEFILE_LIST)))../../bin/port))
PORTS_STACK ?=
INSTALL_ARGS = "$(CURDIR)" "$(DESTDIR)" "$(PREFIX)" $(foreach file,$(PROGRAMS),"$(file)") -- $(foreach alias,$(ALIASES),"$(alias)") -- $(foreach file,$(DATA),"$(file)")
export PORTS_SOURCE PORTS_CACHE GIT_ROOT PREFIX DESTDIR

.PHONY: help install develop uninstall clean
help:
	@printf '%s\n' 'make install | develop | uninstall | clean [PREFIX=/usr/local] [DESTDIR=...]'

# DESTDIR is for redistributable copies, whose sources disappear after build.
install develop:
	@test "$@" != develop || test -z "$(DESTDIR)" || { echo 'develop uses PREFIX without DESTDIR' >&2; exit 2; }
	+@for dep in $(DEPS); do \
	    case " $(PORTS_STACK) $(PACKAGE) " in *" $${dep%%=*} "*) echo "port: dependency cycle at $$dep" >&2; exit 2;; esac; \
	    source=$$("$(PORT_SCRIPT)" fetch "$$dep") || exit; \
	    $(MAKE) -C "$$source" "$@" PORTS_STACK="$(PORTS_STACK) $(PACKAGE)" PREFIX="$(PREFIX)" DESTDIR="$(DESTDIR)" || exit; \
	done
	@"$(PORT_SCRIPT)" files "$@" $(INSTALL_ARGS)

uninstall:
	@"$(PORT_SCRIPT)" files "$@" $(INSTALL_ARGS)

# Source-only ports have no build products. Clones are shared.
clean:
	@:
