# exec. _(noun)_.
1. A system call allowing cross-language function composition. The Unix Way.™
2. An executive. e.g., "The top execs at our company love the exec repo."


The agent wrappers in `bin2` use `lord-run` from the
[thedynamiclinker/lord](https://github.com/thedynamiclinker/lord) package.
If it is on PATH, `lord-log stdin`, `lord-log stdout`, and
`lord-log stderr` read the most recent completed run. Existing profile
switches and semantic pipelines still use the same command-line interface.
