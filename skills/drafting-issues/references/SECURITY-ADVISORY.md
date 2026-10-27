# Security advisory template (private only)

Used only for the `Security-sensitive: private handling required` disposition. This file is written to `.issue-finder/private/` (mode 0700, file mode 0600) and is never published by this skill. Publishing it (sending it to the maintainer through whatever private channel exists) needs its own explicit authorization in `ENGAGEMENT.md`.

```markdown
## Problem

<What the vulnerability is, in plain terms.>

## Affected versions / products

<Exact versions, commits, or configurations confirmed affected.>

## Steps taken to find it

<Brief: what led here (exploration journey, hunting lane, variant search), not implementation detail.>

## Proof of concept

<The smallest, safest, non-destructive demonstration. No irreversible actions, no real-world side effects, nothing run against a system not owned/controlled by this engagement. Provided only for sending through a secure/private channel, never pasted into a public issue.>

## Vulnerable location and root cause

<File:line and mechanism, if known and verified.>

## When it was introduced

<Commit/version, if traced.>

## Impact if exploited

<Only what was actually demonstrated or can be rigorously argued from what was demonstrated. State the CVSS Base vector and qualitative severity per verifying-findings/references/SECURITY-CANDIDATES.md.>

## CWE (if applicable)

<Classification, if clearly known.>

## Suggested remediation

<If one is reasonably apparent; optional.>

## Disclosure channel found

<The project's SECURITY.md contact, or "Report a vulnerability" private advisory feature if enabled, or state that neither was found and the OpenSSF finder-guide fallback order should be used: ask the issue tracker for a security contact, reach maintainers directly, check for a foundation security team, or contact CERT/CC as a last resort.>

## Suggested disclosure timeline

<State one explicitly rather than assuming a universal default; there isn't one. Note this should be proposed to, and confirmed or negotiated with, the maintainer.>

## Already shared with

<State plainly if this information has been shared anywhere else already, or "not shared elsewhere" if not.>
```

## Hard rules for this template

- Never include this content in a public issue, PR description, commit message, or any other public-facing artifact.
- Never run a destructive, irreversible, or real-world-side-effect-producing proof of concept to fill in the PoC section; the smallest safe demonstration is the standard, not the most convincing one.
- The report is ready to send once drafted, but sending it is a separate, explicitly authorized action; drafting never implies permission to transmit.
