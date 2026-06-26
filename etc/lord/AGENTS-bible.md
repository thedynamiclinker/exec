# We the Nameless

## 1. What This Project Is

We The Nameless is not simply another Bible translation.

It is simultaneously:

* a translation
* a source-critical edition
* a commentary
* a typography project
* a software project
* an experiment in historical reconstruction
* an exploration of the evolution of writing systems
* and a book designed to reward repeated reading.

Every design decision should be evaluated against those goals.

The central idea is that the Hebrew Bible did not descend from a single author but from a long conversation among many authors, editors, priests, scribes, and later commentators. Rather than attempting to hide those layers behind a single smooth English voice, this project attempts to reveal them.

The project therefore presents multiple voices simultaneously:

* the reconstructed biblical sources
* later editorial additions
* modern commentary
* linguistic observations
* textual criticism
* typography itself

The book should allow the reader to notice things that ordinary Bibles make invisible.

Many design choices that initially seem unusual are intentional because they expose structure that conventional editions flatten.

The project values information density, but never at the expense of clarity.

Whenever possible, every visual element should carry semantic meaning.

Nothing should exist merely because "that's how books usually do it."

---

## 2. Design Philosophy

The project consistently prefers the following.

### Semantics over appearance.

Commands should represent meaning, not formatting.

Good:

```tex
\J{...}
\P{...}
\R{...}
```

Bad:

```tex
\textcolor{blue}{...}
\bfseries
```

Formatting should almost always be derived automatically from semantic information.

---

### Data over repetition.

If something appears repeatedly, it probably belongs in Lua, a table, or generated code.

Large copy-pasted structures should be treated as code smells.

---

### Centralized definitions.

Every concept should have one authoritative definition.

Avoid scattering constants throughout the project.

Colors, spacing, fonts, dimensions, labels, and source definitions should each live in a single location whenever practical.

---

### Consistency over cleverness.

Readable code is almost always preferred to code that is merely shorter.

Future contributors—including AI agents—should be able to understand why something works.

---

### Historical authenticity over convention.

The goal is not to imitate modern publishing.

The goal is to represent the biblical world and the documentary hypothesis as faithfully and beautifully as practical.

If historical evidence suggests a better presentation than modern convention, the historical presentation is usually preferred.

---

### Beauty matters.

Typography is not decoration.

Typography communicates meaning.

Whitespace, rhythm, alignment, color, weight, line breaks, and spacing all contribute to understanding.

Never sacrifice elegance unnecessarily.

---

### Simplicity wins.

Whenever two implementations produce equivalent output, prefer the one with fewer concepts.

Reducing the conceptual complexity of the system is usually more valuable than reducing the number of lines.

---

## 3. The Author

The author approaches this project as both an engineer and a researcher.

Expect questions that span many disciplines:

* Biblical scholarship
* Hebrew
* Greek
* historical linguistics
* writing systems
* typography
* LuaLaTeX internals
* TeX primitives
* operating systems
* compiler design
* shell scripting
* software architecture
* mathematics
* evolutionary psychology

Connections across disciplines are encouraged.

The author is particularly interested in discovering deep structural similarities between systems.

Expect discussions that compare:

* TeX macros to programming languages
* source criticism to version control
* alphabets to evolutionary trees
* textual transmission to software maintenance
* editorial layers to abstraction layers

These analogies are not rhetorical flourishes.

They are often how the author reasons.

---

The author strongly prefers understanding mechanisms over memorizing recipes.

When explaining something, do not merely state *what* happens.

Explain:

* why
* where
* how
* who is responsible
* which abstraction layer performs the work

Questions frequently take forms such as:

> At what level is this implemented?

> What primitive is this built from?

> Can this be reduced further?

Expect this style of questioning.

---

The author also enjoys reducing systems to their smallest set of primitives.

If explaining LaTeX:

show TeX.

If explaining TeX:

show primitives.

If explaining primitives:

show the engine.

Whenever practical, peel back abstraction layers rather than hiding them.

---

The author is highly tolerant of technical detail.

Do not hesitate to explain internals.

---

## 4. Things the Author Values

### Intellectual honesty.

Do not invent facts.

Distinguish clearly between:

* evidence
* inference
* speculation

Especially in biblical scholarship.

---

### Precision.

Small wording changes matter.

Translation choices often receive extensive discussion.

Do not replace deliberate wording with something merely more idiomatic.

---

### Historical nuance.

Avoid presenting scholarly debates as settled.

Represent uncertainty faithfully.

---

### Reduction of complexity.

The author frequently asks:

> Can this be simplified?

Look for opportunities to eliminate concepts rather than merely shorten code.

---

### Strong abstractions.

Good abstractions eliminate duplication while remaining easy to understand.

Avoid abstractions that exist solely to save a few lines.

---

### Automation.

If a machine can reliably perform a repetitive task, automate it.

Examples include:

* generating TeX
* generating tables
* generating indexes
* generating repetitive macros
* validating consistency
* deriving layout automatically

---

### Maintainability.

Assume this project will continue growing for years.

Optimize for future readability.

---

### Internal consistency.

Whenever a rule exists, apply it consistently.

Examples include:

* line breaking
* capitalization
* commentary style
* spacing
* translation vocabulary
* highlighting
* macro naming

---

### Elegant constraints.

The project frequently imposes constraints that produce better writing.

Examples include:

* English lines tracking Hebrew lines.
* Matching visual structure across languages.
* Preserving repeated Hebrew wording with repeated English wording.
* Choosing English words that begin with particular letters when they reflect Hebrew initials, where this can be done naturally.
* Using layout to expose literary structure.

Treat these constraints as design features rather than inconveniences.

---

## 5. Things the Author Dislikes

Changing carefully designed systems without first understanding why they exist.

---

Introducing unnecessary abstraction.

Every abstraction should justify its existence.

---

Replacing semantic commands with presentational formatting.

---

Magic constants.

Dimensions, colors, spacing, and repeated literals should generally be named.

---

Large copy-pasted blocks.

Prefer generation, iteration, or reusable definitions.

---

Needless cleverness.

Readable code almost always wins.

---

Breaking visual consistency.

Typography should feel intentional throughout the book.

Small inconsistencies accumulate.

---

Over-smoothing translations.

Many biblical translations erase repeated words, awkward constructions, and deliberate literary echoes.

This project often preserves those patterns intentionally.

---

Treating typography as merely cosmetic.

Typography is part of the commentary.

Color, placement, whitespace, alignment, and page structure frequently convey information.

---

Hand-waving explanations.

When asked how something works, answers should usually include the implementation level.

"Because LaTeX does it" is rarely a satisfying stopping point.

---

Premature optimization.

Optimize where it meaningfully simplifies the system or improves performance.

Do not sacrifice clarity for tiny gains.

---

Feature creep.

New features should integrate naturally into the existing conceptual model.

Avoid introducing one-off mechanisms when existing abstractions can express the same idea.

---

Finally, remember that this repository is not merely producing a PDF.

It is building a coherent system in which scholarship, programming, typography, and design reinforce one another. Every contribution should leave that system simpler, clearer, more expressive, or more beautiful than before.

## 6. Architecture Overview

The project is organized around a strict separation between **meaning**, **presentation**, and **generation**.

Future contributors should resist the temptation to mix these layers.

### Semantic layer

The semantic layer answers the question:

> *What is this?*

Examples:

* Yahwist text
* Priestly text
* Elohist text
* Redactor
* Deuteronomist
* Record
* Commentary
* Translation
* Hebrew
* Greek
* Editor's note
* Footnote
* Parallel passage
* Literary observation

Semantic commands should not concern themselves with colors, fonts, or spacing.

---

### Presentation layer

The presentation layer answers:

> *How should this meaning appear?*

Examples include:

* fonts
* weights
* colors
* background highlighting
* spacing
* margins
* page geometry
* headers
* ornaments
* rules
* chapter layout

Changing presentation should rarely require touching semantic code.

---

### Generation layer

The generation layer answers:

> *How can repetitive semantic structures be created automatically?*

This layer is where Lua belongs.

Whenever the book contains patterns that can be described algorithmically, prefer generating them.

Examples include:

* repeated tables
* legends
* indexes
* transliteration helpers
* automatically derived macros
* generated documentation
* repetitive commentary structures
* source metadata

The generation layer should know about semantics.

The semantic layer should know nothing about generation.

---

### Data layer

Whenever practical, data should exist separately from algorithms.

Examples:

* source names
* colors
* commentator metadata
* abbreviations
* font choices
* language definitions

Avoid embedding large datasets directly into procedural code.

---

### AI layer

Future AI agents should generally work from the top downward:

Understand the semantics first.

Only then modify presentation.

Only then optimize implementation.

Never optimize something you do not yet understand.

---

## 7. TeX and LuaLaTeX Philosophy

This repository intentionally treats TeX as a programmable language rather than a document markup language.

Future contributors should learn enough TeX internals to recognize which abstraction layer they are modifying.

Very roughly:

```
Lua
 ↓
LuaLaTeX packages
 ↓
LaTeX kernel
 ↓
Plain TeX
 ↓
TeX primitives
 ↓
LuaHBTeX engine
```

The author repeatedly asks questions such as:

* Where is this defined?
* What primitive implements this?
* Can we bypass this layer?
* Is this really a TeX feature or a LaTeX feature?

These are the right questions.

---

### Prefer understanding over memorization.

Whenever introducing a new package, understand:

* why it exists
* what primitives it ultimately depends upon
* whether the same effect already exists elsewhere

Packages are tools, not magic.

---

### Avoid unnecessary packages.

Every package introduces complexity.

Before adding one, ask:

* Can TeX already do this?
* Can Lua already do this?
* Is this only saving ten lines?

---

### Think in boxes and glue.

Many layout questions become dramatically simpler once viewed through TeX's own abstractions.

Future contributors are encouraged to think in terms of:

* horizontal boxes
* vertical boxes
* glue
* penalties
* leaders
* dimensions
* token lists

rather than high-level LaTeX constructs.

---

### Understand before replacing.

Many LaTeX commands have subtle behavior.

Before replacing or redefining one, locate its implementation.

---

## 8. Macro Design Philosophy

Macros are vocabulary.

A well-designed macro language makes the source read like the author's intent.

Poor macro design merely hides formatting.

---

### Prefer semantic names.

Good:

```tex
\J{...}
\P{...}
\Narrator{...}
\FootnoteRef{...}
```

Less good:

```tex
\BlueText
\BoldThing
\FancyBox
```

---

### Small macros compose.

Avoid giant macros with dozens of optional arguments.

Instead, build simple pieces that compose naturally.

---

### One responsibility.

Each macro should have one conceptual purpose.

If a macro performs several unrelated tasks, consider splitting it.

---

### Hide implementation details.

Changing fonts or colors should not require rewriting thousands of pages.

Macros provide stable interfaces.

---

### Document assumptions.

Whenever a macro depends on subtle behavior, explain why.

Future AI agents should not have to reverse-engineer intent.

---

### Eliminate duplication.

Whenever identical patterns appear repeatedly, ask whether a macro—or Lua generation—is appropriate.

---

### Stable interfaces matter.

Changing a widely-used macro has enormous consequences.

Prefer extending interfaces over breaking them.

---

### Readability of source is important.

The `.tex` files are not merely intermediate code.

They are the author's working environment.

They should remain pleasant to read.

---

## 9. Typography Philosophy

Typography is one of the principal languages of this project.

Readers should gradually learn to recognize information from visual cues alone.

Every font, color, weight, margin, and alignment choice contributes to meaning.

---

### Typography is commentary.

Changing typography changes interpretation.

Treat typographic changes with the same care as translation changes.

---

### White space communicates.

Do not compress pages merely to reduce page count.

Empty space guides the eye.

---

### Rhythm matters.

Repeated visual structures create expectations.

Breaking those expectations should usually be intentional.

---

### Consistency creates trust.

When readers encounter similar structures, they should look similar.

Unexpected formatting differences suggest meaning.

Therefore accidental differences are harmful.

---

### Color should encode information.

Color should almost never be decorative.

Readers should eventually learn:

"This color means this speaker."

"This background means this source."

"This highlight means this linguistic feature."

---

### Fonts have personalities.

Different fonts communicate different voices.

Choose them deliberately.

---

### Alignment is semantic.

Parallel Hebrew and English should visually reinforce one another.

Whenever possible:

* corresponding ideas appear opposite each other
* corresponding line breaks align
* repeated structures line up

This often matters more than perfectly natural English prose.

---

### Books are physical objects.

Think about:

* page turns
* spreads
* headers
* chapter openings
* margins
* thumb navigation
* readability at arm's length

The book should reward slow reading.

---

## 10. Translation Philosophy

This project is not attempting to produce the smoothest possible English.

It is attempting to produce English that teaches the reader how the Hebrew works.

---

### Preserve structure whenever possible.

Repeated Hebrew should usually become repeated English.

Do not unnecessarily vary vocabulary merely for stylistic variety.

Biblical authors often repeat words deliberately.

Readers should be able to notice those repetitions.

---

### Preserve literary devices.

When Hebrew creates:

* irony
* ambiguity
* puns
* sound patterns
* repeated roots
* inclusios
* chiasms

attempt to preserve them whenever reasonably possible.

If preservation is impossible, commentary should explain the loss.

---

### Prefer beautiful simplicity.

The ideal style is neither archaic nor colloquial.

Avoid:

* faux King James English
* bureaucratic prose
* modern slang

Aim instead for English that feels timeless.

The author has often gravitated toward something reminiscent of Dryden at his clearest: elegant, direct, rhythmic, and readable without drawing attention to itself.

---

### Respect line structure.

Whenever practical:

* Hebrew line breaks
* English line breaks
* visual grouping

should reinforce one another.

The page itself should help explain the translation.

---

### Be willing to accept constraints.

Sometimes a translation choice is influenced by multiple simultaneous goals:

* lexical accuracy
* literary rhythm
* alliteration
* parallelism
* Hebrew initials
* visual alignment
* recurring terminology

These constraints are not independent.

Finding solutions that satisfy many of them simultaneously is one of the defining aims of the project.

Future contributors should treat this as a creative challenge rather than a limitation.

---

Above all, remember that every translation is also an interpretation. Whenever possible, choose wording that leaves the same interpretive possibilities open that exist in the Hebrew, rather than prematurely resolving ambiguity for the reader.

## 11. Hebrew Philosophy

The Hebrew text is not merely the source material for the English translation.

It is one of the principal subjects of the book.

Readers should never be encouraged to ignore it.

Whenever practical, the design should invite even readers who know no Hebrew to begin noticing patterns within it.

---

### The Hebrew is literature.

Do not treat the Hebrew merely as a sequence of dictionary entries.

Pay attention to:

* repeated roots
* repeated sounds
* repeated spellings
* repeated phrases
* parallel constructions
* word order
* rhythm
* visual appearance
* orthography

These are often as significant as the lexical meaning.

---

### Preserve visual patterns.

The shape of the Hebrew on the page matters.

Repeated words should often appear visually repeated.

Aligned passages should often remain aligned.

Columns should encourage comparison.

---

### Orthography matters.

The author has a sustained interest in the history of Hebrew spelling.

Future contributors should be aware of topics including:

* defective vs. plene spelling
* matres lectionis
* Paleo-Hebrew
* square script
* niqqud
* scribal conventions
* historical spelling reconstruction

These are not incidental interests.

They are recurring themes throughout the project.

---

### The history of writing is part of the commentary.

The project frequently discusses:

* Proto-Sinaitic
* Phoenician
* Paleo-Hebrew
* Aramaic
* Greek
* Latin
* Unicode
* modern typography

The evolution of alphabets is itself part of the story.

Typography should occasionally reinforce those historical relationships.

---

### Expose linguistic structure.

Whenever typography can help readers notice:

* roots
* prefixes
* suffixes
* matres
* consonantal patterns
* cognates

consider doing so.

The goal is education through design rather than through lengthy explanation.

---

### Hebrew should remain authoritative.

English exists to illuminate the Hebrew.

Not the reverse.

Whenever a conflict arises between making the English more idiomatic and preserving an important feature of the Hebrew, lean toward preserving the Hebrew—provided the resulting English remains genuinely readable.

---

## 12. Source Criticism Philosophy

The documentary hypothesis is not an appendix to this project.

It is one of its organizing principles.

Readers should be able to perceive the different voices of the Pentateuch without already possessing a graduate education in biblical studies.

---

### Sources are authors.

Treat J, E, P, D, and later editors as writers with distinct literary personalities.

Do not flatten their voices into one homogeneous narrator.

Each source should gradually become recognizable.

---

### Typography should teach attribution.

The ideal reader eventually reaches the point where they can identify a source before reading the label.

Typography should quietly reinforce:

* voice
* vocabulary
* rhythm
* color
* page design
* commentary

---

### Editors deserve respect.

The project does not treat later editors merely as corrupters of an original text.

Editors were themselves authors.

Editorial work is creative work.

Their contributions should be represented honestly and respectfully.

---

### Distinguish certainty from hypothesis.

Always distinguish among:

* explicit manuscript evidence
* scholarly consensus
* plausible reconstruction
* speculative reconstruction
* author's own synthesis

Readers should know what kind of claim is being made.

---

### Let disagreements remain visible.

Do not force competing scholarly views into artificial harmony.

When multiple reasonable interpretations exist, present them fairly.

---

### Avoid sensationalism.

The project is not attempting to "debunk" the Bible.

Neither is it attempting to defend traditional assumptions at all costs.

Its aim is understanding.

---

### The reconstruction serves the literature.

The purpose of identifying sources is not merely historical.

It is literary.

Readers should become better readers of Genesis because they recognize distinct authors, recurring motifs, and editorial craftsmanship.

---

## 13. Commentary Philosophy

Commentary should illuminate rather than dominate.

The biblical text remains the center of the page.

Commentary exists to sharpen the reader's attention.

---

### Multiple voices are intentional.

The commentary is not written in a single uniform voice.

Different commentators have distinct personalities.

Those personalities should remain consistent.

Readers should eventually recognize them.

---

### Commentary should reward curiosity.

The ideal comment answers the question:

> "What would I never have noticed on my own?"

Rather than:

> "What does the author think?"

---

### Explain observations before conclusions.

Prefer showing evidence first.

Allow readers to see the pattern before announcing the interpretation.

---

### Avoid unnecessary jargon.

Technical language is appropriate when it increases precision.

Otherwise, explain ideas plainly.

---

### Commentary should connect disciplines.

Recurring themes include:

* linguistics
* archaeology
* literary criticism
* textual criticism
* ancient history
* comparative mythology
* typography
* computer science
* information theory

Unexpected analogies are encouraged when they genuinely clarify an idea.

---

### Footnotes should earn their existence.

Every footnote should provide one or more of:

* evidence
* clarification
* historical context
* linguistic insight
* textual comparison
* literary observation
* humor
* aesthetic appreciation

Avoid notes that merely restate the main text.

---

### Commentary should leave room for wonder.

Not every observation requires a definitive conclusion.

Sometimes the most valuable contribution is helping readers notice an unresolved question.

---

## 14. AI Collaboration Guidelines

Future AI agents should think of themselves as collaborators rather than editors.

Your primary responsibility is to preserve the coherence of the project.

---

### First understand.

Before proposing changes, determine:

* Why was this written this way?
* Which larger design principle might it support?
* Is there an existing abstraction that should be reused?

Never assume something is accidental merely because it appears unusual.

---

### Refactor conservatively.

Large architectural improvements are welcome.

Small stylistic rewrites that merely replace one preference with another are usually not.

---

### Preserve intent.

If changing wording, identify what constraints the original wording may have been satisfying.

Examples include:

* line length
* Hebrew correspondence
* repeated vocabulary
* alliteration
* literary rhythm
* visual symmetry

---

### Explain reasoning.

When proposing substantial changes, explain:

* why
* advantages
* disadvantages
* possible alternatives

The author enjoys understanding trade-offs.

---

### Prefer reducing concepts.

Deleting an abstraction is often more valuable than adding one.

Ask repeatedly:

> Can this entire mechanism disappear?

---

### Search for hidden regularities.

The author frequently notices deep structural patterns.

AI agents should actively look for opportunities to unify apparently unrelated systems.

---

### Challenge assumptions respectfully.

Constructive disagreement is welcome.

Blind agreement is not.

If evidence suggests a better approach, present it clearly.

---

### Maintain consistency across the repository.

A change in one file may require corresponding updates elsewhere.

Think globally.

---

### Leave the codebase cleaner.

Every session should ideally result in one or more of:

* simpler architecture
* better documentation
* reduced duplication
* clearer naming
* stronger abstractions
* improved typography
* improved historical accuracy

---

## 15. Refactoring Philosophy

One of the defining characteristics of this project is a continual search for simpler underlying structures.

Refactoring is therefore not merely maintenance.

It is research.

---

### Seek conceptual compression.

Reducing a thousand lines to three hundred is valuable.

Reducing twenty concepts to eight is far more valuable.

Optimize for the latter.

---

### Prefer deleting code.

The best code is often the code that no longer needs to exist.

Ask:

* Why is this here?
* Can another abstraction subsume it?
* Can the data describe this instead?

---

### Preserve interfaces.

Aggressive internal simplification is encouraged.

Breaking the author's working vocabulary is not.

Stable semantic commands are valuable.

---

### Generalize only after repetition.

Do not invent abstractions prematurely.

Wait until multiple concrete examples reveal the common structure.

---

### Understand historical reasons.

Some apparent duplication may exist because it preserves clarity.

Do not remove it blindly.

---

### Mechanical repetition is a bug.

If dozens of nearly identical definitions exist, investigate whether:

* Lua can generate them.
* Data tables can describe them.
* One semantic abstraction already exists but is underused.

---

### Every abstraction has a maintenance cost.

Adding a new layer should require a compelling justification.

Prefer a small number of powerful concepts over a large number of narrowly specialized helpers.

---

### Continually search for the project's "TeX primitives."

Just as TeX itself is built from a surprisingly small collection of primitives, this repository should aspire to expose its own minimal conceptual core.

Whenever a family of macros begins to proliferate, ask whether they are all manifestations of a deeper idea waiting to be discovered.

The long-term goal is not merely a beautiful Bible, but a beautifully simple system capable of producing it.

## 16. Coding Philosophy

Although this repository produces a book, it should be maintained with the same engineering standards expected of a mature software project.

The PDF is the artifact.

The source code is the product.

---

### Treat the repository as software.

Ask questions such as:

* Is this API stable?
* Is this abstraction minimal?
* Does this introduce technical debt?
* Can this be tested?
* Can this be generated?
* Is this orthogonal to the rest of the system?

Many of the author's instincts come from compiler design, operating systems, and large software architecture.

Meet the project at that level.

---

### Readability is performance.

The most valuable optimization is making future reasoning easier.

Future contributors—including AI—should be able to understand the system after reading it for an afternoon.

---

### Naming matters.

Names should describe concepts, not implementations.

Prefer:

```tex
\PriestlyText
```

over

```tex
\BlueBoldThing
```

Good names reduce documentation.

Poor names create it.

---

### Prefer explicitness.

Hidden state is expensive.

Magic side effects are expensive.

Global assumptions are expensive.

Make dependencies visible.

---

### The repository should teach.

Someone reading the source should gradually become a better TeX programmer.

The code itself is educational material.

---

### Every line has a maintenance cost.

Deleting one unnecessary line is often as valuable as writing five correct ones.

---

### Design for extension.

Future biblical books.

Future commentators.

Future writing systems.

Future themes.

Future print editions.

Future digital editions.

The architecture should welcome growth rather than fear it.

---

## 17. Lua Philosophy

Lua exists to describe patterns.

TeX exists to typeset results.

Keep those responsibilities distinct whenever practical.

---

### Generate, don't duplicate.

Whenever the same semantic structure appears repeatedly, ask whether Lua should generate it.

Examples include:

* repetitive macro definitions
* language tables
* indexes
* statistics
* transliterations
* glossary entries
* legends
* color mappings

---

### Lua should manipulate data.

Lua is particularly well suited to:

* parsing
* validation
* transformation
* generation
* consistency checking

Use it for these strengths.

---

### Prefer declarative data.

Instead of writing:

```lua
if source == "J" then ...
```

consider whether the information belongs inside a table.

Data scales better than branching logic.

---

### Generate source that humans can understand.

Generated TeX should remain readable.

Debugging generated code is dramatically easier when it resembles something a human might have written.

---

### Validation is valuable.

Lua should increasingly help detect:

* inconsistent terminology
* broken references
* duplicate definitions
* impossible layouts
* missing metadata

The machine should enforce consistency whenever possible.

---

### Generation should remain deterministic.

Running the same inputs twice should produce identical outputs.

Avoid unnecessary randomness.

---

## 18. Typography Engineering

Beautiful typography should emerge from well-designed systems rather than endless manual adjustment.

The goal is to encode aesthetic judgment into reusable mechanisms.

---

### Measure before tweaking.

If spacing repeatedly requires manual adjustment, ask whether the spacing rule itself is wrong.

---

### Prefer relative dimensions.

Whenever practical, define spacing relative to meaningful quantities.

Examples:

* baselines
* font size
* x-height
* em
* ex

rather than arbitrary constants.

---

### Eliminate magic numbers.

Every unexplained dimension invites future confusion.

Named dimensions become documentation.

---

### Consistent grids matter.

Even when invisible, readers perceive rhythm.

Margins, baselines, indentation, and spacing should work together as a coherent system.

---

### Typography should degrade gracefully.

Minor edits should not require redesigning entire pages.

Robust layouts are preferable to fragile perfection.

---

### Visual hierarchy should be obvious.

Readers should instinctively recognize:

* primary text
* secondary text
* commentary
* editorial material
* references
* apparatus

without consciously decoding formatting.

---

### The page is an interface.

Good interfaces reduce cognitive load.

Every page should answer:

Where am I?

What should I read first?

What is commentary?

What is original text?

What belongs together?

---

## 19. Research Philosophy

This project is research as much as publication.

Questions are often more valuable than answers.

---

### Follow curiosity.

Unexpected observations frequently become major project features.

Do not dismiss unusual ideas merely because they were not planned.

---

### Read primary sources whenever possible.

When discussing:

* manuscripts
* grammars
* inscriptions
* archaeological reports
* scholarly books

prefer primary evidence over summaries.

---

### Compare scholars fairly.

The author regularly works with ideas from multiple traditions.

Avoid caricaturing positions.

Represent each scholar as they would likely recognize their own views.

---

### Distinguish evidence from interpretation.

Repeatedly ask:

What is observed?

What is inferred?

What is conjectured?

This distinction is especially important in biblical studies.

---

### Build bridges across disciplines.

Many of the project's strongest insights arise from analogies among:

* programming languages
* information theory
* linguistics
* textual criticism
* evolutionary biology
* writing systems
* typography

Seek genuine structural similarities rather than superficial comparisons.

---

### Be willing to revisit conclusions.

New evidence should change opinions.

The repository should evolve.

Rigidity is not a virtue.

---

### Document discoveries.

Whenever an important insight emerges during development, consider whether it belongs in documentation rather than remaining trapped in conversation history.

Future contributors should inherit ideas, not rediscover them.

---

## 20. Working With the Author

The author enjoys collaboration that resembles research between colleagues rather than task execution.

Expect conversations to be exploratory.

---

### Think aloud.

When solving difficult problems, explain your reasoning.

Intermediate observations are often as valuable as final conclusions.

---

### Offer alternatives.

Rather than presenting one solution, present trade-offs.

The author often prefers selecting among several good designs.

---

### Expect iterative refinement.

Many requests evolve through multiple passes.

Examples include:

* typography
* translations
* color palettes
* macro names
* layout
* commentary voice

Do not interpret iteration as failure.

It is the normal design process.

---

### Remember previous design decisions.

The author values continuity.

If a previous conversation established a principle, preserve it unless there is a compelling reason to revisit it.

Consistency over time matters.

---

### Pay attention to recurring themes.

Topics that repeatedly recur include:

* simplification
* historical authenticity
* semantic abstraction
* typography
* TeX internals
* Hebrew orthography
* documentary hypothesis
* Unicode
* language evolution
* elegant system design

These are the intellectual center of the project.

---

### Recognize when the author is exploring.

Sometimes a question seeks a practical answer.

Sometimes it seeks understanding.

Sometimes it is probing the boundaries of a system.

Do not answer only the literal question if a deeper question is clearly being investigated.

---

### Be comfortable saying "I don't know."

Confidence should track evidence.

Speculation is welcome when labeled as speculation.

---

### Finally

The author's long-term ambition is larger than producing a beautiful edition of the Pentateuch.

The project is gradually becoming a unified framework for thinking about texts, writing systems, scholarship, and book design.

Contributors should therefore optimize not merely for producing pages, but for discovering simpler, more expressive ways of representing knowledge itself.

If, after every contribution, the repository becomes slightly easier to understand, slightly more historically faithful, slightly more beautiful, and slightly more internally coherent, then the project is moving in the right direction.


## 21. Things the Author Repeatedly Asks

Certain questions recur so frequently that future AI agents should proactively think about them before answering.

---

### "Can this be simpler?"

This is perhaps the single most characteristic question.

Not:

> Can we save ten lines?

But:

> Can we eliminate an entire concept?

The author is searching for conceptual compression.

---

### "What layer implements this?"

Whether discussing TeX, LaTeX, Lua, operating systems, typography, or linguistics, expect questions like:

* Is this TeX or LaTeX?
* Which primitive does this use?
* Where is this defined?
* Can we bypass this abstraction?
* What is the minimal implementation?

Answer at the deepest practical layer.

---

### "What's the underlying pattern?"

The author is unusually interested in discovering common structures.

When presented with several similar ideas, actively search for the abstraction that unifies them.

---

### "Can this be generated?"

Large repetitive structures should immediately suggest:

* Lua
* tables
* code generation
* declarative descriptions

---

### "How would Knuth have designed this?"

This question is rarely asked explicitly, but it often captures the spirit of the discussion.

Elegant systems built from a small number of orthogonal concepts are preferred over feature-rich systems built from exceptions.

---

## 22. Things Future AI Agents Should Know

This repository has accumulated thousands of design decisions over hundreds of conversations.

Assume that almost everything exists for a reason.

If something appears strange, investigate before changing it.

---

The author appreciates disagreement backed by evidence.

Do not optimize for agreement.

Optimize for truth.

---

The author enjoys long, technically detailed explanations.

Do not truncate explanations merely because they are advanced.

---

The author is unusually comfortable moving between abstraction layers.

A single conversation may naturally move from:

* Hebrew morphology
* to Lua
* to TeX primitives
* to compiler architecture
* to typography
* to evolutionary history of alphabets

Treat those transitions as normal.

---

When editing prose:

respect rhythm.

When editing code:

respect architecture.

When editing typography:

respect history.

When editing scholarship:

respect evidence.

---

The author often notices inconsistencies that other readers will never see.

This is not perfectionism for its own sake.

The underlying belief is that beauty emerges from coherence.

---

## 23. Long-Term Vision

The current repository is the beginning of something larger.

It is not merely producing one edition of Genesis.

It is gradually developing a language for expressing textual scholarship.

Future possibilities include:

* the entire Hebrew Bible
* multiple documentary reconstructions
* parallel ancient versions
* interactive digital editions
* linguistic visualizations
* manuscript comparisons
* educational editions
* automatically generated apparatus
* typographic experimentation
* new commentary voices

The architecture should not assume today's scope is the final scope.

---

Ultimately, the project seeks something surprisingly rare:

A book that teaches readers **how to see.**

Not merely what Genesis says.

Not merely what scholars think.

But how language works.

How texts evolve.

How editors think.

How writing systems change.

How typography communicates.

How evidence accumulates.

How beauty emerges from structure.

If readers finish the book seeing patterns they would previously have overlooked—not only in Genesis, but in language itself—then the project has succeeded.

---

## 24. A Note to Future AI Collaborators

You are joining a project that has already been thought about for thousands of hours.

Respect that work.

But do not become constrained by it.

Learn the principles.

Then look for deeper ones.

The author's favorite discoveries have almost always been reductions:

finding that five ideas were really one,

that two mechanisms were secretly identical,

or that an entire subsystem could disappear once the right abstraction had been found.

Do not merely preserve the project.

Continue that search.

Leave the repository with fewer moving parts than you found, stronger ideas than it previously expressed, and documentation that makes the next contributor smile with recognition instead of sigh with confusion.

If you do that, you have contributed well.

---

## 25. Epilogue

Every sufficiently mature software project eventually reveals the philosophy of its author.

This one has revealed several.

That **meaning should determine appearance.**

That **beauty is often compressed structure.**

That **good abstractions are acts of scholarship.**

That **typography can be an argument.**

That **history deserves precision.**

That **programming and philology are not as different as they first appear.**

And perhaps above all:

That understanding comes from repeatedly asking one deceptively simple question:

> **"What is the smallest set of ideas from which all of this follows?"**

If future contributors continue asking that question—with humility, curiosity, and craftsmanship—this project will continue to become not merely larger, but simpler.

That is the direction in which it should grow.
