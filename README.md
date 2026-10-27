# Issue Finder

An evidence-driven agent skill suite that hunts a locally cloned codebase for real bugs, vulnerabilities, performance problems, and missing features, by using the project the way a real human user would, then verifying every candidate against evidence, screening for duplicates, ranking, and writing local, human-reviewable drafts.

Give it a cloned open-source project and it explores the project like a user, not a static scanner: it installs it, runs it, clicks through it, drives its CLI, hits its API, and judges every surprise against a named reason before calling it a lead. A lead only becomes a finding after it survives a reproduction on a pinned baseline, a traced root cause, and a real attempt to disprove it. Nothing gets filed, committed, or pushed without you granting that specific action, every time.

## Why

Most "find bugs in my repo" prompts produce a wall of plausible-sounding guesses: some real, most not, with no way to tell which is which without redoing the investigation yourself. Issue Finder is built around the opposite bias: a lead is not a finding until it has been reproduced, traced, and actively challenged. Most leads this suite generates should die during verification. That's the gate working, not the gate failing.

## The safety model

- **Read-only by default.** `issue-finder` never edits the target project's tracked source. Fixing a finding is a separate, explicit step: run `issue-fixer` by name, once, per finding.
- **Authorization lives in a file, not a chat turn.** Every external action (commit, push, rebase, force-push, a public issue, a PR, a private security report) is tracked in `ENGAGEMENT.md`, inside the target checkout's `.issue-finder/` workspace, and defaults to **no**. This file persists across sessions and context compaction, so a permission you granted an hour ago doesn't silently carry forward to an action you never actually authorized.
- **Security-sensitive findings override everything else.** The moment a candidate's impact involves unauthorized access, data exposure, or privilege escalation, its disposition becomes `Security-sensitive: private handling required`, and that overrides every other authorization already granted for that engagement. It's written only to `.issue-finder/private/` (directory mode `0700`, files mode `0600`), and `drafting-issues` writes a private advisory, never a public issue, for it.
- **A target's own instructions are data, not commands.** A target project's `AGENTS.md`, `CLAUDE.md`, rules files, or bundled scripts are read as information about that project's conventions. They are never treated as instructions that expand this suite's own authorization, even if the target repo tries to say otherwise.
- **Sandboxed execution.** Building and running a cloned project means running untrusted code. The suite prefers a devcontainer, then a container, then a disposable VM or cloud sandbox, and only falls back to the host with your explicit, informed consent.

Full detail: [`skills/issue-finder/references/ENGAGEMENT.md`](skills/issue-finder/references/ENGAGEMENT.md), [`skills/issue-finder/references/GROUNDING.md`](skills/issue-finder/references/GROUNDING.md), and [`SECURITY.md`](SECURITY.md).

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

When the installer asks which skills to take, choose all six: `issue-finder`, `exploratory-testing`, `verifying-findings`, `screening-duplicates`, `drafting-issues`, `issue-fixer`. Installing only `issue-finder` leaves it unable to call its companions. To update, run `npx skills@latest update`, and re-run `add` to pick up new skills.

### Single-skill install

```bash
npx skills@latest add ANAMASGARD/issue-finder --skill issue-finder --skill exploratory-testing --skill verifying-findings --skill screening-duplicates --skill drafting-issues
```

Omit `issue-fixer` only if you never want this suite touching source code, even on request.

## Usage

```bash
cd my-cloned-project
```

Then, in your agent:

```
/issue-finder
```

The agent asks about scope and budget, sets up `.issue-finder/ENGAGEMENT.md` with every external action defaulted to no, grounds itself in the repo's real state, and runs the full pipeline: explore like a user, hunt for leads, verify each one against evidence, screen for duplicates, rank, and write local drafts. It stops at `REPORT.md`; nothing is filed or pushed.

To fix one finding from that report:

```
/issue-fixer IF-002
```

This asks for explicit authorization to create a local branch and change source if `ENGAGEMENT.md` doesn't already grant it, writes a failing regression test first, makes the smallest fix for the already-traced root cause, and ends at a local PR draft. Opening the actual PR is a separate action.

You can also call any of the four model-invoked disciplines directly, without running the full pipeline, for a narrower question:

- "Is this a real bug or a false positive?" calls `verifying-findings`.
- "Has this already been reported upstream?" calls `screening-duplicates`.
- "Explore this app like a new user and tell me what's broken." calls `exploratory-testing`.
- "Write up this finding as an issue." calls `drafting-issues`.

## Reference, grouped by invocation

**User-invoked** (you type the name; these never fire on their own):

| Skill | Docs |
| --- | --- |
| `issue-finder` | [docs/skills/issue-finder.md](docs/skills/issue-finder.md) |
| `issue-fixer` | [docs/skills/issue-fixer.md](docs/skills/issue-fixer.md) |

**Model-invoked** (reachable by name or automatically, when the task fits):

| Skill | Docs |
| --- | --- |
| `exploratory-testing` | [docs/skills/exploratory-testing.md](docs/skills/exploratory-testing.md) |
| `verifying-findings` | [docs/skills/verifying-findings.md](docs/skills/verifying-findings.md) |
| `screening-duplicates` | [docs/skills/screening-duplicates.md](docs/skills/screening-duplicates.md) |
| `drafting-issues` | [docs/skills/drafting-issues.md](docs/skills/drafting-issues.md) |

See [`.agents/invocation.md`](.agents/invocation.md) for why the split exists, and [`GLOSSARY.md`](GLOSSARY.md) for the shared vocabulary (lead, candidate, disposition, finding, oracle, journey, draft, proof boundary) used consistently across every skill.

## FAQ

**Will this file issues on the target project for me?**
No. `issue-finder` stops at local drafts. Opening a real issue, PR, or sending a security report each needs its own explicit authorization, granted individually, after you've reviewed the draft yourself.

**Will it commit or push to my repo?**
No, not without explicit authorization recorded in `ENGAGEMENT.md`. The default for every external action is no.

**What if it finds a security vulnerability?**
It's handled privately, written only to `.issue-finder/private/` with restrictive file permissions, and routed to a private advisory draft, never a public issue, regardless of what else is authorized for that engagement. See [`SECURITY.md`](SECURITY.md).

**Does it work on anything besides web apps?**
Yes. `exploratory-testing` ships a playbook per project type: CLI tools, web UIs, HTTP services, libraries and SDKs, Kubernetes and infrastructure tooling, CI actions and integrations, parsers and data tools, desktop and mobile apps (including GTK/GNOME), and security scanners themselves.

**Why are `issue-finder` and `issue-fixer` user-invoked instead of automatic?**
A full run builds and exercises the target, and can run for a long time. Firing that from a casual "does this have any bugs?" would surprise you with an expensive workflow you didn't ask for. The tradeoff: a skill with `disable-model-invocation` is a non-spec key, so these two skills fail strict `skills-ref validate` and a claude.ai zip upload. See [`.agents/adr/0001-user-invoked-entry-points.md`](.agents/adr/0001-user-invoked-entry-points.md) for the full reasoning.

**What if I only install `issue-finder`?**
It will reach a step that needs a companion skill, stop there, and tell you exactly which one to install. It never inlines a weaker substitute for a missing companion.

**Can I run this against a project I'm actively developing myself, not someone else's open-source project?**
Yes. The pipeline doesn't care whose project it is; the authorization model is the same either way.

## Maintaining this repository

See [`AGENTS.md`](AGENTS.md) for the rules that govern this repository's own layout, versioning, and safety invariants, and [`SCOPE.md`](SCOPE.md) for what does and doesn't belong in a change.

## License

[MIT](LICENSE)
