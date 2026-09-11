# AGENTS.md

## Purpose

This document describes what **code worth maintaining** means in this repository.

It is for human contributors and coding agents. It is not mainly a style guide. It is a guide to choosing concepts, APIs, abstractions, tests, and structure.

The central rule is:

> **THE CODE SHOULD LOOK LIKE THE REALITY WE ARE TALKING ABOUT.**

A good codebase reads like a vocabulary for its problem. A bad one reads like a vocabulary for software architecture.

The goal is not merely fewer lines. The goal is to remove code whose existence is explained mainly by the fact that this is software.

The remaining code should feel like direct notation for the world.

---

## 1. Preserve reality, not code

Programming is discovering the smallest set of concepts that can express the problem cleanly.

Optimize roughly in this order:

1. Correct concepts
2. Correct behavior
3. Conceptual simplicity
4. Readability
5. Composability
6. Performance where it matters
7. Brevity

Reducing **concepts** matters more than reducing lines.

Good:

```python
result = thing.change_since(previous)
```

Bad:

```python
context = ThingAnalysisContext(thing, previous)
resolver = ThingResolver(context)
adapter = ThingResultAdapter(resolver.resolve())
result = ChangeResultBuilder(adapter).build()
```

The first is better not because it is shorter, but because it invents less.

Continually ask:

* Is this a thing we actually think or talk about?
* Can this abstraction disappear?
* Can these two concepts become one?
* Is this distinction real, or merely architectural?
* Is this preserving capability, or preserving implementation history?

The ideal system feels inevitable.

---

## 2. Architecture is ontology, not scaffolding

Good architecture is mostly the discovery of the **right things and relationships**, not the accumulation of layers.

Before writing or refactoring code, identify the smallest ontology of the problem.

For one repository it might be:

```text
project
projects
task
tasks
date
interval
change
history
plot
```

For another it will be different. Use the nouns and verbs people naturally use when discussing that domain.

Code should mostly contain names like:

```python
Project
Task
tasks
intervals
changes
first
last
load
plot_changes
```

Be suspicious when it mostly contains names like:

```python
ProjectManager
TaskAdapter
DataFactory
ResultWrapper
Registry
AnalysisContext
SchemaResolver
Strategy
Builder
Orchestrator
```

These are not forbidden words. They simply have to justify themselves, because they often describe software machinery rather than reality.

A useful test is to explain the source to a smart person who knows the problem and Python.

Good:

> A project has tasks. Tasks have dates. Intervals are the differences between dates.

Bad:

> The adapter normalizes the resolver output so the context can construct the collection abstraction.

Delete concepts until the sentence becomes normal.

---

## 3. Real concepts deserve direct types

If something is a real concept, let the code say so.

Sometimes this is enough:

```python
class Document(str):
    ...

class Documents(list):
    ...
```

Do not automatically turn it into:

```python
@dataclass
class DocumentEntity:
    id: str
```

Let alone

```python
class DocumentRepositoryProtocol(Protocol):
    ...


class DocumentCollectionDTO(Generic[T]):
    ...
```

unless those extra concepts correspond to distinctions the problem actually requires.

A type is valuable when it makes natural sentences become natural code:

```python
document.load()
project.documents
len(project.documents)
```

A type is suspicious when its main purpose is enabling other architecture:

```python
DocumentResolver
DocumentLoaderFactory
DocumentContext
DocumentRecordAdapter
```

Do not build a framework when the thing is already exactly what it sounds like.

### “Has” is not “is”

If a project **has tasks**, model that relationship honestly:

```python
class Project:
    def __init__(self, project_id, tasks):
        self.project_id = project_id
        self.tasks = Tasks(tasks)

    def __len__(self):
        return len(self.tasks)
```

Do not inherit from `list` merely to get list behavior:

```python
class Project(list):  # bad: a project is not a list
    ...
```

However!... Inheriting from `list` is the perfect solution
for almost every *plural type.*

That is, if
    `Hotdog` or `Person` or `Document` is a type,
then
    `Hotdogs` or `People` or `Documents` should absolutely be a subclass of list with any relevant query or grep methods
    and that list should contain instances of the singular types.

This is perhaps the most important design principle that
we want our code to follow: subclass built-in types whenever
it makes our life easier, because their constructors can *take*
things that are easy for humans to type at the keyboard,
namely, built-in types. Then, plurals of those objects
can be typed AND built-in by subclassing builtin collections
like list, dict, and set. (But usually, if not always, list).

The code should preserve the conceptual sentence:

```text
A project has tasks.
```

not mutate it into:

```text
A project is a specialized list because that was convenient.
```

---

## 4. Ordinary language should map to ordinary code

If something really is a collection, ordinary Python should work:

```python
projects[0]
len(projects)

for project in projects:
    ...

projects.filter(lambda p: len(p) > 1)
```

When simple, slicing should preserve the semantic collection type:

```python
projects[:10]      # Projects
project.tasks[:3]  # Tasks
```

A tiny `__getitem__` is better than a typed-list framework:

```python
class Projects(list):
    def __getitem__(self, key):
        value = super().__getitem__(key)
        return type(self)(value) if isinstance(key, slice) else value
```

Prefer that over:

```python
class TypedCollectionBase(Generic[T]):
    item_type: type[T]
    collection_factory: Callable[..., "TypedCollectionBase[T]"]
    ...
```

when the generic machinery exists for one or two call sites.

A small local method is often better than a reusable abstraction nobody needed.

---

## 5. Keep semantic objects lightweight

Creating a semantic object should usually create the object, not secretly load the universe.

Good:

```python
project = Project("p-123")
rows = project.load()
```

```python
document = Document("doc-42")
rows = document.load()
```

The object can hold identity and small stable facts while expensive data is loaded explicitly.

Bad:

```python
project = Project("p-123")
# surprise: constructor read 8 GB, joined six tables, and populated caches
```

Also bad when an existing data interface already suffices:

```python
ProjectDataAccessManager(
    ProjectRepositoryAdapter(...)
).load_project(project)
```

Prefer the natural operation:

```python
project.load()
```

Explicit expensive operations are easier to understand, test, profile, and compose.

---

## 6. Put facts where they belong

Stable facts should be represented directly, once, where they conceptually live.

Good:

```python
user.user_id
user.created_at
user.locale
```

Less good:

```python
user.metadata["user_id"]
user.metadata["created_at"]
user.metadata["locale"]
```

Worse:

```python
AttributeResolver(user).resolve("locale")
```

Do not build an attribute framework when attributes say the same thing more directly.

If a stable fact conflicts across source rows, use the simplest rule justified by its meaning.

If the policy is “first recorded value wins,” write that:

```python
locale = rows["locale"].dropna().iloc[0]
```

Do not create:

```python
StableAttributeConflictResolver(
    strategy=FirstObservedValueStrategy()
)
```

for one obvious rule.

Special cases can be real. They do not each need a framework.

---

## 7. One fact, one home

Every important fact should have one obvious representation.

Prefer:

* one identity for a thing
* one collection representing its children
* one public name for a concept
* one implementation of a question
* one place deciding exports
* one place deciding configuration
* one place deriving a stable fact

Bad:

```python
EXPORTS = {"load": load}
ALIASES = {"read": "load"}
__all__ = ["load", "read"]


def read(*args, **kwargs):
    return load(*args, **kwargs)
```

Good:

```python
__all__ = ["load"]
```

If two names mean the same thing, strongly prefer choosing one.

Fundamental concepts deserve stability.

Accidental architecture does not.

### Python exports

In Python packages, one module can decide its public API:

```python
__all__ = ["Document", "Documents", "load", "latest"]
```

and the package can re-export it simply:

```python
from .documents import *
```

Do not duplicate export decisions across imports, `__all__`, registries, aliases, and forwarding functions.

**One fact, one home.**

---

## 8. Name concepts, not mechanical steps

Names should survive implementation changes.

Prefer:

```python
DocumentStore
TaskScheduler
intervals
changes
first
last
plot_changes
```

over:

```python
HashThing
QueueRunner
ResultBuilder
AnalysisDispatcher
ContextFactory
```

The best functions often describe questions or operations we naturally ask:

```python
first(history)
last(history)
intervals(events)
changes(values)
plot_changes(values)
```

not algorithm stages:

```python
build_analysis_context(...)
resolve_series_inputs(...)
dispatch_plot_kind(...)
construct_result_payload(...)
```

Naming is architecture.

---

## 9. Prefer direct code over helper soup

Private functions are not bad. Twenty private helpers for one public idea often are.

Suspicious:

```python
def analyze(events):
    normalized = _normalize_input(events)
    grouped = _prepare_groups(normalized)
    context = _build_context(grouped)
    result = _compute_result(context)
    return _format_result(result)
```

when each helper is used once and names a mechanical step.

Often clearer:

```python
def analyze(events):
    events = events.sort_values("date")
    grouped = events.groupby("entity_id")
    return grouped["value"].diff()
```

A helper deserves to exist when it names a genuine repeated concept.

Good:

```python
def intervals(dates):
    return dates.sort_values().diff()
```

Questionable:

```python
def _prepare_sorted_date_difference_input(dates):
    ...
```

Inline mechanics. Name concepts.

---

## 10. Use the abstractions you already have

Do not wrap a mature abstraction merely to make the repository feel architected.

If pandas already expresses the tabular operation clearly, use pandas.

Good:

```python
counts = df.groupby("customer_id").size()
repeated = counts[counts > 1]
```

Bad:

```python
repeated = CustomerGroupingService(
    CustomerFrameAdapter(df)
).customers_with_multiple_records()
```

Likewise, use the language, standard library, database, shell, plotting library, or framework directly when its vocabulary already matches the task.

Create another layer only when the layer itself names a meaningful recurring concept.

### Plots should correspond to ideas

Good:

```python
plot_counts(...)
plot_intervals(...)
plot_changes(...)
plot_trajectories(...)
```

Bad:

```python
build_plot_context(...)
create_analysis_panel(...)
dispatch_plot_kind(...)
resolve_plot_strategy(...)
```

Use plotting-library mechanics locally:

```python
def plot_changes(changes):
    ax = changes.hist()
    ax.set_xlabel("change")
    return ax
```

Do not create a plotting framework unless the repository is actually a plotting framework.

---

## 11. One capability, one implementation

Different interfaces may expose the same capability, but they should not reimplement it.

Good:

```python
def summarize(path):
    ...


def main(args):
    print(summarize(args.path))
```

Bad:

```python
def summarize(path):
    # Python implementation
    ...


def main(args):
    # second, subtly different CLI implementation
    ...
```

The CLI should parse arguments, call ordinary functions, and format results.

The same rule applies to GUIs, HTTP handlers, notebooks, and scripts.

One capability. Multiple interfaces if useful. One implementation.

---

## 12. Declarative design is good when the thing is data

Prefer data over branching when the data itself is the natural representation.

Good:

```python
COMMANDS = {
    "copy": {"shortcut": "c", "dangerous": False},
    "delete": {"shortcut": "d", "dangerous": True},
}
```

Less good:

```python
if command == "copy":
    shortcut = "c"
    dangerous = False
elif command == "delete":
    shortcut = "d"
    dangerous = True
```

But do not create configuration objects merely to hide obvious arguments.

Bad:

```python
config = PlotConfiguration(width=8, height=4)
plot(data, config)
```

Often better:

```python
plot(data, width=8, height=4)
```

Use data when the thing is data.

Use code when the thing is behavior.

---

## 13. DRY only after understanding the repetition

Duplication is a smell. Premature abstraction is also a smell.

Use this order:

1. Write the concrete cases.
2. Notice repetition.
3. Understand **why** they repeat.
4. Introduce the smallest abstraction that captures the real common idea.

Bad premature generalization:

```python
class OperationStrategy(Protocol):
    def apply(self, value): ...


class AddOneStrategy:
    def apply(self, value):
        return value + 1
```

when there is one operation and no evidence that “strategy” is a real concept.

Good:

```python
def increment(value):
    return value + 1
```

If three systems are secretly the same thing, unify them.

If they merely have similar syntax, do not force them together.

---

## 14. Delete aggressively, but preserve real capabilities

Existing code has no right to survive merely because it works.

Ask of every function, class, file, helper, abstraction, and test:

> **Is this a thing?**

Meaning: does it correspond to something we actually think, say, need, or promise about the problem?

Real things might include:

```text
user
project
document
version
measurement
interval
change
history
first
last
```

Things that are often not real:

```text
Resolver
Manager
Context
Builder
Adapter
Strategy
Registry
Factory
Wrapper
Spec
```

Delete freely when justified:

* abstractions with one implementation
* wrappers around wrappers
* factories that just call constructors
* builders that just collect arguments
* registries that duplicate the language namespace
* config classes packaging two or three arguments
* compatibility aliases with no demonstrated need
* duplicated representations of the same fact
* duplicated APIs for the same question
* generalized machinery serving one call site
* elaborate validation of states we construct ourselves
* forwarding methods
* helpers named after mechanics rather than concepts
* fake extensibility
* internal mini-frameworks
* code whose main justification is enabling other bad code
* tests whose only purpose is preserving such code

When one bad abstraction disappears, follow the consequences. Often several others existed only to support it.

### Delete vs. rewrite

Use this hierarchy:

1. **Not a real concept; no important capability depends on it** → delete it.
2. **Not a real concept; it supports a real capability** → remove the abstraction and implement the capability directly.
3. **Real concept; ugly implementation** → keep the concept and rewrite it.
4. **Real concept; good implementation** → leave it alone.

Example:

```python
class RecentDocumentResolver:
    def resolve(self, documents):
        return max(documents, key=lambda d: d.date)
```

The capability matters. The resolver probably does not.

Prefer:

```python
def latest(documents):
    return max(documents, key=lambda d: d.date)
```

Preserve the **question**, not the scaffolding.

### Do not start over

Aggressive deletion is not permission to replace the repository with your favorite architecture.

Keep useful domain knowledge, good algorithms, clear data transformations, important analyses, useful plots, stable concepts, and working integrations.

Remove the scaffolding between us and them.

---

## 15. APIs: stable concepts, disposable accidents

APIs are promises, but not every historical public name deserves immortality.

Preserve interfaces that are natural, conceptually stable, widely depended upon, or expensive to replace safely.

Change or remove interfaces that expose accidental architecture.

If these all mean the same thing:

```python
load_document(...)
fetch_document(...)
get_document(...)
```

pick the best one when compatibility constraints allow it.

If an API already reads like the domain, prefer stability.

If it forces users to learn internal machinery, simplify it.

Fundamental concepts deserve stable names.

Accidental architecture does not.

---

## 16. Tests are executable examples

A person should be able to browse the tests to learn the library.

Prefer tests that state small truths directly.

Good:

```python
def test_project_has_tasks():
    """Projects have tasks."""
    assert isinstance(projects()[0].tasks, Tasks)
```

Good:

```python
def test_project_length():
    """A project's length is its number of tasks."""
    project = projects()[0]
    assert len(project) == len(project.tasks)
```

Also good:

```python
def test_merge_is_commutative():
    a = Thing("a")
    b = Thing("b")
    ab = merge(a, b)
    ba = merge(b, a)
    assert ab == ba
```

This can teach more than compressing the same idea into one dense assertion:

```python
def test_merge_commutativity():
    assert merge(Thing("a"), Thing("b")) == merge(Thing("b"), Thing("a"))
```

The goal is:

> **MAXIMIZE HOW MUCH THE TEST TEACHES PER CONCEPT INTRODUCED.**

Not: minimize lines.

Delete tests that mostly preserve:

* private helpers
* internal intermediate structures
* call graphs
* mocked calls
* fake fixtures
* compatibility aliases being removed
* unnecessary validation machinery
* architecture users should not depend upon

Test things users do and truths the program promises.

### Prefer real data and real paths

When practical, tests should exercise the same kinds of data and paths used at runtime.

Prefer:

```python
documents = repository.documents()
assert documents
```

over constructing a miniature fake universe:

```python
fake_store = FakeStore()
fake_repo = MockRepository(fake_store)
monkeypatch.setattr(module, "repo", fake_repo)
...
```

when stable real or representative local data can answer the question directly.

Mocks and monkeypatching are tools, not default architecture. They are appropriate for destructive effects, remote services, nondeterminism, rare faults, or expensive boundaries.

If simple behavior becomes impossible to test without a fake universe, inspect whether the production abstraction is too indirect.

---

## 17. Understand mechanisms, not merely interfaces

When reading or explaining a system, ask:

```text
What is the primitive?
What is this built from?
What actually performs the work?
What invariant makes this safe?
Can a layer disappear?
```

Do not stop at “this function does X.” Also understand why, how, where, and what actually executes.

Examples of the preferred instinct:

* For Linux, inspect syscalls when relevant.
* For Git, understand objects and refs, not only porcelain commands.
* For SQL, inspect query plans when semantics or performance matter.
* For a language feature, understand the runtime when the abstraction leaks.
* For generated code, inspect the generated form when behavior is surprising.

Abstractions are useful. Understanding what they reduce to prevents cargo-cult design.

---

## 18. Compose simple tools; automate mechanics

Prefer small, understandable pieces that compose naturally.

```bash
tool list | grep active | tool summarize
```

```python
active = users.filter(is_active)
summary = summarize(active)
```

Prefer scriptable input/output, ordinary data structures, functions that compose, shell commands for mechanical workflows, and Makefile/task-runner rules for repeatable operations.

Humans should solve problems.

Machines should repeat themselves.

---

## 19. Performance should not corrupt the model

Measure before complicating the conceptual structure.

Prefer optimizations with clear leverage:

* better asymptotics
* less I/O
* less repeated work
* better queries
* readable vectorization
* removing needless copies
* caching with clear ownership

Do not turn:

```python
latest = max(documents, key=lambda d: d.date)
```

into a cache-coordination subsystem because it might theoretically be slow.

If requirements force complexity, isolate and explain that complexity instead of spreading it through the model.

---

## 20. Refactoring protocol

Before changing an unfamiliar area:

1. Read the implementation.
2. Read its public interfaces.
3. Read the tests.
4. Read examples, docs, notebooks, presentations, or scripts that reveal what users actually ask the software to do.
5. Run representative paths when practical.
6. Understand current behavior before deleting based on names alone.

Then:

### A. Write down the real capabilities

For example:

```text
list projects
get a project's tasks
count tasks
find first and last activity
compute intervals
compute changes
plot history
load underlying data
```

These are what must survive.

### B. Reduce the area to its ontology

```text
project
projects
task
tasks
date
interval
change
history
plot
```

Then ask why anything else exists.

### C. Remove accidental architecture

Look especially for:

```text
managers
adapters
factories
wrappers
registries
contexts
schemas
strategies
resolvers
builders
orchestration
helper layers
internal frameworks
```

Try expressing the real capability directly.

### D. Collapse duplicate representations

If the same fact lives in three places, choose one.

If the same question has four APIs, keep the best one.

### E. Simplify tests with the production model

Tests should become simpler because the model became simpler, not because assertions became denser.

### F. Run tests and inspect the diff manually

Look for both failure modes:

1. Cruft survived because it already existed.
2. A real capability disappeared because its old implementation was ugly.

If the second happened, restore the **capability** with a simpler implementation.

---

## 21. Final-pass smell test

Be suspicious of every remaining:

```text
helper
wrapper
adapter
manager
resolver
builder
config class
registry
forwarding function
compatibility alias
mock fixture
fake dataset
private mini-framework
```

Ask whether it corresponds to something real.

If not, try deleting it and simplifying what remains.

Also ask the opposite question:

> Did simplification erase an important real-world question or useful capability?

If so, restore the question without restoring the accidental architecture.

---

## 22. The standard for code worth maintaining

Code worth maintaining has these properties:

* The library reads like a vocabulary, not infrastructure.
* Types correspond to things that exist in the world or in ordinary thought.
* Functions correspond to operations or questions we naturally ask about those things.
* Important facts have one obvious representation.
* Public concepts are stable; implementation machinery is disposable.
* Expensive behavior is explicit.
* Tests teach the API.
* Abstractions are earned by repeated real structure.
* Existing powerful abstractions are used directly rather than wrapped reflexively.
* Interfaces compose.
* The implementation can be explained without reciting a bureaucracy of layers.

Use the Zen of Python seriously, especially:

```text
Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Flat is better than nested.
Readability counts.
There should be one-- and preferably only one --obvious way to do it.
If the implementation is hard to explain, it's a bad idea.
```

If a function exists only because another function was written badly, neither necessarily deserves to survive.

If five abstractions can become one obvious expression, prefer the expression.

If deleting 200 lines makes the remaining 50 reveal the idea, delete the 200 lines.

If deleting 50 lines destroys a fundamental useful capability, rewrite those 50 lines instead.

Do not optimize for preserving code.

**Optimize for preserving reality.**

The best refactoring is not merely:

> That's shorter.

or:

> That's faster.

It is:

> **I hadn't realized those were actually the same idea.**

The final measure is:

> **HOW MUCH OF THE REMAINING CODE LOOKS LIKE THE WORLD, AND HOW LITTLE OF IT LOOKS LIKE “CODE”?**

