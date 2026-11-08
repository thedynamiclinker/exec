Or: A good verb does not hard-code the location where you do it.
Or: A good function does not hard-code the location where you do it.
Or: A good function does not know where its inputs come from or where they go.

- Functions are verbs.
- Where they happen is a preposition.
- Verbs should not attempt to hard-code the place they will happen.
- IO is about where things come from and where they go.
- The `I` in `IO` means "where data comes from" - this isn't a normal function input.
- The `O` in `IO` means "where data goes to" - this isn't a normal function output.
- Try to decouple your functions from assumptions about where data came from.
- The verb "to run" does not know where its user intends to run.