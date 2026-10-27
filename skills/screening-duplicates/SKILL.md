---
name: screening-duplicates
description: Check whether a confirmed finding has already been reported, fixed, or discussed, across issues, PRs, commits, discussions, and advisories, before it gets drafted or published. Use when asked whether a bug has already been reported, or to dedupe a finding before filing it.
---

# Screening Duplicates

A real bug reported twice wastes a maintainer's time and damages the credibility of every other finding in the same report. Screen every confirmed candidate before it moves to drafting, and screen it again immediately before anything is actually published.

## Non-negotiables

1. **Read bodies, not just titles.** A title match or near-miss isn't enough to call something a duplicate, and a title mismatch isn't enough to clear it either; read the actual content of every plausible hit.
2. **Record every query you ran**, even the ones that returned nothing. An empty result is only meaningful if you can show what you searched for.
3. **Re-run the screen right before publishing**, not just once earlier in the engagement. Time passes between verification and drafting; someone else may have filed the same thing in between.
4. **A near-duplicate gets linked, not silently dropped or silently duplicated.** If you find a related-but-not-identical report, say so explicitly and let `drafting-issues` decide how to reference it.

## Procedure

### 1. Build a query set

For each candidate, construct multiple queries, not one:

- The symptom in plain language, as a user would describe it.
- The exact error text or message, verbatim, in quotes.
- Component name and any specific configuration keys involved.
- Code symbols: function/class/variable names from the root cause.
- The underlying mechanism, described abstractly (e.g., "race condition", "off by one", "volume not mounted").
- A broader query (drop a specific term) and a narrower query (add a specific version/config) than the main one, to catch both over- and under-specific prior reports.

### 2. Run the query set across every relevant source

See [references/FORGES.md](references/FORGES.md) for exact commands per forge. At minimum, cover:

- Issues and PRs, in every state (open, closed, merged), not just open ones. A closed-and-fixed issue is still a duplicate, just one with a different disposition consequence (`Already fixed upstream`).
- Discussions/forums if the project uses them.
- Commit history: `git log --grep`, `-S`, `-G` for the exact symbols or literal strings from the root cause.
- Changelogs and release notes for a line mentioning the same fix.
- Security advisories (GitHub Security Advisories, OSV) if the candidate is security-sensitive.

### 3. Read results, record the verdict

For every result that's even plausibly related, read its body (and enough of its thread/comments to see its resolution), not just its title. Record, per candidate:

- Every query run, verbatim.
- Every plausible hit found, with its verdict: duplicate / near-duplicate (related, not identical) / unrelated / already fixed.
- The final screening verdict for the candidate.

### 4. Return a verdict

- **No duplicate found** → candidate proceeds to drafting as planned.
- **Duplicate found, open** → disposition becomes `Confirmed but already reported`; link it, don't draft a new one.
- **Duplicate found, closed-fixed** → disposition becomes `Already fixed upstream`; re-run the gate-3 reproduction from `verifying-findings` against current upstream to confirm before finalizing.
- **Near-duplicate, not identical** → proceeds to drafting, but the draft must reference the related report explicitly.

### 5. Re-screen before publishing

Immediately before any draft is actually published (a separate, explicitly authorized step), re-run the exact same query set. Time has passed; don't skip this because the first screen already happened.

## Output

Update the candidate's record with the screening section filled in (queries, hits, verdict), and update its status in `.issue-finder/candidates.md` to `screened`.
