# Organization-scale engagements

When the user names an organization or a set of repositories rather than one checkout, do this before Phase 2 of the main pipeline:

1. **Inventory accessible, active repositories.** List what exists; note which are archived. An archived repo only matters if a currently active product still depends on it.
2. **Give each repository a one-line triage disposition**: active and user-facing, active and internal-only, archived-but-depended-on, or archived-and-dormant. Do not claim an inventory-only repository (one you never opened) is bug-free; say it was not investigated.
3. **Select the deep-investigation set**, sized 6-10 unless the user set a different budget, weighted by: real user impact, recent activity (a repo with fresh commits has fresher assumptions to test), testability (can you actually build and run it here), and cross-component importance (a shared library many others depend on outranks a leaf repo of similar size).
4. **Run the full single-repo pipeline (Phases 1-9) independently per selected repository**, each with its own `.issue-finder/` workspace inside that repository's own checkout, and its own `ENGAGEMENT.md` authorizations (don't assume one repo's authorization carries to a sibling repo).
5. **Roll up one organization-level `REPORT.md`** (outside any single repo, in whatever directory contains all the checkouts) that lists every repository's triage disposition and links to each investigated repo's own `REPORT.md`.

A cross-component finding (the same contract bug on both sides of a producer/consumer pair in two different repos) gets one candidate record cross-referencing both repos, not two independent ones.
