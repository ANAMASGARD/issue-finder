---
name: drafting-issues
description: Turn a confirmed, screened finding into a local draft issue, feature request, or private security advisory, ready for human review, following the target project's own conventions. Use when asked to draft, write up, or prepare an issue or report for a finding. Never publishes anything itself.
---

# Drafting Issues

A draft is for a human to read and decide whether to file, not something this skill files itself. Nothing in this skill ever opens a public issue, posts a comment, or creates a PR.

## Non-negotiables

1. **Only confirmed, screened findings get drafted.** A candidate must carry disposition `Confirmed and actionable` (or `Security-sensitive: private handling required`, routed to the private template) and have already been through `screening-duplicates`, before this skill touches it.
2. **The target project's own rules win.** Read its issue templates/forms, `CONTRIBUTING`, AI-contribution policy, `SECURITY.md`, and DCO/CLA requirements before drafting anything, and follow them. If the project bans AI-assisted reports outright, stop and tell the user; do not draft around the ban.
3. **No fix pitch in a bug report.** Describe the problem; a suggested fix, if any, is a separate, clearly labeled, optional note, never baked into the title or description as if it were the point.
4. **State what's unverified as unverified.** Never let a draft imply more certainty than `verifying-findings`'s record actually supports.
5. **Redact secrets.** Every piece of captured evidence quoted in a draft gets credentials/tokens/PII replaced with `<REDACTED>` first.
6. **Security-sensitive findings get the private template only, ever.** No public issue, no public PR, regardless of any authorization already granted for other findings.
7. **A draft isn't final until the fresh-eyes check passes.** See below.

## Preflight

Before drafting, in order:

1. Confirm the finding's disposition and screening status in its record; if either is missing, stop and route back to the right skill.
2. Read the target's issue templates/forms (`.github/ISSUE_TEMPLATE/`, `.gitlab/issue_templates/`, or equivalent), `CONTRIBUTING.md`/`CONTRIBUTING.rst`, any `AGENTS.md`/`CLAUDE.md` AI-contribution clause, `SECURITY.md`, and DCO/CLA requirements (a "Signed-off-by" requirement, a CLA bot). See [references/AI-DISCLOSURE-POLICIES.md](references/AI-DISCLOSURE-POLICIES.md) for concrete examples of how differently real projects treat this, and why checking the specific target matters more than assuming a convention.
3. If the project's policy bans AI-generated issue content outright, stop here, tell the user exactly which policy says so and where you found it, and still write the local draft (for the user's own use) but mark it clearly as **not filable as-is** under the project's stated policy.
4. If private vulnerability reporting is enabled (a "Report a vulnerability" button on the repo) or `SECURITY.md` names a contact, note that channel in the security advisory draft so the user knows where to send it.

## Content rules

- **Title**: under ~72 characters, names the component and the observable failure, no proposed fix, no inflated severity language. Good: "CronJob template omits `extraVolumes` mount present in Deployment template." Bad: "Fix critical volume bug."
- **Body sections** (adapt to the project's own template when one exists, but cover all of these somewhere): Description, Environment (OS/runtime, exact commit/tag/version, config, source vs. release build), Steps to reproduce (minimal, copyable, from a clean checkout, no credentials or machine-specific assumptions), Expected behavior (cite the contract), Actual behavior (exact output/exit code/logs, redacted), Cause (only the parts actually traced and verified), Impact and affected scope (only what was demonstrated).
- **Disclosure**: if the project's policy asks for AI-assistance disclosure (see AI-DISCLOSURE-POLICIES.md), include it plainly, don't bury it.
- Use the matching template: [references/BUG-REPORT.md](references/BUG-REPORT.md), [references/FEATURE-REQUEST.md](references/FEATURE-REQUEST.md) (for `Enhancement requiring maintainer discussion` findings), or [references/SECURITY-ADVISORY.md](references/SECURITY-ADVISORY.md) (private only, for `Security-sensitive` findings).

## Fresh-eyes check

Before a draft is considered final, someone or something with no prior context must reproduce the bug from the draft's own steps alone:

- A fresh subagent that has not seen the investigation, given only the draft text, attempts the repro and reports whether it reproduced.
- Or, a rerun of the exact documented steps in a clean container/checkout, by the same agent, treating the draft text as the only source of truth (not the investigation notes).

If the fresh-eyes attempt fails to reproduce, the draft's steps are incomplete or wrong; fix the steps (not the investigation record) and re-run the check. A draft that hasn't passed this check is not final, no matter how confident the underlying `verifying-findings` record is; a confirmed bug with bad repro steps in the draft helps nobody.

## Output

Write the draft to `.issue-finder/drafts/IF-###-<slug>.md` (or `.issue-finder/private/IF-###-<slug>.md` for security advisories, mode 0600). Update the candidate's status to `drafted` in `.issue-finder/candidates.md`.

## Publishing is separate

This skill never files anything. Opening the actual public issue, PR, or sending the private security report is a distinct action that needs its own explicit authorization in `ENGAGEMENT.md`, granted individually, after the user has reviewed the draft.
