
- It's not always clear why we do this thing called "programming."

- But there are certain things that are definitely NOT the reason why we program.

- The reason we program is definitely NOT "because we want to write the exact same code tomorrow that we wrote today."

- If we change the word "tomorrow" to "next week" or "next year," this remains true.

- Therefore, the simplest unit of "writing code" in a given language or environment should always come tightly coupled to the simplest unit of "re-using that code."

- The `hello world` is supposed to be the minimal unit of code.

- Therefore: We forgot half of `hello world`.

- The half of `hello world` we forgot is the minimal unit of code re-use.

- There are two types of code: importables and executables.

- Importables are units of code that we re-use _intra-process_, through dynamic linking or a language specific import, include, require, or use mechanism.

- Executables are units of code that we can re-use `inter-process`, through the language-independent system call `exec` and all its variants.

- Importables generally must be written in the same language as the code that uses them. Exceptions to this rule generally require the use of "foreign function interfaces," or linking against code written in another language. These are common, but can become extremely subtle in edge cases or when things go wrong.

- Executables can be written in any language, and the code that uses them (and the code they use) becomes no more difficult to incorporate by virtue of being written in another language.

- Each programming language has its own `hello world`.

- Each programming language also has its own language specific search/install paths for importables, e.g.
	- `/usr/include` for C header files.
	- `/usr/lib` for shared libraries in compiled languages.
	- `/usr/lib/pythonX.Y/site-packages` for python libraries.
	- `/usr/lib/perlX/site_perl/X.Y.Z` for perl libraries.

- All languages share the same search/install paths for executables: `$PATH`.

- There is only one language for which the importable (intra-process) and executable (inter-process) search/install paths for code sharing are in fact the same path.

- That language is the family of dialects we call "the shell."

	- The shell is the highest level programming language in existence.
	- This topic will be discussed more fully in another principle.
	- For now, back to first principles.
	- I mean the first principle.
	- Because this is the first principle:

- We forgot half of `hello world`.

- The second half is making each `hello world` re-usable, by installing it in your personal lexicon of commands.

- Your personal lexicon of commands is the most important code base you will ever write or maintain.

- In general, adding code to your personal lexicon requires learning about search paths and install paths of each language you use regularly.

- But the first step toward building that lexicon only requires:
	- making a private `~/bin`,
	- adding it to `PATH`, and
	- putting one command in there,
	- this is the missing half of the _first_ hello world you ever wrote.
	- now that we've done it, you've finished _one_ hello world.
	- there are lots of other hello worlds in computing.

- A `hello world` need not just print `hello world`.

- A `hello world` is any piece of code that illustrates how to do something that you would not know how to do without it, and does so as simply as possible.

- The `hello world` is the most valuable unit of software.

- Most `hello worlds` are not finished.

- Sometimes it's not clear what it would even mean to install a given `hello world` in a way that makes it re-usable.

- For example, a `hello world` showing how to write your own OS kernel may be satisfying for educational purposes, but it's unlikely to be something you can simply put in `$HOME/bin`.

- Not all `hello world`s need to be "finished."

- But whenever possible, remember to finish `hello world`.

- For some `hello worlds`, to "finish" just means to put it in your personal `$HOME/bin`.

- For other `hello worlds`, to "finish" may mean to put it in a different search path, like `$LD_LIBRARY_PATH` or language specific paths like `$PYTHONPATH`.

- For still other `hello world`s, to "finish" may mean to push it to remote source control, or to make it an installable package according to some language-specific packaging format.

- For still other `hello worlds`, to "finish" may just mean to keep it in a long text file full of one-liners that you grep or search through whenever you need to remember how to do a thing. (But remember to make that file quick and easy to find from anywhere on your system, or _it_ isn't finished, though the examples it contains might be. More on this later.)

- The definition of "finished" depends on the definition of "easy to re-use" for a given piece of code. If it's easy to re-use by typing a few characters, it's finished. If it's not, it isn't.

- So finish `hello world` whenever possible.

- Because it may not always be easy to say what the point of programming is.

- But the point of programming is definitely NOT to write the same code over and over again each time we need it.

- Optimize your workflow for being able to use any code tomorrow that you wrote today, with as little effort required of your tomorrow-self as possible.

- Before long, nothing will feel "finished" until it's ready for your future self to re-use in whatever ways future you will find most useful.

- Creation is not finished just because the code is finished.

- Creation is not finished without the word.

- The word is a name. A new word in our lexicon. The word that will be used to call the code in the future.

- Naming things is the first hard problem in computing for a reason.

- Until the hello world is in a file named `hello` in `~/bin` or some other location in the `PATH` that will be searched any time we type the word `hello`, we're not finished.

- Code can be ready for the world without tests, without review, without any of the false requirements one often hears.

- Code is ready for the world as soon as it has a name.

- If you then find in practice that you never type that name, and thus never use the code, it doesn't matter if the code is untested, unreviewed, insecure, or otherwise imperfect.

- If the name can be forgotten, then the code can be forgotten.

- Code begins to exist the moment it has a name.

- In the beginning was the word.

- So sayeth the L||D.

- [[bin/sh#First Principles|EOF]].
