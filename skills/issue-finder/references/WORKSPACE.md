# The `.issue-finder/` workspace

Created by `scripts/init-workspace.sh`, or by hand if the script can't run in this environment. Lives inside the target checkout, at its root, and is added to `.git/info/exclude` (not `.gitignore`, so the target's own tracked files stay untouched) so it never gets committed.

```text
.issue-finder/
├── ENGAGEMENT.md         # Phase 1: scope, budget, authorization ledger
├── state.md              # Phase 2: repo state snapshot (REPO-STATE.md fields)
├── capabilities.md       # Phase 2: capability inventory + sandbox choice
├── system-map.md         # Phase 3: SFDIPOT system map
├── claims.md             # Phase 4: claims ledger built from docs/--help/examples
├── journeys.md           # Phase 4: one row per exploratory-testing journey
├── candidates.md         # Phase 5+: one row per IF-### candidate, status + disposition
├── findings/
│   └── IF-001-<slug>/
│       ├── record.md     # the full candidate record (verifying-findings)
│       ├── repro/        # scripts, fixtures, captured output for the reproduction
│       └── evidence/     # logs, screenshots, diffs cited by record.md
├── drafts/                # public-facing draft issue/feature bodies
├── private/               # mode 0700; security-sensitive material only
└── REPORT.md             # Phase 9: final report
```

`candidates.md` is a simple table, one row per candidate:

```markdown
| ID      | Title                          | Status      | Disposition                  | Score |
| ------- | ------------------------------- | ----------- | ----------------------------- | ----- |
| IF-001  | CLI exits 0 on invalid config   | verified    | Confirmed and actionable      | 82    |
| IF-002  | Flaky retry under packet loss   | screening   |                                |       |
```

`private/` must be created with directory mode `0700` and any file inside it with mode `0600`. If the filesystem or sandbox can't set that mode, say so explicitly in `capabilities.md` as a boundary rather than silently writing world-readable security material.
