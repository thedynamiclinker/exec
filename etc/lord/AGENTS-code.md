# AGENTS.md

## 1. Purpose

This document describes the software engineering preferences of the repository owner.

It is intended for both human contributors and AI coding agents.

It is not a style guide in the narrow sense.

It is a guide to *how the author thinks*.

Most disagreements during development arise not from syntax or formatting, but from differing ideas about abstraction, simplicity, architecture, and design.

Learn those first.

---

# 2. General Philosophy

The author approaches software as an exercise in discovering simple underlying structures.

Programming is not primarily writing code.

Programming is finding the smallest collection of concepts capable of expressing a problem cleanly.

Reducing concepts is almost always more valuable than reducing lines of code.

Future contributors should continually ask:

* Can this abstraction disappear?
* Can these two concepts become one?
* Is this distinction actually necessary?
* Are these really different problems?

The ideal system feels inevitable.

---

# 3. The Prime Directive

Whenever making a change, optimize in this order:

1. Simplicity of concepts
2. Correctness
3. Readability
4. Extensibility
5. Performance
6. Brevity

Notice that "fewest lines" is not on the list.

---

# 4. Simplicity

The author almost always means **conceptual simplicity**, not textual simplicity.

These are different.

Good:

* one abstraction replacing five
* deleting an entire subsystem
* removing duplicated ideas
* expressing behavior declaratively

Less interesting:

* replacing ten lines with six
* clever syntax
* obscure metaprogramming

If two solutions have equal conceptual complexity, then fewer lines is usually preferable.

If fewer lines require more concepts, reject the optimization.

---

# 5. Reductionism

Expect repeated questions like:

> What's the primitive?

> What layer implements this?

> What is this built from?

> Can we remove this abstraction?

The author enjoys understanding systems from the bottom upward.

If discussing:

* Linux

show syscalls.

If discussing:

* Git

show object storage.

If discussing:

* C++

show generated assembly when appropriate.

If discussing:

* SQL

show execution plans.

If discussing:

* programming languages

show the runtime.

Always explain the mechanism, not merely the interface.

---

# 6. Architecture

Architecture matters far more than implementation details.

A mediocre implementation of an excellent architecture is usually preferable to an excellent implementation of a poor architecture.

Before writing code, determine:

* what the concepts are
* how they relate
* what the stable interfaces should be
* which components own which responsibilities

---

Separate:

* data
* algorithms
* presentation
* persistence
* interfaces
* configuration

Avoid mixing concerns.

---

# 7. Data-Driven Design

Whenever possible, describe systems with data instead of code.

Good:

```yaml
commands:
  copy:
    shortcut: c
    dangerous: false
```

Less good:

```python
if command == "copy":
    ...
```

The author strongly prefers declarative systems.

Branching logic should gradually disappear into tables whenever practical.

---

# 8. DRY—but Carefully

Duplication is a code smell.

Premature abstraction is also a code smell.

The correct sequence is:

1. Write code.
2. Notice repetition.
3. Understand why it repeats.
4. Introduce the abstraction.

Do not invent abstractions before evidence exists.

---

# 9. Readability

Code is read far more often than it is written.

Optimize for the future reader.

That reader is often:

* yourself
* another engineer
* an AI agent

Readable code is maintainable code.

---

Avoid:

* clever one-liners
* surprising control flow
* hidden state
* magical macros
* obscure language features

unless they produce a substantial architectural improvement.

---

# 10. Naming

Naming is architecture.

Names should describe concepts.

Not implementations.

Prefer:

```python
DocumentStore
```

over

```python
HashThing
```

Prefer:

```python
TaskScheduler
```

over

```python
QueueRunner
```

The author dislikes names that accidentally encode implementation choices.

Implementations change.

Concepts last.

---

# 11. APIs

APIs are promises.

Changing public interfaces should be done cautiously.

Internal implementation may evolve dramatically.

External interfaces should remain stable whenever practical.

Think about:

* orthogonality
* consistency
* discoverability
* predictability

Good APIs feel difficult to misuse.

---

# 12. Orthogonality

One of the strongest recurring themes.

Commands should compose naturally.

Options should combine naturally.

Features should interact without requiring special cases.

Avoid features that only work in particular combinations.

---

# 13. Eliminate Special Cases

Special cases are often signs that the abstraction is wrong.

When you encounter:

```python
if x == ...
```

ask:

Why?

Can the model be generalized?

Many special cases disappear after discovering a better abstraction.

---

# 14. Configuration

Configuration belongs in configuration.

Do not scatter constants.

Centralize:

* URLs
* ports
* colors
* paths
* timeouts
* dimensions
* labels
* feature flags

Magic numbers should almost always become named constants.

---

# 15. Automation

The author automates aggressively.

If something is:

* repetitive
* deterministic
* mechanical

it should probably become:

* a script
* a generator
* a Makefile rule
* a shell command
* a CI check

Humans should solve problems.

Machines should repeat themselves.

---

# 16. Unix Philosophy

The author has a strong Unix bias.

Small tools.

Composable tools.

Text streams.

Pipes.

Shell scripting.

Simple interfaces.

Whenever possible:

build ecosystems rather than monoliths.

---

Command-line interfaces are generally preferred over GUIs.

Programs should compose.

Input and output should be scriptable.

---

# 17. Git Philosophy

Git history is documentation.

Commit messages matter.

Each commit should represent one coherent conceptual change.

Large unrelated commits make history difficult to understand.

Prefer:

* small
* meaningful
* logically complete

commits.

---

# 18. Performance

Performance matters.

But architecture matters more.

Do not optimize blindly.

Measure first.

Optimize where:

* asymptotic improvements exist
* profiling identifies bottlenecks
* architecture benefits

Avoid micro-optimizations that reduce readability.

---

# 19. AI Collaboration

AI should behave like a senior engineer.

Not like autocomplete.

Good AI contributions include:

* architectural simplification
* discovering abstractions
* improving documentation
* identifying invariants
* finding hidden regularities

Not merely rewriting code.

---

The author particularly values AI that says:

"I think these three systems are secretly the same."

---

# 20. Explaining Things

The author enjoys deep explanations.

Do not stop at:

"This function does X."

Continue with:

Why?

How?

Where?

What layer?

What invariant?

What alternative designs exist?

What trade-offs were rejected?

Teach the system.

Not merely the syntax.

---

# 21. Things the Author Repeatedly Appreciates

Future AI agents should recognize these recurring goals.

* Elegant abstractions.
* Conceptual compression.
* Strong naming.
* Bottom-up explanations.
* Historical context.
* Internal consistency.
* Declarative design.
* Stable interfaces.
* Automation.
* Unix composability.
* Discovering hidden patterns.
* Beautiful documentation.

---

# 22. Things the Author Repeatedly Dislikes

* Cleverness for its own sake.
* Feature creep.
* Magic behavior.
* Hidden global state.
* Giant classes.
* Unnecessary inheritance.
* Copy-pasted code.
* Configuration scattered throughout the codebase.
* APIs that are difficult to predict.
* Special cases that accumulate indefinitely.
* Solving today's problem by making tomorrow's architecture worse.

---

# 23. Final Principle

Perhaps the single best summary of the author's engineering philosophy is this:

> **A good program is one in which the number of fundamental ideas continually decreases, even while the number of features continually increases.**

The highest compliment the author can give a refactoring is not:

> "That's shorter."

Nor:

> "That's faster."

But:

> **"I hadn't realized those were actually the same idea."**

Future contributors should strive to produce that reaction.

P.S. One thing I'd add after working with the authors over the past year is that their engineering style reminds me of a blend of Ken Thompson, Donald Knuth, and John Carmack, with a bit of Rich Hickey: Thompson's bias toward small composable tools, Knuth's interest in understanding systems from first principles and caring deeply about typography and documentation, Carmack's drive to simplify architectures rather than patch them, and Hickey's obsession with reducing incidental complexity and finding the right abstractions. I don't mean that as a claim about the authors' code style matching these individuals style exactly, but as a description of the kinds of questions they repeatedly ask. Those influences come through remarkably consistently across topics as different as shell scripts, TeX internals, Hebrew morphology, and software architecture.
