
## Meaning

### Worse is Better - The New Jersey style

Also known as The UNIX Philosophy.
#### Simplicity
- The design must be simple, both in implementation and interface. 
- _It is more important for the implementation to be simple than the interface._
- Simplicity is the most important consideration in a design.
#### Correctness
- The design should be correct in all observable aspects.
- It is slightly better to be simple than correct.
#### Consistency
- The design must not be overly inconsistent.
- Consistency can be sacrificed for simplicity in some cases.
- It is better to drop those parts of the design that deal with less common circumstances than to introduce either complexity or inconsistency in the implementation.
#### Completeness
- The design must cover as many important situations as is practical.
- All reasonably expected cases should be covered.
- Completeness can be sacrificed in favor of any other quality.
- Completeness must be sacrificed whenever implementation simplicity is jeopardized.
- Consistency can be sacrificed to achieve completeness if simplicity is retained.
- Consistency of interface is especially worthless.

### The Right Thing - The MIT Approach

#### Simplicity
- It is more important for the interface to be simple than the implementation.
#### Correctness
- The design must be correct in all observable aspects. Incorrectness is simply not allowed.
#### Consistency
- The design must be consistent.
- A design is allowed to be slightly less simple and less complete to avoid inconsistency.
- Consistency is as important as correctness.
#### Completeness
- The design must cover as many important situations as is practical.
- All reasonably expected cases must be covered.
- Simplicity is not allowed to overly reduce completeness.

%%
Benefits
- [[Brian Kernighan - Lex Fridman Short]]

Sources 
- [Worse is Better](https://dreamsongs.com/WorseIsBetter.html) original essay, Richard P. Gapriel (1989)
- [Worse is Better](https://en.wikipedia.org/wiki/Worse_is_better) on wikipedia.
%%