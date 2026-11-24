# exec. _(noun)_.
1. A system call allowing cross-language function composition. The Unix Way.™
2. An executive. e.g., "The top execs at our company love the exec repo."

`etc/bashrc` puts `bin3` first for the New World commands. Open a terminal
and run `nsh`. Use `lord auth login` to sign in and `lord auth status` to
check the active provider. The bundled commands come from the `nsh`, `LD`,
`lord`, and `gen` packages in `HOME/THE-NEW-WORLD`. The packages also install
into their own prefixes.


The agent wrappers in `bin2` use `lord-run` from the
[thedynamiclinker/lord](https://github.com/thedynamiclinker/lord) package.
If it is on PATH, `lord-log stdin`, `lord-log stdout`, and
`lord-log stderr` read the most recent completed run. Existing profile
switches and semantic pipelines still use the same command-line interface.
