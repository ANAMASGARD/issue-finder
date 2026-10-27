# Tours and the SFDIPOT coverage check

## Tours

Named lenses (Whittaker's exploratory-testing "tours") to run over a target you don't know yet, for fast, varied coverage without hand-designing test cases up front. Run at least a Guidebook and a Landmark tour on every entrypoint; add the others where the system map and persona call for them.

| Tour | Run it to find |
| --- | --- |
| **Guidebook** | Follow the README/quickstart/examples verbatim, step by step. Catches every place reality diverges from documentation (a direct Claims-oracle check). |
| **Landmark** | Exercise 5-10 key features/commands in varied, non-documented orders. Order-dependent bugs hide here ("works if you do X before Y, breaks the other way"). |
| **Intellectual** | Push the hardest questions: max field/file/input size, deepest nesting, most complex query, most concurrent callers. |
| **FedEx** | Pick one piece of data (a user string, an uploaded file, a config value) and trace it end to end: where it's created, transformed, stored, rendered. Check consistency at every hop. |
| **Bad Neighborhood** | Use `git log`/`git blame` to find historically bug-prone files (frequent fix commits touching the same region) and focus there. |
| **Museum** | Target old, rarely touched, poorly documented, or undertested code paths; new code usually has newer tests, old code often doesn't. |
| **Back Alley** | Test the least-used, least-visible features, the ones at the bottom of any usage or coverage report. |
| **All-Nighter** | Leave it running under continuous light load without a clean restart; look for leaks, drift, and accumulated-state bugs. |
| **Garbage Collector's** | A fast, shallow pass across every screen/command/endpoint in the shortest path, checking the obvious things everywhere rather than depth anywhere. |
| **Saboteur** | Deliberately try to break it through adversarial, malformed, or out-of-order input. |

## SFDIPOT as a coverage check

Before closing out exploration of an area, check it against every applicable letter of Structure, Function, Data, Interfaces, Platform, Operations, Time (full definitions in `issue-finder/references/SYSTEM-MAP.md`). The point is not to exhaustively test every letter on every feature, it's to notice which letters you haven't touched at all before calling an area "explored."

## Spec inventory and churn as prioritization heuristics

Two cheap ways to decide where to spend chartered-session time first, beyond the claims ledger:

- **Churn.** The project's largest recent merged changes (`git log --stat` on the last several months, sorted by lines changed) are disproportionately where new bugs land; a Landmark or Intellectual tour through a recently-churned area is usually higher-yield than a random walk.
- **Stated invariants with no visible enforcement.** A code comment or doc line asserting "must never happen" or "callers must X" that you can't find a corresponding check for is worth a dedicated FedEx tour tracing that exact value.
