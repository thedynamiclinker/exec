# exec. _(noun)_.
1. A system call allowing cross-language function composition. The Unix Way.™
2. An executive. e.g., "The top execs at our company love the exec repo."

## usage

Just say whatever.

~ $ grep2 -m 5 --bojack-first "References to horses" /usr/share/imaginary-file-containing-the-full-text-of-revelation-and-also-a-line-or-two-from-bojack-horseman
I'm BoJack Horseman. Obviously.
And I saw, and behold a white horse
And there went out another horse that was red
and lo a black horse
and behold a pale horse

## New Human Shell

Put this checkout's `bin` on PATH. Run `@` on a terminal to start the shell,
or run `@ REQUEST` for a single agent turn. For example, `printf '@\n' | @ ot`
asks for the Old Testament name. `@unix` runs the original Unix-filter profile.

`nsh` tries lines in Bash and delegates failures to `law`. Answer a
clarifying question at the next prompt. A bare `@` between simple stages
such as `cat names @ sed 's/old/new/'` goes straight to the agent. Readline
supports editing, Tab completion and history search. Terminal history goes
to `$NSH_HOME/history`, with space-prefixed lines omitted. Use Ctrl+C to
cancel input or a question, `:paste` to enter multiple lines, or
`ld.so COMMAND` to run Bash directly with the terminal's original streams.
`nhs` uses `>>>` and collects a block after a line ending in a colon.

The [@ profile](etc/lord/AGENTS-@.md) defines the shell's vocabulary and how
it learns. The shell adds `~/.nsh/bin` to PATH and the agent keeps scoped
definitions in `~/.nsh/etc/nshrc`. Set `NSH_HOME` to use a separate prefix.
An English file with the shebang `#!/usr/bin/env LD` can be run as its
own agent program. Existing `nsh-ld` shebangs continue to work.
