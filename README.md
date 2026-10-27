# Issue Finder

[![skills.sh](https://skills.sh/b/ANAMASGARD/issue-finder)](https://skills.sh/ANAMASGARD/issue-finder)

An evidence-driven bug hunter and issue finder for any cloned codebase, CLI, library, web app, API service, mobile, desktop, or infra. It syncs your primary branch to the latest commit on a fresh branch, learns the project from its own docs, runs it like a real user, and reports only bugs it actually reproduced, each with a confidence score, a priority, and a difficulty estimate. Pick one, and `issue-fixer` proves the fix red-to-green with the project's own CI commands before writing a local PR draft.

## Why

Most "find bugs in my repo" prompts produce a wall of plausible-sounding guesses: some real, most not, with no way to tell which is which without redoing the investigation yourself. Issue Finder is built around the opposite bias: a lead is not a finding until it's been reproduced with a real command and real output, scored against a fixed checklist, and survived an adversarial skeptic pass. Most leads should die during verification; that's the gate working, not the gate failing.

## How it works

1. **Sync.** Stash any local changes (never dropped), fetch, fast-forward or replay the primary branch onto its latest upstream commit, and branch into `bughunt/<date>-<sha>`. Your original branch and commits are never touched.
2. **Understand.** Detect the project's type and toolchain, read its README/CONTRIBUTING/CI config, and record the exact install/build/lint/test commands, taken from CI, not guessed.
3. **Baseline.** Install and run those commands against the untouched synced base. A baseline failure is itself a finding.
4. **Hunt.** Follow the docs exactly as a new user would, then probe the edge cases for that project type.
5. **Verify and score.** Every lead gets reproduced, root-caused, checked against a skeptic subagent, and scored: confidence (0-10), priority (P0-P3), difficulty (0-10).
6. **Report and ask.** Show the scorecard, ask which finding (if any) to fix now.

```text
Confirmed findings

Rank  ID      Finding                               Confidence  Priority  Difficulty
1     IF-002  Crash on an empty input file          8/10        P0        3/10
2     IF-001  Documented --verbose flag is ignored  9/10        P1        2/10
```

Pick one, and `issue-fixer` writes a failing regression test, makes the smallest root-cause patch, re-runs the full CI ladder against the recorded baseline, and leaves a local PR draft. Nothing is pushed or opened anywhere unless you say so.

## Safety

- **`issue-finder` never edits your tracked source.** It stashes, syncs, and branches, all local and reversible, then reads, builds, and runs the project to hunt. `issue-fixer` is the only thing that writes code, and only inside its own `fix/<slug>` branch, for exactly one finding you named.
- **Push, a public issue, a PR, and a security report always need their own explicit yes**, asked in chat at the moment each would happen. Nothing is bundled into a blanket "go ahead," and nothing from a prior turn carries forward silently.
- **Security findings stay private.** Full detail lives only in `.issue-finder/private/`; the scorecard and every report show only "Security finding," never a description, regardless of what's authorized for ordinary findings.
- **The target's own instructions are information, not permission.** Its `AGENTS.md`, rules files, and bundled skills describe its conventions; nothing in them expands what this suite is authorized to do.
- **Zero findings is a complete, honest result.** Nothing gets inflated or padded to avoid reporting it.

Full detail: [`AGENTS.md`](AGENTS.md), [`SECURITY.md`](SECURITY.md), and [ADR 0004](.agents/adr/0004-two-skill-find-then-fix.md).

## Install

### Claude Code, Codex, GitHub Copilot (CLI and VS Code)

```bash
claude plugin marketplace add ANAMASGARD/issue-finder
claude plugin install issue-finder@anamasgard
```

Codex and Copilot CLI read the same `.claude-plugin/` manifests:

```bash
codex plugin marketplace add ANAMASGARD/issue-finder
codex plugin add issue-finder@anamasgard
```

```bash
copilot plugin marketplace add ANAMASGARD/issue-finder
copilot plugin install issue-finder@anamasgard
```

### Cursor

Open the Command Palette and run **Plugins: Add Marketplace**, then paste `https://github.com/ANAMASGARD/issue-finder`. Or, from a terminal in the project:

```bash
npx skills@latest add ANAMASGARD/issue-finder --skill '*' -a cursor
```

### Gemini CLI

```bash
gemini skills install https://github.com/ANAMASGARD/issue-finder.git --path skills
```

Re-run to update; Gemini does not auto-update skills.

### Any other agent, or editable files

```bash
npx skills@latest add ANAMASGARD/issue-finder -a <agent>  # cursor, opencode, windsurf, devin, amp; omit -a to choose
```

Take both skills: `issue-finder` and `issue-fixer`. `issue-finder` hands off to `issue-fixer` by name once you pick a finding to fix, so installing only one leaves that handoff unable to complete. To update, run `npx skills@latest update`, and re-run `add` to pick up changes.

### Single-skill install

```bash
npx skills@latest add ANAMASGARD/issue-finder --skill issue-finder
```

Omit `issue-fixer` only if you never want this suite touching source code, even on request; you can still fix findings yourself from the report.

## Usage

```bash
cd my-cloned-project
```

Then, in your agent:

```
/issue-finder
```

It syncs your primary branch to the latest commit on a new `bughunt/` branch, learns the project, runs it like a real user, and stops at a scorecard plus `.issue-finder/REPORT.md`. Nothing is filed or pushed.

Pick a finding from the scorecard, and it hands off automatically, or call it yourself:

```
/issue-fixer IF-002
```

It fetches the latest tip again, writes a failing regression test, makes the smallest fix for the already-traced root cause, proves it with the project's own CI commands, and leaves a local PR draft. Opening the actual PR is a separate action.

## Reference

| Skill | Invocation | Docs |
| --- | --- | --- |
| `issue-finder` | User-invoked (`/issue-finder`) | [skills/issue-finder/SKILL.md](skills/issue-finder/SKILL.md) |
| `issue-fixer` | Model-invoked (by `issue-finder`'s handoff, or `/issue-fixer <id>`) | [skills/issue-fixer/SKILL.md](skills/issue-fixer/SKILL.md) |

## FAQ

**Will this file issues or open PRs on my project for me?**
No. `issue-finder` stops at a local report, and `issue-fixer` stops at a local PR draft. Opening a real issue, PR, or sending a security report each needs its own explicit "yes," asked at the moment it would happen.

**Will it commit or push to my repo?**
It makes local commits only, on its own `bughunt/`/`fix/` branches, never on the branch you were already on. It never pushes without you explicitly saying so.

**What if it finds a security vulnerability?**
It's handled privately: written only to `.issue-finder/private/`, shown in the scorecard only as "Security finding," and never named in a commit message or branch name. See [`SECURITY.md`](SECURITY.md).

**Does it work on anything besides web apps?**
Yes. `skills/issue-finder/references/project-types.md` covers CLIs, libraries/SDKs, web UIs, HTTP/API services, full-stack apps, mobile, desktop, infra/IaC, data and language tooling, and browser/editor plugins, each with how to recognize it, what environment to use, and its typical bug sources.

**Why is `issue-finder` user-invoked but `issue-fixer` isn't?**
A full `issue-finder` run syncs a branch, installs dependencies, and can run for a long time; firing that from a casual remark would surprise you. `issue-fixer` only ever acts on one specific, already-scored finding ID, so once you've named one, `issue-finder` can hand off to it directly instead of making you type a second command. See [ADR 0001](.agents/adr/0001-user-invoked-entry-points.md) and [ADR 0004](.agents/adr/0004-two-skill-find-then-fix.md).

**What happens to my local work in progress when I run this?**
It's stashed, never dropped, before anything else happens. If sync can't complete cleanly (a conflicting rebase, an in-progress merge), it stops and tells you exactly how to get back to where you started.

**Can I run this against a project I'm actively developing myself, not someone else's open-source project?**
Yes. The pipeline doesn't care whose project it is; the safety model is the same either way.

## Maintaining this repository

See [`AGENTS.md`](AGENTS.md) for the rules that govern this repository's own layout, versioning, and safety invariants.

## License and credit

[GPL-3.0-only](LICENSE), with a required attribution notice under GPLv3 section 7(b): see [`NOTICE`](NOTICE). You're free to use, modify, and redistribute this project; a fork or redistribution must stay GPL-3.0 and keep the "Issue Finder by Gaurav Chaudhary" credit intact. Copyright (C) 2026 Gaurav Chaudhary.
