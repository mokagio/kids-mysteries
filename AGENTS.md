A static site generated with Hugo to collect simple mysteries for budding detectives.

## Commands

```sh
hugo server              # dev server on http://localhost:1313, live reload
hugo server -D           # ...including shelved cases (draft: true)
hugo --gc --minify       # production build into public/
```

No npm, no theme, no dependencies — everything is in `layouts/` and `assets/`.

Pushing to `main` deploys to <https://mokagio.github.io/kids-mysteries/> via
`.github/workflows/deploy.yml`.
The site is served from a subpath, so link to the home page with
`site.Home.RelPermalink` — `"/" | relURL` renders as `/` and lands on the domain
root instead.

## House rules

These are tuned to the kids reading the site right now.
**Do not exceed them.** Gio raises them as the kids get better — until he does,
a case that breaks one of these is wrong, not ambitious.

| Rule | Value |
| --- | --- |
| Suspects | exactly 3 |
| Clues | exactly 5 |
| Advanced words | at most 3, each wrapped in `{{< word >}}` |
| Emoji | one per suspect |
| Everything else | words a seven-year-old reads without stopping |

Simple vocabulary is the constraint that bites hardest.
Short sentences, everyday words, no clause stacking.
If a word needs explaining it must be one of the three, or it doesn't go in.

A skill for generating new cases will come later; for now they're written by hand.

## Adding a mystery

One file per case: `content/mysteries/<slug>.md`.

```markdown
---
title: The Lighthouse at Gull Point
date: 2026-08-05         # shown as "Filed", and orders the home page
setting: A lighthouse on a tidal rock
victim: Captain Sloat    # or `missing:` for a theft — the header labels itself
difficulty: 2            # 1–3, rendered as magnifying glasses
---

Scene-setting prose. Wrap the key fact in **bold** to highlight it.
An {{< word def="what the hard word means, in plain language" >}}alibi{{< /word >}}
gets a dashed underline and a definition card on tap.

{{< suspects >}}

{{< suspect name="Silas Crumb" role="The Postman" emoji="📮" >}}
"Their alibi, in their own words."
{{< /suspect >}}

{{< /suspects >}}

{{< clues >}}

1. A numbered Markdown list. The numbering is re-derived by CSS.

{{< /clues >}}

{{< solution culprit="Dr. Ada Quill" >}}

Why each innocent suspect is cleared, then how the culprit gave themselves away.

{{< /solution >}}
```

Shortcode bodies use `{{<` (not `{{%`), so inner content is passed through `markdownify`
in the shortcode template rather than by the page renderer.
That is why `markup.goldmark.renderer.unsafe` is on: without it, a `{{< word >}}`
nested inside `clues` or `solution` comes out as escaped text.
Suspect numbering comes from `.Ordinal`, so cards number themselves in source order.

`{{< word >}}` builds its element id from the word itself, so don't define the same
word twice on one page.
It emits a single trimmed `printf` — a newline in that template lands as a space
before the next full stop.

Set `draft: true` to shelve a case that isn't working, rather than deleting it,
and say why in a comment above the key.

## Writing a case that holds up

Two suspects are cleared by a clue a child can check.
The third is caught contradicting their own statement, with one physical clue to
confirm it.
That's the whole shape — don't add a second inference on top of the elimination.

Test every alibi against the clock before publishing.
Establish when the crime *started* as well as when it was discovered, or a suspect
whose alibi begins a few minutes late is left with an unexamined gap.
And check that alibis aren't circular: if A vouches for B and B vouches for A,
neither is cleared — bring in a third witness.

## The solution reveal

`layouts/_shortcodes/solution.html` renders **nested `<details>`**: the outer one
reveals only the culprit's name so a reader can check their guess, the inner one
reveals the reasoning.
No JavaScript — keep it that way, and keep the solution collapsed by default.

The solution is present in the HTML, just hidden.
It hides spoilers from a reader, not from anyone who opens the page source.

## Definition cards

`{{< word >}}` renders a `<button popovertarget>` plus a `[popover]` card, so a tap
opens it, a tap anywhere else dismisses it, and Escape closes it — all native, no
JavaScript.

A popover lives in the top layer, so placing it against the word takes CSS anchor
positioning.
Where that is supported the card floats just above the word, flipping below it
when the word is near the top of the screen.
Where it isn't — Firefox, for now — the card falls back to a centred modal over a
shaded page.

Anchor names are per word, so `word.html` emits them as inline styles built from
the same `$id` it gives the popover.

## Design

The look is Murdle-inspired: cream paper, charcoal borders, hard offset shadows,
heavy uppercase display type, monospace for clues so they read as evidence.
All of it lives in `assets/css/main.css` behind custom properties at the top —
change the palette there, not in the rules.

There is no dark mode, deliberately: the site should read like a printed case file
on any device.

Fonts are system stacks on purpose: the site makes no network requests at build or
runtime, so it works offline and on a plane.
