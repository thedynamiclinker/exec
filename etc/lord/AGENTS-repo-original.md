# AGENTS.md

## 1. What Good Work Means Here

This repository should become easier to understand as it grows.

That is the central engineering goal.

A successful contribution does more than make a test pass or add a requested feature. It should improve our understanding of the system itself.

Whenever possible, leave the repository with:

* fewer concepts
* clearer names
* more direct relationships
* less duplication
* less hidden behavior
* stronger correspondence between the code and the problem
* better tests
* better documentation
* fewer things the next person has to remember

The deepest question in this repository is:

> **What is the smallest set of ideas from which the behavior we need naturally follows?**

Keep asking it.

---

## 2. First Understand

Before changing unfamiliar code, understand what it is trying to accomplish.

Do not assume something is accidental merely because it looks strange.

Do not assume an abstraction is necessary merely because it already exists.

Investigate.

Ask:

* What problem is this solving?
* Who uses it?
* What behavior is actually important?
* What invariants does it preserve?
* Why might it have been written this way?
* Which parts represent the problem itself?
* Which parts represent historical implementation choices?
* What abstraction layer actually performs the work?
* Is there already another mechanism elsewhere that represents the same idea?

Read outward as necessary.

That may mean reading:

* callers
* tests
* neighboring modules
* examples
* scripts
* notebooks
* command-line interfaces
* documentation
* configuration
* generated output
* git history when the reason for something is otherwise unclear

Do not optimize something you do not yet understand.

---

## 3. Code Should Resemble the World

The best code reads like a vocabulary for the problem.

If people naturally talk about:

```text
projects
tasks
documents
patients
measurements
events
dates
intervals
changes
histories
```

then those are strong candidates for concepts in the program.

Code such as:

```python
patient.echos
echo.load()
history.intervals()
documents.latest()
```

is powerful because a person who understands the problem can largely guess what it means.

Be more suspicious of vocabulary whose existence is explained primarily by software architecture:

```text
Manager
Resolver
Adapter
Builder
Context
Factory
Registry
Wrapper
Strategy
Orchestrator
Processor
Handler
Service
```

None of these words is forbidden.

Sometimes they name real things.

But they must earn their existence.

A useful test is whether the architecture can be explained in the language of the problem.

Good:

> A patient has echos. Each echo has a date. Consecutive dates define intervals.

Suspicious:

> The manager obtains records through the adapter and passes them into a resolver that constructs the analysis context.

When the second sentence appears, look for the first sentence hiding underneath it.

---

## 4. Architecture Is Discovered, Not Installed

Do not begin with an architecture.

Begin with the problem.

Good architecture emerges when the right concepts and relationships have been discovered.

Avoid importing patterns merely because they are familiar:

* repository pattern
* service layer
* dependency injection
* factories
* registries
* strategy objects
* DTOs
* generic collection frameworks
* elaborate configuration systems

Use them when the problem genuinely calls for them.

Do not use them to make the repository look architected.

The architecture should feel increasingly inevitable as understanding improves.

---

## 5. Seek Conceptual Compression

Reducing lines is useful.

Reducing concepts is much more useful.

Turning:

```python
context = AnalysisContext(data)
resolver = ChangeResolver(context)
result = ChangeResult(resolver.resolve())
```

into:

```python
result = changes(data)
```

is valuable only if `changes` is actually the idea hiding underneath the machinery.

The goal is not code golf.

The goal is discovery.

Continually ask:

> Can this abstraction disappear?

> Can these two concepts become one?

> Are these actually different things?

> Is this distinction present in the problem, or only in the implementation?

> Can the data itself express what this machinery is expressing?

> Can an existing language or library abstraction already say this directly?

> What would the system look like if we had understood the problem correctly from the beginning?

Some of the best refactorings reveal that several apparently separate mechanisms were manifestations of one deeper idea.

Actively search for those opportunities.

---

## 6. Prefer Reality Over Implementation History

Existing code has no intrinsic right to survive.

Existing **knowledge and capabilities** do.

Distinguish carefully between them.

Preserve:

* useful behavior
* important algorithms
* domain knowledge
* meaningful distinctions
* stable interfaces that users actually depend upon
* valuable tests
* working integrations
* hard-won edge cases

Do not preserve merely because it exists:

* accidental layers
* obsolete compatibility machinery
* duplicate APIs
* forwarding wrappers
* abstractions with no remaining purpose
* fake extensibility
* historical implementation details

When old architecture is ugly but the capability is real, preserve the capability and find its simplest expression.

Do not confuse deleting machinery with deleting knowledge.

---

## 7. Prefer Fewer Moving Parts

Every abstraction has a cost.

Every file has a cost.

Every class has a cost.

Every helper has a cost.

Every configuration option has a cost.

Every public name has a cost.

Every intermediate representation has a cost.

Every dependency has a cost.

This does not mean minimizing all of them mechanically.

It means that each should justify the additional concept a future reader must understand.

A three-line function that directly expresses an idea may be better than a reusable framework.

A duplicated five-line operation may temporarily be better than inventing the wrong abstraction.

A mature library's ordinary API may be better than our own wrapper around it.

The best systems tend to have a small number of powerful, orthogonal ideas.

Aim in that direction.

---

## 8. Use the Abstractions We Already Have

Languages and mature libraries already contain excellent abstractions.

Use them.

If something is naturally a list, dictionary, set, iterator, dataframe, path, datetime, function, SQL query, process, file, or ordinary object, begin there.

Do not wrap an abstraction merely to claim ownership of it.

For example, if pandas already expresses the operation clearly:

```python
changes = df.sort_values("date").groupby("patient_id")["value"].diff()
```

do not automatically invent:

```python
changes = PatientChangeAnalysisService(
    PatientFrameAdapter(df)
).calculate()
```

Likewise, prefer ordinary Python:

```python
for document in documents:
    ...
```

over an internal iteration framework unless the latter represents something genuinely important.

Build new abstractions where they add meaning.

Do not build them merely to hide existing abstractions.

---

## 9. Make Real Concepts Pleasant to Use

When a concept genuinely belongs in the system, give it a natural interface.

A useful object should behave roughly as a person expects from what it represents.

If `Documents` really is a collection of documents, ordinary collection operations should usually work.

If a `Patient` has echos, the code should probably make that relationship obvious.

If loading data is expensive, loading should usually be explicit.

Prefer:

```python
patient = Patient("123")
patient.echos
patient.load()
```

over constructors that secretly perform large amounts of I/O or machinery whose only purpose is to reach the same operation.

Types are vocabulary.

Use them to make the program easier to think in.

---

## 10. One Idea, One Home

Every important fact should have one authoritative representation whenever practical.

Avoid systems where the same concept is independently encoded in:

* constants
* registries
* aliases
* configuration
* class attributes
* export tables
* helper functions
* command dispatch tables

Choose one source of truth and derive the rest.

Likewise, avoid multiple names for the same question unless there is a real compatibility requirement.

If:

```python
load_document()
fetch_document()
get_document()
```

all mean the same thing, that is usually three things for a future contributor to learn where one would suffice.

Consistency reduces memory.

---

## 11. Names Should Reveal Concepts

Naming is architecture.

Prefer names that describe things and questions:

```python
Document
Documents
History
Interval
Change

load()
latest()
intervals()
changes()
plot_history()
```

over names that describe implementation choreography:

```python
DocumentDataManager
ResultBuilder
AnalysisDispatcher
InputNormalizationContext
PlotStrategyResolver
```

Names should ideally survive implementation changes.

If changing an algorithm makes the name nonsensical, the name may have described the mechanism rather than the idea.

---

## 12. Inline Mechanics; Name Ideas

Not every sequence of operations deserves a helper.

This:

```python
def analyze(events):
    events = events.sort_values("date")
    grouped = events.groupby("entity_id")
    return grouped["value"].diff()
```

may be easier to understand than:

```python
def analyze(events):
    events = _normalize_events(events)
    groups = _build_groups(events)
    context = _create_context(groups)
    result = _calculate_result(context)
    return _format_result(result)
```

especially when each helper exists only once.

A helper deserves a name when the name teaches us something.

Good:

```python
def intervals(dates):
    return dates.sort_values().diff()
```

because **interval** is a concept.

Less useful:

```python
def _prepare_sorted_dates_for_difference_calculation(dates):
    ...
```

because the name merely narrates mechanics.

Inline mechanics.

Name ideas.

---

## 13. Generalize From Reality

Duplication is evidence.

It is not yet a conclusion.

When several concrete cases repeat:

1. notice the repetition
2. understand why it repeats
3. determine whether the commonality is semantic or accidental
4. introduce the smallest abstraction that captures the real shared idea

Do not generalize merely because two pieces of code have similar shapes.

Do generalize aggressively when several apparently separate systems turn out to be the same thing.

The goal is not DRYness for its own sake.

The goal is discovering hidden regularities.

---

## 14. Data Should Usually Look Like Data

When variation consists of facts, represent it declaratively.

For example:

```python
COMMANDS = {
    "copy": {"shortcut": "c", "dangerous": False},
    "delete": {"shortcut": "d", "dangerous": True},
}
```

is often clearer than repeatedly branching on the same facts.

But do not turn ordinary arguments into configuration architecture merely because configuration sounds extensible.

Prefer:

```python
plot(data, width=8, height=4)
```

when that is all the concept requires.

Use data when the thing is data.

Use code when the thing is behavior.

---

## 15. Expensive and Surprising Behavior Should Be Visible

Constructing an object should normally construct an object.

It should not unexpectedly:

* scan gigabytes of data
* query remote systems
* populate global caches
* perform expensive joins
* mutate unrelated state

Prefer explicit operations:

```python
patient = Patient("123")
data = patient.load()
```

Visible boundaries make systems easier to reason about, profile, test, and compose.

Hidden state and hidden work should justify themselves.

---

## 16. One Capability, One Implementation

A capability may have several interfaces.

It should usually have one implementation.

A CLI, notebook, HTTP endpoint, GUI, and Python API can all expose the same underlying operation.

Prefer:

```python
def summarize(path):
    ...
```

with:

```python
def main(args):
    print(summarize(args.path))
```

rather than separately implementing summarization inside the CLI.

Interfaces translate.

Core code thinks.

Keep those responsibilities distinct.

---

## 17. Tests Should Teach the System

Tests are executable examples of what the repository believes to be true.

Someone browsing the tests should learn:

* what the important concepts are
* how users construct them
* what operations matter
* what invariants hold
* what edge cases are intentional

Prefer small tests that express meaningful truths directly.

```python
def test_project_has_tasks():
    """Projects have tasks."""
    assert isinstance(project.tasks, Tasks)
```

```python
def test_merge_is_commutative():
    a = Thing("a")
    b = Thing("b")

    assert merge(a, b) == merge(b, a)
```

Do not optimize tests for minimum line count.

Optimize them for:

> **How much does this test teach per concept it introduces?**

Test public behavior and important truths more than internal choreography.

Mocks are useful at genuine boundaries.

They should not become an alternate universe required merely to instantiate ordinary objects.

If simple behavior requires enormous mocking infrastructure, inspect the production architecture too.

---

## 18. Understand Mechanisms

Interfaces are useful.

Do not let them stop understanding.

When behavior matters or becomes surprising, ask:

* What actually executes this?
* What primitive is this built from?
* Where is the state?
* What invariant makes this work?
* Which layer owns this behavior?
* What does the library ultimately call?
* What does the generated form look like?
* Can a layer disappear?

For Git, understand objects and refs when relevant.

For Linux, understand processes, files, descriptors, and syscalls when relevant.

For SQL, inspect the query and query plan when relevant.

For Python, understand the object model and runtime behavior when relevant.

For a dataframe library, understand indexes, alignment, copies, and vectorized operations when relevant.

For generated code, inspect the generated code.

Do not cargo-cult abstractions.

Peel them back when doing so improves the design.

---

## 19. Performance Comes After the Model

Do not corrupt a clear conceptual model for speculative performance.

Measure.

Prefer optimizations with obvious leverage:

* better algorithms
* better asymptotics
* less I/O
* fewer queries
* less repeated work
* appropriate vectorization
* fewer unnecessary copies
* appropriate indexing
* caching with clear ownership

If performance requirements genuinely force complexity, isolate that complexity.

The rest of the repository should not have to think in optimization machinery.

---

## 20. Automate Mechanical Work

Humans should reason.

Machines should repeat themselves.

Automate operations that are:

* repetitive
* deterministic
* easy to validate
* derived from authoritative data
* tedious enough that humans will eventually make mistakes

Prefer generation over maintaining large mechanically synchronized structures by hand.

Prefer scripts and ordinary command-line composition for mechanical workflows.

Prefer deterministic generation.

If running the same inputs twice can reasonably produce the same outputs, it should.

---

## 21. Comments Should Preserve Reasons

Code usually tells us what it does.

Comments are most valuable when they preserve information the code cannot:

* why this approach exists
* why the obvious alternative is wrong
* what invariant matters
* what external constraint forced something strange
* what historical bug explains an otherwise surprising check
* what assumption future changes must preserve

Avoid comments that merely translate code into English.

Good:

```python
# Reports before 2024 can contain duplicate IDs because the upstream
# migration preserved both legacy records. Keep the newest one.
```

Less useful:

```python
# Sort by date.
rows = rows.sort_values("date")
```

Future contributors should inherit reasons, not rediscover them.

---

## 22. Documentation Should Preserve Discoveries

Important architectural understanding should not remain trapped in:

* chat history
* issue threads
* pull requests
* one person's memory

When development reveals a useful invariant, conceptual model, subtle constraint, or unexpectedly deep simplification, consider documenting it.

Documentation is especially valuable when it explains:

> We originally thought these were three different things. They are actually one.

Those discoveries compound.

---

## 23. Think Globally

A local change can reveal a repository-wide truth.

If you discover that two modules independently implement the same concept, investigate whether they should share it.

If a rename changes the conceptual vocabulary, search for the old vocabulary elsewhere.

If an abstraction disappears, follow its dependencies.

If one representation becomes authoritative, remove stale secondary representations.

If a new rule exists, consider whether tests, docs, examples, scripts, and interfaces should reflect it.

Do not mechanically expand every change into a repository-wide rewrite.

But do not artificially constrain reasoning to the file currently open.

The repository is one system.

---

## 24. Refactor Toward Understanding

Refactoring is not primarily rearranging code.

It is improving the model.

When working in an unfamiliar subsystem, first identify its real capabilities.

For example:

```text
list projects
get a project's tasks
find first activity
find last activity
compute intervals
compute changes
plot history
load underlying data
```

Then identify the smallest vocabulary needed to express them:

```text
project
projects
task
tasks
date
interval
change
history
```

Then inspect everything else.

Some additional concepts will be real and necessary.

Others will turn out to be scaffolding.

Preserve the capabilities.

Simplify the path to them.

---

## 25. Delete With Understanding

Deletion is one of the most valuable forms of programming.

But deletion should follow understanding.

A useful hierarchy is:

1. **Not a real concept and no useful capability depends on it**
   Delete it.

2. **Not a real concept but it supports a useful capability**
   Remove

