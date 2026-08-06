---
name: add-mystery
description: Write and publish a new mystery case for The Young Detectives Club. Use when asked to add a mystery, write a new case, add a puzzle, or "one more for the kids". Takes an optional difficulty (1-3) and an optional premise.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(hugo *), Bash(./scripts/check-case.sh *), Bash(bats *), Bash(git *), Bash(git -C *), Bash(agentic-commit *), AskUserQuestion
user-invocable: true
---

# Add a Mystery

## Arguments

`$ARGUMENTS` — optional, free text. It may carry a difficulty, a premise, or both:

- `/add-mystery` — difficulty 1, premise is yours to invent
- `/add-mystery difficulty 2` — harder, premise is yours to invent
- `/add-mystery a missing library book, difficulty 2`
- `/add-mystery something with a dog in it`

**Difficulty defaults to 1** — one magnifying glass out of three, the easy end —
whenever the user doesn't name one. Do not quietly aim higher because the case
feels thin to you; a case a child solves unaided is the point.

## Before anything else

Read `AGENTS.md`. The house rules table is the contract, and Gio raises those
limits over time — the file is the source of truth, not this skill's summary.
As of writing: **exactly 3 suspects, exactly 5 clues, at most 3 advanced words,
one emoji per suspect, and vocabulary a seven-year-old reads without stopping.**

Skim `content/mysteries/who-ate-the-cake.md` for the shape.
Ignore `the-lighthouse-at-gull-point.md` — it predates the rules and breaks them.

## Step 1 — Settle the premise

If the user gave one, use it. If not, invent one and say what you picked in a
sentence; don't interrogate them for a theme.

Something is taken, eaten, broken, or moved. A death is allowed — the lighthouse
case is a murder — but a theft carries the same logic and suits the age better.
Keep the world small and concrete: a school, a fete, a farm, a swimming pool, a
campsite. Three people who were nearby, all with a reason to be.

## Step 2 — Build the shape

Every case is the same skeleton, and the skeleton is not where you innovate:

1. **Two suspects are cleared** by a clue a child can check without being told.
2. **The third is caught contradicting their own statement**, with one physical
   clue to confirm it.

Nothing else. No second inference stacked on the elimination, no clue that only
pays off once you already know the answer.

What difficulty changes is how hard the checking is — never the counts:

| Difficulty | The reader has to |
| --- | --- |
| 1 (default) | Match each clue to a suspect. No arithmetic, no clock. |
| 2 | Do one small check — a gap between two times, a count that doesn't add up. |
| 3 | Notice two clues contradict each other before elimination narrows it. |

## Step 3 — Break your own case before you write it

Most of the work is here. Every case that has been pulled from this site failed
one of these:

- **Establish when the crime started, not just when it was found.** An alibi that
  begins four minutes late leaves a gap nobody examined.
- **Walk each alibi against the clock.** Every suspect, every minute of the
  window. If a suspect is free for longer than the crime takes, they aren't
  cleared.
- **No circular alibis.** If A vouches for B and B vouches for A, neither is
  cleared. Bring in a third witness.
- **Every clue must survive "but why would anyone do that?"** A door that bolts
  from the outside needs someone to have bolted it, and a reason. If you can't
  name one, the clue is broken — find a cause with no person behind it (weather,
  tide, a machine, a timestamp).
- **Nothing outside the page.** No knowledge a child hasn't been given in the
  case itself.

Also check the culprit has a reason. It can land in the solution as the last
line — it doesn't have to be a clue — but a thief with no motive reads as random.

## Step 4 — Pick the words

Simple vocabulary is the constraint that bites hardest. Short sentences,
everyday words, no clause stacking.

Then choose **at most three** words worth teaching and wrap each one:

```markdown
{{< word def="a reason why you could not have done it, because you were somewhere else at the time" >}}alibi{{< /word >}}
```

Good candidates are the detective's own vocabulary — *alibi*, *evidence*,
*culprit*, *witness*, *motive*. Definitions are for a seven-year-old: no commas
stacked three deep, no word in the definition harder than the word itself.

Any other word that would need explaining doesn't go in the case at all.

A word's element id is built from the word, so **don't define the same word
twice on one page**.

## Step 5 — Write the file

`content/mysteries/<kebab-case-title>.md`:

```markdown
---
title: Who Ate the Cake?
date: 2026-08-06          # today, local date
setting: Bramble Lane School
missing: One big slice of chocolate cake   # or `victim:` for a death — pick one
difficulty: 1
---

Scene-setting prose. Bold the times and facts that matter: **twelve o'clock**.

{{< suspects >}}

{{< suspect name="Bert Dunn" role="The Caretaker" emoji="🧹" >}}
"Their alibi, in their own words."
{{< /suspect >}}

{{< /suspects >}}

{{< clues >}}

1. Five of them, numbered, plainly worded.

{{< /clues >}}

{{< solution culprit="Coach Tibbs" >}}

Clear each innocent suspect first, one short paragraph each, then how the culprit
gave themselves away.

{{< /solution >}}
```

Notes that will bite otherwise:

- `date:` is today's **local** date. It shows as "Filed" and orders the home page.
- One emoji per suspect, matching their job, not their guilt. Don't hand the
  reader a 🔪 for the murderer.
- Shortcodes use `{{<`, never `{{%`.
- Put the answer only inside `solution`. Nothing earlier may name the culprit.

## Step 6 — Verify

Do all four. The first two are not optional.

```sh
./scripts/check-case.sh content/mysteries/<slug>.md   # house rules
hugo --gc --minify                                     # must be warning-free
```

Then confirm it actually rendered — a case can pass both checks and still be
missing from the site, because Hugo silently drops future-dated pages:

```sh
ls public/mysteries/<slug>/index.html
```

Finally, **re-read the case as the child**. Solve it from the clues alone,
without looking at the solution. If you can't, or if you can only by knowing the
answer already, the case isn't finished — go back to step 3.

If you changed `scripts/check-case.sh`, run `bats test/check-case.bats`.

## Step 7 — Commit

Use the `/commit` skill. One commit, titled `Add "<Title>"`.

Pushing to `main` deploys to <https://mokagio.github.io/kids-mysteries/>, so
don't push a case you haven't read back.

## When a case doesn't work

Never delete it. Set `draft: true` and write a comment above the key saying what
broke, the way the two shelved cases do. `hugo server -D` builds drafts.
