## What it does

Hunts a locally cloned codebase for real, reproducible bugs, vulnerabilities, performance problems, and missing features, by using the project the way a real human user would, then verifying, ranking, and drafting local reports. The defining constraint: it never edits the target's tracked source. A run ends at verified findings and local drafts, never at a commit, a push, or a filed issue, unless each of those is separately and explicitly authorized.

## When to reach for it

- Invocation mode: user-invoked. You type `/issue-finder`; the agent never reaches for it on its own, even if you ask a casual "are there any bugs in this?" question.
- Reach for this when you want a full hunting engagement on a project you've cloned locally: exploring, verifying, screening, ranking, and drafting. For a narrower question (is this one specific thing a real bug, has this already been reported, write up this one finding), call the matching companion skill directly instead; `issue-finder` is the full pipeline, not the only door into any one of its steps.

## Prerequisites

A local git clone of the target project, with shell, git, and the target's own build toolchain available. The companion skills (`exploratory-testing`, `verifying-findings`, `screening-duplicates`, `drafting-issues`) should be installed alongside it; if one is missing, `issue-finder` stops at the step that needed it and tells you which to install.

## The pipeline

Nine phases, in order: Brief (scope, budget, and the authorization ledger in `ENGAGEMENT.md`), Ground (repo state, capabilities, sandbox choice), Map the system, Use it like a real user (hands off to `exploratory-testing`), Hunt (leads from journeys and hunting lanes), Verify and screen (hands off to `verifying-findings` then `screening-duplicates`), Rank and look for variants, Draft (hands off to `drafting-issues`), and the Final report.

## Authorization, not assumption

Every external action, commit, push, rebase, force-push, public issue, PR, and security report, defaults to no in `ENGAGEMENT.md`, a file in the target's own `.issue-finder/` workspace rather than something inferred from chat. That file persists across sessions and context compaction, so authorization survives even when the conversation doesn't.

## It's working if

- `.issue-finder/` exists in the target checkout, excluded via `.git/info/exclude`, not your `.gitignore`.
- `ENGAGEMENT.md` exists with every external action explicitly marked, and nothing was pushed, committed, or filed without you granting that specific authorization.
- The final `REPORT.md` states what was and wasn't tested, plainly, even when the honest answer is zero findings.

## Where it fits

The orchestrator. It calls `exploratory-testing` to generate leads, `verifying-findings` to turn leads into dispositioned findings, and `screening-duplicates` before anything gets drafted by `drafting-issues`. Fixing a finding is a separate, explicit next step: run `issue-fixer` by name, once, per finding.
