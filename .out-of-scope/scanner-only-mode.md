# A fast mode that skips verification and reports raw scanner/lint output

Rejected direction: a flag or mode where `issue-finder` runs Semgrep, a linter, or `npm audit` and reports the raw hits directly as findings, skipping `verifying-findings`'s reproduction and disproof-attempt gates, for speed.

## Why this is out of scope

This is the exact failure mode the suite exists to avoid: "A suspicious line, TODO, linter warning, dependency alert, scanner result, broad permission, missing best practice, or low-coverage file is a lead. It is not a confirmed issue" (carried over from the source master prompt into every `verifying-findings` run). Static tools stay available as optional inputs that feed leads into the same verification gate as everything else (see `skills/issue-finder/references/OPTIONAL-SKILLS.md`), but nothing produced by a scanner, including Semgrep or CodeQL results from the optional companion skills, ever reaches `drafting-issues` without passing through `verifying-findings` first.
