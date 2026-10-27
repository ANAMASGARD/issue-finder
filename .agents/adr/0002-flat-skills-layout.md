# Flat `skills/<name>/` layout, no bucket folders, no root `SKILL.md`

mattpocock/skills groups its skills into bucket folders (`engineering/`, `productivity/`, `misc/`, `in-progress/`, `deprecated/`) and had to defer a native Codex plugin for a year because Codex's `skills` field could only name one path, which could not select a curated subset across two bucket folders (see that repo's `.agents/adr/0002-ship-as-a-claude-code-plugin.md`, retrieved during research for this repo).

Issue Finder ships exactly six skills, all of them promoted, none deprecated or in-progress. There is no curation problem to solve.

## Decision

Every skill lives directly under `skills/<name>/`, flat, with no bucket folder and no root `SKILL.md`. Two further consequences:

- A root-level `SKILL.md` would also make `npx skills` stop its discovery at the repo root and ship the entire repository (docs, evals, research) into every user's skill directory (facts 6-7 in `docs/research/agent-skills-format-and-distribution.md`, verified by that research's local experiments). The flat `skills/` folder avoids this: only `skills/*` is discovered and shipped.
- Claude Code's, Cursor's, and Codex's plugin manifests can each point a single `skills` field or array at paths under one `skills/` directory with no bucket-selection problem, so this repo ships one plugin manifest per harness family instead of mattpocock's split (Claude Code plugin shipped, Codex plugin deferred).

If this suite ever grows past six skills and needs curation (a `misc/` style bucket for experimental additions), revisit this ADR before introducing bucket folders, since it reopens the exact cross-manifest tension mattpocock's ADR 0002 describes.
