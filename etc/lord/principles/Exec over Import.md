Import Doesn't Scale

- Exec is a between-process method of code re-use.
- Import is a within-process method of code re-use.

- Import does not work between processes, except via `fork()`.
- Because Concurrency Primitives are Broken, `fork()` often can't be mixed with threads.

- The import method of sharing code does not work between languages, except via awkward foreign function interface APIs.

- Unix got it right.
