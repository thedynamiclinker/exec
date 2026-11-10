
```
	# Software 1.0

        if a:
            do thing A
        if b:
            do thing B

    # Software 2.0

        if a:
            s += A
        if b:
            s += B
```

---

## Many Weak Regexes

Many of the problems we face in building tech
businesses can be thought of as "soft parsing problems."

Given some text, we want to extract all the street addresses,
or standard names, or all the clauses from a document, or
any other data type that almost (but not quite) fits
a well-defined pattern. Often the entire business rests
on the fact that this data is distributed, not standardized,
or hard to find all in one place.

In these cases, the ideal approach would be one that
strikes a balance between software 1.0 (conventional
programming) and software 2.0 (data science and AI),
since the problems are often not complex enough to
warrant training an entire model or messing around
with API keys, but not simple enough to be solved
without something resembling "software 2.0".

The "many weak regexes" method described below is a
rough draft attempt to strike this sort of middle
ground in a practical problem. Since we're at work,
the example below isn't designed for purity or for
minimalism, and it will inevitably be mixed with some
distracting digressions and irrelevant details since
we also need to solve a specific problem here at work.

In what follows, we'll focus on extracting standard names,
but try to keep the discussion abstract enough to show
the general idea, so other folks can hopefully get the
gist and see if it proves useful on other problems.

To use this idea on your own problems, follow these steps:

---

First, build a stereotype of what you're looking for.

The goal here is not to represent all the variations
of every instance you'll encounter in reality, nor
to represent only the features that are common to
all those instances.

Just build a stereotype. Unapologetically. It must
be oversimplified. That's the point. We'll use it
in step two, to capture that messy reality.

The stereotypical example of a simple standard name
looks something like this:

    ISO 123-45-1:2014

The reality, of course, is more annoying and complex.

For example, sometimes several standards bodies collaborate
to write these things. The stereotypical "multiple-standards-body"
standard name looks something like this:

    AAA/BBB/CCC 12345-1:2017

Also, due to the imperfections of OCR in turning pdfs
into text, real world examples of what a standard name
looks like in the data sets we'll be working with will
often contain spaces or dashes inserted at semi-random
positions, plus occasional misspellings and chaos, so
they often look like this.

    AAA /BBB / CCC   12345 -1 :,2017)

Finally, standard names occur in the broader context of
a document or chunk of text, and we need to extract them
from those documents and ignore everything else.

The sort of sentence, or line, or small chunk of text
in which a standard name occurs in this dataset tends to
look like this:

    In accordance with the rules and such as outlined
    in AAA/BBB / CCC /DDD  60601-2 -1 :2024 and then
    also in EEE / FFF / GGG /HHH 12345 -22-11:2023 and
    in LCA 90210:2022 but not Los Angeles CA 90210 cuz
    that's not a standard it's a place, and let's also
    toss some numbers like 2024 and 12345 around too
    plus some p-,un--ctuat:ion and n o i s e that you'll
    need to ignore, now figure out how to parse this and
    just extract the standard names haha ok bye.

In other words, in reality standard names come in bursts, often several
per line or sentence; are written in a semi-standard (but not
actually standard) format; are interspersed with street
addresses and other text, parts of which almost certainly
match the same patterns as certain standard names; are
mixed with an unpredictable number and kind of OCR artifacts
too numerous to be worth attempting to categorize; and are
nevertheless very easy to recognize by a human brain, and
therefore must, in some sense, be a "well defined" thing.

That's reality. It's complex. So step one is to ignore that.

In step one, we just make a stereotype. Like

    ISO 123-45-1:2014

Ignore the rest.

Now, in step two, write down descriptions of the *parts*
that make up the whole stereotype we just wrote down. In our case,
our stereotype is a string, and the "parts" are character classes
that can be defined by simple regexes.

The key idea of how we'll detect messy and imperfect
instances will not be only to look for these "parts",
but for *co-occurence* of the parts, each co-occurrence
giving a small independent contribution to our
recognition of the whole, and doing so in a way where
the presence of noise (e.g., some random "noise" characters
between two parts that we expected to be adjacent) should
diminish but not totally disrupt our ability to detect
the whole.

This is all getting a bit abstract.

Time for some code.

The rest of the file is a rough draft POC of the ideas above.

Feel free to change it.

It's almost certainly more complex than it needs to be.

The basic idea is simple:

> As data becomes less structured,
> many weak cues beat any strong one.
