# Writing a skill's docs page

Every skill has a human-facing docs page at `docs/skills/<name>.md`. The page is not the skill and not a copy of `SKILL.md`: `SKILL.md` is the agent's runbook; the docs page orients a human deciding whether and when to reach for the skill.

## Template

Fill every section; none are optional for this repo's six skills (unlike mattpocock/skills, this suite is small enough that every skill earns the full page).

```markdown
## What it does

One or two paragraphs. Lead with the one-sentence job, then state the defining
constraint: the fact that makes this skill behave differently from the obvious
default (for `verifying-findings`: it does not accept a lead as a finding until
a disproof attempt has failed).

## When to reach for it

- Invocation mode: user-invoked ("you type /name, the agent never reaches for
  it on its own") or model-invoked ("type /name, or the agent reaches for it
  automatically when a task fits").
- Trigger boundary: the situations that belong here versus a sibling skill,
  as a short table when there is a real branch to show.

## Prerequisites

Only if the skill needs something in place first (a workspace it writes into,
a prior skill's output). Omit the heading otherwise.

## <free-form middle, 1-3 sections>

Whatever headings make this skill's own mechanism click: its gates, its
dispositions, its loop. Surface the skill's leading word.

## It's working if

A few checkable bullets: signals the reader can see in their own run without
opening SKILL.md.

## Where it fits

One or two sentences: this skill's role in the pipeline, and its one or two
neighbors, each with a because-clause.
```

## Rules

- No install commands on a docs page; those live only in the README, copied from `.agents/install-block.md`.
- No em-dashes (see `AGENTS.md`).
- Every link is relative within this repo (this suite has no hosted docs site, unlike mattpocock/skills' aihero.dev pages).
- Re-sync the page in the same change that alters the skill's behavior, gates, or dispositions.
