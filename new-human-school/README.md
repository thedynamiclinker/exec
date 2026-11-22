# Heisig primitives for New Human School

This is a machine-readable catalogue of the meaning-bearing pieces used to build an East writing curriculum: ordinary character components, Heisig's explicitly assigned mnemonic components, their positional drawings, and the traditional radical-family baseline requested by Jason.

## Open these files

- **heisig-primitives-atlas.html** — searchable offline visual atlas. The special shapes are embedded SVGs. Open a card to see source references, RTH checks and any documented smaller parts.
- **heisig-primitives.md** — complete ordered Markdown tables for Obsidian.
- **heisig-primitives-fenced.md** — the same tables inside a Markdown code fence for copying.
- **heisig-primitives.json** — full machine-readable catalogue, with provenance and separate meaning fields.
- **heisig-primitives.tsv** — compact tab-separated interchange table.
- **glyphs/** — exact supplemental drawings and three independently drawn arrangement diagrams.
- **rth-primitive-checks.json** — targeted RTH1/RTH2 checks, with page references.
- **traditional-form-review.json** — a separate review of old and alternate forms in RTK3.
- **evidence/** — factual source transcriptions and audit decisions, including all the author-index entries and the ordinary-character review.

## What “complete” means here

The catalogue contains 441 entries: 411 Heisig or explicitly requested foundation entries and 30 traditional forms for which this audit did not establish a matching Heisig semantic introduction. It covers all 214 traditional radical families, all 234 drawings in the pinned supplemental shape dataset, and all 374 entries in the cumulative primitive-meaning index that was checked. Those 374 entries include synonyms and inverted alphabetical cross-references; they normalize to 302 editorial label groups.

These counts measure different things. They are not additive, and 441 is not a claim that Heisig has 441 irreducible roots.

The author also allows any learned kanji to serve as a primitive when it is reused intact. That recursive category is open-ended: it includes larger words assembled from earlier components. The present catalogue targets the requested foundation inventory, not every whole kanji that could ever be reused. It deliberately does not treat every empty decomposition field in a community CSV as an atomic shape.

## Editions and order

The detailed author-text checks use RTK1 fifth edition (2007) and RTK3 second edition (2008). The main sequence is crosswalked to the RTK1 sixth-edition / revised RTK3 numbering used in the existing NHS data. The sixth-edition supplemental drawings are included as well.

`approx_rtk6_order` is a placement aid. It can indicate a numbered character, the nearest frame before or after a special component, or an earlier occurrence of a shape moved into revised RTK1. It is not an invented frame number for an unnumbered radical. The exact old-edition page, the printed index reference and corrections to that reference are retained separately. A null order means this audit did not establish an RTK placement.

## Meanings are separate from memory labels

`heisig_labels` contains component images. `whole_character_keywords` contains numbered character keywords. `rth_checks` distinguishes community character-keyword matches from directly checked primitive uses. `traditional_radicals` contains Unicode's conventional radical-family names. These fields must not be collapsed into a claim about historical etymology.

Examples:

- 艮 is assigned the image **silver** in both RTK and RTH. That does not make “silver” its ordinary independent character meaning.
- 月 may carry the **moon** image or a **flesh/body** image; those are distinct semantic roles even when their printed forms coincide.
- 王 and 玉 share the mnemonic **ball**, while their whole-character keywords remain **king** and **jewel**.
- 甲 is **roots**, while 由 is **shoot/sprout** in the component vocabulary.
- 午 has the early **horse** image; 馬 is the later **team of horses** image.
- 之 is **building blocks**. 卆 is **game of cricket**. Neither label should be assigned to a vaguely similar larger character.

One index label, **silverware**, has only an inferred association with 艮. It is retained in `tentative_roles`, not treated as an independently verified quiz answer.

## A foundation that can be constructed

The teaching policy is to introduce a new association only when needed, then show what it makes possible. Do not turn every row of this catalogue into an unexplained kindergarten flashcard.

The ordinary-character audit directly checked 59 whole-shape teaching units, plus six pictographs for which smaller constructions are available, 五 as a numeral seed, and the user-requested 言 component. That is a practical review set, not a mathematical proof that these are the only possible base units.

The catalogue records smaller parts for 40 entries. For example, 莫 “graveyard” has flowers + sun + large dog; 粦 “shoeshine” has rice + sunglasses; 豈 “hill of beans” has mountain + beans. These can be taught as named constructions. `learning_status` distinguishes such records from reviewed whole-shape units and from components whose atomicity was not audited. An absent decomposition is an unknown, not proof of indivisibility.

## Shapes and Unicode

All 234 upstream drawings are retained. Source code points are preserved, with common display equivalents used in the Markdown table where appropriate. Similar-looking shapes are not silently identified across different roles: the left and right 阝 components remain separate.

Fifty-four catalogue entries have no asserted ordinary Unicode glyph after arrangement descriptions are separated out. Their SVGs or descriptive references carry the shape. An IDS string such as ⿱十目 describes an arrangement; it should never be shown to a learner as though it were a single character. The atlas draws that component instead.

The two separated-pair strokes of “I Ching,” the “eye of a needle” arrangement and “arrowhead” use original schematic SVG diagrams. They are not crops of a book page.

## RTH backup checks

There are 26 directly checked RTH primitive/variant groups and 206 catalogue entries with a matching RTH character keyword in the community transcription. These are different levels of evidence. A matching ordinary character keyword does not verify an unrelated mnemonic role.

The full RTH character crosswalk has 3,035 community-reported numbered entries. Three early frame numbers disagree with the primary RTH1 text that was checked; those corrections are recorded separately. No claim is made that every RTH frame number or every primitive label was independently verified.

## Source rights and reuse

No Heisig story prose, book PDFs or page images are included. This package contains factual mappings, original audit notes, and the supplemental glyph drawings from the pinned cyphar repository. The repository's CC0 statement covers its author's contributions to those drawings; it does not grant a blanket licence to the Heisig books or other people's stories. The source URLs, editions and repository commits are in sources.json.

The catalogue is suitable for local NHS development and further review. Keep provenance and verification fields when importing it into the quiz app, and keep any NHS-specific child-facing alias separate from the original Heisig label.
