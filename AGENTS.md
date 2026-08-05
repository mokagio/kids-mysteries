A static site generated with Hugo to collect simple mysteries for budding detectives.

## Commands

```sh
hugo server              # dev server on http://localhost:1313, live reload
hugo server -D           # ...including shelved cases (draft: true)
hugo --gc --minify       # production build into public/
```

No npm, no theme, no dependencies — everything is in `layouts/` and `assets/`.

## Adding a mystery

One file per case: `content/mysteries/<slug>.md`.

```markdown
---
title: The Lighthouse at Gull Point
date: 2026-08-05
setting: A lighthouse on a tidal rock
victim: Captain Sloat    # or `missing:` for a theft — the header labels itself
difficulty: 2            # 1–3, rendered as magnifying glasses
---

Scene-setting prose. Wrap the key fact in **bold** to highlight it.

{{< suspects >}}

{{< suspect name="Silas Crumb" role="The Postman" >}}
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
Suspect numbering comes from `.Ordinal`, so cards number themselves in source order.

Set `draft: true` to shelve a case that isn't working, rather than deleting it,
and say why in a comment above the key.

## Writing a case that holds up

Aim between "solvable at a glance" and "needs a second inference on top of the
elimination" — every suspect but one is cleared by a clue a child can check,
and the culprit is caught by contradicting themselves.

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

## Design

The look is Murdle-inspired: cream paper, charcoal borders, hard offset shadows,
heavy uppercase display type, monospace for clues so they read as evidence.
All of it lives in `assets/css/main.css` behind custom properties at the top —
change the palette there, not in the rules.

There is no dark mode, deliberately: the site should read like a printed case file
on any device.

Fonts are system stacks on purpose: the site makes no network requests at build or
runtime, so it works offline and on a plane.
