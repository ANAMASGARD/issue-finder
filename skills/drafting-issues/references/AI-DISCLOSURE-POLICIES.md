# AI-contribution policies differ per project, check the specific target

There is no single open-source-wide convention for AI-assisted issue reports. Real, currently-documented policies disagree with each other, sometimes within the same umbrella organization. Check the specific target repository; never assume one of these applies by default.

- **Permissive with disclosure** (e.g. GTK's `CONTRIBUTING.md`): AI assistance is allowed, but must be disclosed on every issue/MR, fabricated content ("benchmarks, bug reports, test results, code samples, or reproducers") is explicitly forbidden, changes/reports must stay narrow and understood by the submitter, and maintainers are told to reject unverified AI output outright. The policy's own framing is blunt: a human must remain accountable for every maintenance decision.
- **Tool-output exception, human-filed only** (e.g. GStreamer's `AGENTS.md`): agents are explicitly forbidden from using the forge's API/CLI/web UI to open or update issues, merge requests, or comments at all. AI-written issue descriptions and comments are banned outright, **with one named exception**: issues for defects found by specialized tooling (fuzzers, LLM-assisted defect detection) may include verbatim tool output in the description, but the issue must still be reviewed and created by a human, and all maintainer communication must be done by a human.
- **Full ban, applies to everything** (the Loupe-originated policy, since adopted by other projects): no AI-generated contributions of any kind are accepted anywhere in the project, explicitly including issues, not just code. Projects adopting this policy treat a report that looks AI-generated as grounds to close it, and in some cases to warn or ban the reporter.
- **No stated policy at all**: the most common case for smaller projects. Default to the most conservative posture available: draft locally, disclose AI assistance when filing, never auto-publish, and let the human filing it make the final call about what to say.

## What this means for every drafting-issues run

1. Check the specific target's `CONTRIBUTING.md`/`AGENTS.md`/`CLAUDE.md`/issue templates for an explicit AI policy before drafting anything.
2. If the policy is a full ban, stop and tell the user plainly; still write the local draft for the user's own reference, marked "not filable as-is under this project's policy."
3. If the policy requires disclosure, include a plain disclosure line in the draft (not buried, not euphemized).
4. If the policy makes a tooling-output exception (as GStreamer's does), prefer including verbatim, redacted evidence output directly in the draft, since that's the part such policies explicitly protect, and remember the human still has to be the one who files it.
5. If no policy is found, draft conservatively and say in the draft itself that no AI-contribution policy was found, rather than silently assuming permission.
