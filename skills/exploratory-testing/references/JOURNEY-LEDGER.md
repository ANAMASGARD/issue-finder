# `journeys.md` format and the self-audit

One row per chartered session:

```markdown
| Charter | Persona | Tour | Result | Evidence | Leads |
| --- | --- | --- | --- | --- | --- |
| Explore config loading with a first-time install to discover undocumented required fields | First-time user | Guidebook | fail | journeys/001/ | Claims violation: README says 3 required fields, binary requires a 4th undocumented one |
```

Result is exactly one of: `pass`, `fail`, `partial`, `blocked`, `incomplete`.

- `pass` / `fail`: the journey was actually executed and the result observed directly.
- `partial`: some of the charter's scope was covered, some wasn't; say which.
- `blocked`: couldn't attempt it at all (missing capability, no sandbox support); name the blocker.
- `incomplete`: the session ran but the self-audit below caught a sign it wasn't thorough. Never silently upgrade this to `pass`.

## Self-audit before closing a session

A session that looks thorough but wasn't produces false confidence. Before marking any session `pass`, check:

- Did you actually run a command / click through the UI / make a request, or did you only read code and infer the result? Reading-only is `unverifiable` input to `verifying-findings`, never a `pass` journey.
- Is the evidence thin relative to the charter's stated scope (a charter about "config loading" with one command run and no edge cases touched)?
- Did every journey in this session come back clean? A string of all-`pass` results on a charter that targeted limits or adversarial input is a reason to look harder, not a reason to stop early.
- Would a 60-90 minute charter's output fit in a few seconds of actual tool-call time? If the session feels rushed relative to its own charter, mark it `incomplete` and say what's missing, rather than reporting a false `pass`.

## Evidence

Each journey gets its own `journeys/<NNN>/` folder under `.issue-finder/` (or inline in the session notes for a trivial one): captured command output, screenshots, HAR files, or console logs, with secrets redacted per the non-negotiables. Cite the exact path from `journeys.md`'s Evidence column.
