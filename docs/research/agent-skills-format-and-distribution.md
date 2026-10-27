# Agent Skills: format, authoring, and distribution (research for `issue-finder`)

Researched 2026-10-27. Versions checked: `skills` CLI 1.7.4 (vercel-labs/skills commit `533c7df`), GitHub CLI 2.103.2 (`gh skill`, preview), OpenAI Codex source at `2cab11c`, agentskills/agentskills at `69ef37e`, anthropics/skills at `dbd4588`, openai/skills at `49f948f`. Web docs were fetched on the research date; they change often.

Every claim links to the primary source that owns it. "Local experiment" means a reproducible test run during this research in a throwaway `/tmp` sandbox with a fake `HOME` and `DISABLE_TELEMETRY=1` (commands are in the [appendix](#appendix-local-experiments)). Community sources are marked **[secondary]**; anything not confirmed is marked **[unverified]**.

## Top 10 design-relevant facts

1. **The open spec allows exactly six frontmatter keys.** These are `name` and `description` (required) plus `license`, `compatibility`, `metadata`, and `allowed-tools` (optional). The reference validator, claude.ai uploads, and the Claude Skills API all hard-fail on any other key. ([spec](https://agentskills.io/specification), [skills-ref validator](https://github.com/agentskills/agentskills/blob/69ef37e9424c0a7ea9dd2293b559e43ec8176379/skills-ref/src/skills_ref/validator.py), [Claude Code docs](https://code.claude.com/docs/en/skills))
2. **`name` must be 1–64 characters of `a-z`, `0-9`, and single hyphens, and must match the parent directory name.** Anthropic additionally forbids XML tags and the words "anthropic" and "claude". `issue-finder` is valid. ([spec](https://agentskills.io/specification), [Anthropic best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices))
3. **The `description` (max 1,024 characters) is the only trigger signal, and hosts truncate it.** Claude Code cuts `description` + `when_to_use` at 1,536 characters in its skill listing. Codex shortens descriptions when the skill list exceeds 2% of the context window (or 8,000 characters), so put the key use case and trigger words first. ([Claude Code docs](https://code.claude.com/docs/en/skills), [Codex docs](https://developers.openai.com/codex/skills))
4. **Keep the `SKILL.md` body under 500 lines and about 5,000 tokens.** Put detail in `references/` files that are loaded on demand. Link them one level deep, using relative paths from the skill root with forward slashes. ([spec](https://agentskills.io/specification), [Anthropic best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices))
5. **After auto-compaction, Claude Code re-attaches only the first 5,000 tokens of an invoked skill** (all skills share a 25,000-token budget). A long-running workflow such as issue-finder must put its non-negotiable rules at the top. ([Claude Code docs](https://code.claude.com/docs/en/skills))
6. **`npx skills add owner/repo` stops at a repo-root `SKILL.md`.** If one exists, that is the only skill it discovers. Otherwise it walks `skills/` and about 30 hard-coded agent directories up to three levels deep. The installed folder is named after the sanitized frontmatter `name`, and when a repo contains exactly one skill it is selected automatically. ([skills.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/skills.ts#L248-L274), [installer.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/installer.ts#L320-L322), [add.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/add.ts#L1991))
7. **With a repo-root `SKILL.md`, the whole repo is copied into every user's skill folder.** That includes `README.md`, `docs/`, and `evals/`; only `.git`, `__pycache__`, `__pypackages__`, and `metadata.json` are excluded. A `skills/issue-finder/` layout ships only that folder. This was verified with both `npx skills` and `gh skill`. ([installer.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/installer.ts#L475-L481), [local experiment](#appendix-local-experiments))
8. **The `skills` CLI installs into `.agents/skills/` (project scope) or `~/.agents/skills/` (global, `-g`).** Cursor, Codex, Gemini CLI, GitHub Copilot, and OpenCode all read those paths natively. Claude Code gets a symlink in `.claude/skills/` or `~/.claude/skills/`. ([agents.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/agents.md), [installer.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/installer.ts#L409-L419), [local experiment](#appendix-local-experiments))
9. **skills.sh lists a skill automatically from anonymous `npx skills add` install telemetry.** There is no submission step, and telemetry is sent only for repos that GitHub confirms are public. ([skills.sh FAQ](https://www.skills.sh/docs/faq), [add.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/add.ts#L2422), [Vercel KB](https://vercel.com/kb/guide/agent-skills-creating-installing-and-sharing-reusable-agent-context))
10. **Agent-specific frontmatter keys are silently ignored by other agents but break spec validation.** Examples are Claude Code's `disable-model-invocation`, `user-invocable`, `when_to_use`, `context`, and `hooks`, and Cursor's `paths`, `icon`, and `color`. `allowed-tools` is experimental, and each agent uses a different tool vocabulary (Claude Code `Bash(git:*)`, Copilot `shell`). Codex-only UI and invocation policy belongs in a separate `agents/openai.yaml`. ([Claude Code docs](https://code.claude.com/docs/en/skills), [Cursor docs](https://cursor.com/docs/context/skills), [Copilot docs](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills), [Codex docs](https://developers.openai.com/codex/skills))

---

## 1. The Agent Skills open specification

The canonical spec lives at agentskills.io. The anthropics/skills repo now only redirects there ([anthropics/skills spec/agent-skills-spec.md](https://github.com/anthropics/skills/blob/dbd4588f9e1033efb41dad4bef2f7947c8993d44/spec/agent-skills-spec.md)). The spec's GitHub home is [agentskills/agentskills](https://github.com/agentskills/agentskills).

### 1.1 Frontmatter fields

`SKILL.md` must contain YAML frontmatter followed by Markdown ([spec](https://agentskills.io/specification)).

| Field | Required | Constraints (from [spec](https://agentskills.io/specification)) |
| --- | --- | --- |
| `name` | Yes | 1–64 chars; lowercase alphanumerics and hyphens only; no leading/trailing hyphen; no `--`; **must match the parent directory name** |
| `description` | Yes | 1–1024 chars; non-empty; should say what the skill does **and** when to use it, with keywords |
| `license` | No | License name or reference to a bundled license file; keep it short |
| `compatibility` | No | 1–500 chars if present; environment requirements (product, system packages, network). "Most skills do not need" it |
| `metadata` | No | Map of string keys to string values; use reasonably unique keys |
| `allowed-tools` | No | Space-separated string of pre-approved tools; **experimental**, support varies by agent |

How the constraints are enforced in practice:

- **Reference validator.** `skills-ref validate` rejects any key outside these six, checks the length limits, and errors when the directory name differs from `name` (both are NFKC-normalized before comparison) ([validator.py](https://github.com/agentskills/agentskills/blob/69ef37e9424c0a7ea9dd2293b559e43ec8176379/skills-ref/src/skills_ref/validator.py)). Its README says the library is "for demonstration purposes only" ([skills-ref README](https://github.com/agentskills/agentskills/blob/69ef37e9424c0a7ea9dd2293b559e43ec8176379/skills-ref/README.md)).
- **Recommended client behavior.** The client-implementation guide tells agents to be lenient. A name that doesn't match its directory, or that exceeds 64 characters, should produce a warning but still load. A missing description or unparseable YAML should cause the skill to be skipped ([adding skills support](https://agentskills.io/client-implementation/adding-skills-support)).
- **Anthropic extras.** Anthropic adds: no XML tags in `name` or `description`, and no reserved words "anthropic" or "claude" in `name` ([Anthropic best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)).

### 1.2 Directory layout

A skill is a directory containing at least `SKILL.md`. The conventional optional directories are `scripts/` (executable code), `references/` (documentation loaded on demand, e.g. `REFERENCE.md` or domain files), and `assets/` (templates, images, data). Any other files are allowed ([spec](https://agentskills.io/specification)).

- **Scripts** should be self-contained or document their dependencies, give helpful error messages, and handle edge cases ([spec](https://agentskills.io/specification)).
- **Reference files** should stay focused, because "smaller files mean less use of context" ([spec](https://agentskills.io/specification)).

### 1.3 Progressive disclosure and size limits

Skills load in three tiers ([spec](https://agentskills.io/specification)):

1. Metadata (~100 tokens): `name` and `description` for every skill, loaded at startup.
2. Instructions (< 5,000 tokens recommended): the full body, loaded on activation.
3. Resources: other files, loaded only when needed.

"Keep your main `SKILL.md` under 500 lines" ([spec](https://agentskills.io/specification)). The agentskills.io best-practices page restates this as under 500 lines **and** under 5,000 tokens ([best practices](https://agentskills.io/skill-creation/best-practices)).

### 1.4 File references

- **Use relative paths from the skill root**, e.g. `[the reference guide](references/REFERENCE.md)` or `scripts/extract.py`. Keep references one level deep and avoid nested reference chains ([spec](https://agentskills.io/specification)).
- **Clients resolve these paths against the skill directory**, the parent of `SKILL.md`. The guide recommends telling the model "Relative paths in this skill are relative to the skill directory" ([adding skills support](https://agentskills.io/client-implementation/adding-skills-support)).
- **No absolute paths are needed**; "the agent resolves these paths automatically" ([using scripts](https://agentskills.io/skill-creation/using-scripts)).
- **Cursor and Copilot work the same way.** Cursor documents relative paths from the skill root ([Cursor docs](https://cursor.com/docs/context/skills)). Copilot's example says to run a script "from this skill's base directory" ([Copilot how-to](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills)).

### 1.5 Other spec-site guidance

- **Descriptions.** Use imperative phrasing ("Use this skill when…"), focus on user intent, "err on the side of being pushy", and keep it to a few sentences. Test triggering with about 20 queries (8–10 that should trigger, 8–10 near-misses that should not), run each about 3 times, and compute a trigger rate ([optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)).
- **Evals.** Store test cases in `evals/evals.json` inside the skill directory. Run each case **with and without** the skill (or against the previous version), add assertions after the first run, grade them with evidence, and record tokens and time ([evaluating skills](https://agentskills.io/skill-creation/evaluating-skills)).
- **Scripts.** Scripts must be non-interactive (a "hard requirement"). Document them with `--help`, send structured data to stdout and diagnostics to stderr, use meaningful exit codes, support `--dry-run` for stateful operations, and pin versions of one-off tools (e.g. `npx eslint@9.0.0`). Declare inline dependencies with PEP 723 for `uv run`, or the equivalent for Deno, Bun, or Ruby ([using scripts](https://agentskills.io/skill-creation/using-scripts)).
- **Content.** Start from real expertise. Add what the agent lacks and omit what it already knows. Include a **Gotchas** section, which is often the highest-value content. Provide output templates, checklists, validation loops, and plan-validate-execute steps. Offer "defaults, not menus", and prefer procedures over one-off answers ([best practices](https://agentskills.io/skill-creation/best-practices)).
- **Untrusted project skills.** Project-level skills from an untrusted repository, "e.g., a freshly cloned open-source project", can inject instructions, so clients should consider gating them behind a trust check ([adding skills support](https://agentskills.io/client-implementation/adding-skills-support)).

---

## 2. Anthropic's skill authoring best practices

Source: [platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices). The `docs.claude.com/...` URL returns a 302 redirect to this page.

- **Concise is key.** "The context window is a public good." Default to assuming Claude is already very smart, and add only context it lacks. For every paragraph, ask whether it justifies its token cost.
- **Degrees of freedom.** Match specificity to how fragile and variable the task is:
  - High freedom (prose heuristics) when many approaches are valid.
  - Medium freedom (pseudocode or parameterized scripts).
  - Low freedom (exact commands, "Do not modify the command") for fragile sequences.
  - The page's analogy: a "narrow bridge with cliffs" versus an "open field".
- **Test with every model you plan to use** (Haiku, Sonnet, Opus). What works for Opus may need more detail for Haiku.
- **Naming.** Gerund form (`processing-pdfs`) is suggested. Noun phrases (`pdf-processing`) are acceptable. Avoid vague or generic names and reserved words.
- **Descriptions.**
  - **Always write in third person**, because the description is injected into the system prompt ("Processes Excel files…", not "I can help…" or "You can use this…").
  - Be specific, and include both what the skill does and its triggers.
  - Claude picks from "potentially 100+" skills using only this text.
  - This differs from agentskills.io's imperative advice (§1.5). Both sources' examples share the pattern "<what it does>. Use when <triggers>."
- **Progressive disclosure.**
  - Keep the body under 500 lines.
  - `SKILL.md` acts as a table of contents pointing to `FORMS.md`, `reference/finance.md`, and similar files.
  - Organize references by domain, and use conditional pointers ("For tracked changes: See REDLINING.md").
- **References one level deep.** Claude may partially read (`head -100`) files that are reached through other references. Link every reference directly from `SKILL.md`, and give reference files longer than 100 lines a table of contents at the top.
- **Workflows and checklists.** For complex tasks, provide numbered steps and a checklist Claude copies into its response and checks off.
- **Feedback loops.** "Run validator → fix errors → repeat". The validator can be a script or a reference document such as a style guide.
- **Plan-validate-execute.** Have Claude write an intermediate plan file, validate it with a script, then execute. Use this for batch, destructive, or high-stakes operations.
- **Content rules.**
  - Avoid time-sensitive information (put it in a collapsed "Old patterns" section).
  - Use consistent terminology.
  - Use templates (strict or flexible), input/output examples, and conditional workflows.
- **Evaluation-driven development.** Build evaluations **before** writing extensive docs:
  1. Find gaps by running without the skill.
  2. Create three scenarios.
  3. Measure a baseline.
  4. Write minimal instructions.
  5. Iterate.
  - Anthropic shows a JSON evaluation shape (`skills`, `query`, `files`, `expected_behavior`) and notes there is "not currently a built-in way to run these evaluations".
  - Iterate with "Claude A" (author) and "Claude B" (tester), and observe how Claude navigates the files (unexpected paths, missed links, ignored files).
- **Anti-patterns.**
  - Windows-style paths; always use forward slashes.
  - Offering too many options instead of a default with an escape hatch.
  - Deeply nested references.
  - Vague descriptions.
  - Scripts that "punt" errors to Claude.
  - "Voodoo constants".
  - Assuming packages are installed instead of listing them.
  - Unqualified MCP tool names; use `Server:tool`.
- **Scripts.** Prefer bundled utility scripts for deterministic operations: they are more reliable, save tokens, and are consistent. State clearly whether Claude should **run** a script or **read** it.
- **Checklist before sharing.** Specific description with triggers, body under 500 lines, references one level deep, no time-sensitive information, at least 3 evaluations, tested on Haiku, Sonnet, and Opus, and tested with real usage.

---

## 3. Distribution via `npx skills` (vercel-labs/skills) and skills.sh

The CLI is the npm package `skills` (v1.7.4; bins `skills` and `add-skill`). It requires Node.js 22.20 or later and its homepage is skills.sh ([README](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/README.md), [package.json](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/package.json)).

### 3.1 How `npx skills add <source>` discovers skills

Accepted source formats ([commands.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/commands.md)):

- `owner/repo`
- A full GitHub URL, or a `/tree/<ref>/<path>` URL pointing at one skill
- A GitLab or Azure Repos URL
- Any git URL
- A local path
- A direct `SKILL.md` or archive URL (limited to 10 MiB downloaded, 25 MiB extracted, 1,000 files)

Discovery algorithm ([skills.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/skills.ts); [creating-skills.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/creating-skills.md); Context7 `/vercel-labs/skills` matches):

1. **Repo-root `SKILL.md`.** If the search path contains `SKILL.md`, the CLI adds it and **returns early**, so no other skills are discovered unless `--full-depth` is passed ([L248-L263](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/skills.ts#L248-L263)).
2. **Priority containers.** These are walked up to depth 3: `skills/`, `skills/.curated/`, `skills/.experimental/`, `skills/.system/`, and 30 hard-coded agent directories (`.agents/skills/`, `.claude/skills/`, `.codex/skills/`, `.github/skills/`, …). The generated docs list about 52 agent directories; see the conflict note at the end. The repo root itself is walked only to depth 1. A shallower `SKILL.md` shadows anything nested below it ([L266-L322](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/skills.ts#L266-L322)).
3. **Plugin manifests.** Skills declared in `.claude-plugin/marketplace.json` or `.claude-plugin/plugin.json` are also discovered. Paths must start with `./` ([plugin-manifest.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/plugin-manifest.ts)).
4. **Recursive fallback.** If nothing is found, the CLI searches recursively to depth 5, skipping `node_modules`, `.git`, `dist`, `build`, and `__pycache__` ([L324-L340](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/skills.ts#L324-L340)).
5. **Validation.** A skill is skipped, with a warning, if its frontmatter lacks a string `name` or a string `description`. No other validation is done: no name charset check and no directory-match check ([L100-L115](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/skills.ts#L100-L115)). The YAML parser deliberately rejects `---js` frontmatter ([frontmatter.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/frontmatter.ts)).
6. **Hidden skills.** `metadata.internal: true` hides a skill unless `INSTALL_INTERNAL_SKILLS=1` is set ([creating-skills.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/creating-skills.md)).
7. **Fetching.** For GitHub sources, the CLI first tries a "blob" fast path: the GitHub Trees API, then `raw.githubusercontent.com` for frontmatter, then the `skills.sh/api/download` snapshot. It falls back to `git clone --depth 1` ([blob.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/blob.ts#L1-L11), [git.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/git.ts)).

### 3.2 What gets installed, and where

- **Folder name.** The install folder is `sanitizeName(frontmatter.name)`, not the repo or directory name ([installer.ts L320-L322](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/installer.ts#L320-L322), [sanitizeName](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/installer.ts#L66-L81)).
- **Files copied.** The whole skill directory is copied, excluding only `.git/`, `__pycache__/`, `__pypackages__/`, and `metadata.json` ([installer.ts L475-L481](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/installer.ts#L475-L481)). For a repo-root `SKILL.md`, the "skill directory" is the entire repo. The local experiment confirmed that `README.md`, `docs/research/notes.md`, and `evals/evals.json` all landed in `.claude/skills/issue-finder/`.
- **Install mode.** The default is symlink mode: one canonical copy in `.agents/skills/<name>`, linked into agent-specific directories. `--copy` makes independent copies ([commands.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/commands.md)).
- **Lock file.** Project installs write `skills-lock.json`, which records the source, source type, and a content hash (local experiment).
- **Agent paths.** The table below lists the agents relevant here. The full table of about 80 agents is in [agents.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/agents.md), and the definitions are in [agents.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/agents.ts).

| Agent (`--agent`) | Project path | Documented global path | Actual global install (CLI 1.7.4, local experiment) |
| --- | --- | --- | --- |
| Claude Code (`claude-code`) | `.claude/skills/` (symlink to `.agents/skills/`) | `~/.claude/skills/` | `~/.agents/skills/issue-finder` + symlink `~/.claude/skills/issue-finder` |
| Cursor (`cursor`) | `.agents/skills/` | `~/.cursor/skills/` | `~/.agents/skills/` only |
| Codex (`codex`) | `.agents/skills/` | `~/.agents/skills/` | `~/.agents/skills/` |
| Gemini CLI (`gemini-cli`) | `.agents/skills/` | `~/.gemini/skills/` | `~/.agents/skills/` only |
| GitHub Copilot (`github-copilot`) | `.agents/skills/` | `~/.copilot/skills/` | `~/.agents/skills/` only |
| OpenCode (`opencode`) | `.agents/skills/` | `~/.config/opencode/skills/` | `~/.agents/skills/` only |

The "only" rows follow from the code: global installs for "universal" agents skip the agent-specific link to avoid duplicates ([installer.ts L409-L419](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/installer.ts#L409-L419)). Each of those agents reads `~/.agents/skills` natively (see §4.3). For project installs, the CLI only links into non-universal agents' directories when that agent's root folder (e.g. `.windsurf/`) already exists. Claude Code is the exception and always gets one ([installer.ts L100-L117, L421-L441](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/installer.ts#L100-L117), [agents.ts L155-L165](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/agents.ts#L155-L165)).

### 3.3 Flags (from `npx skills --help`, v1.7.4, and [commands.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/commands.md))

- `add`:
  - `-g/--global` installs at user scope.
  - `-a/--agent <agents…>` targets specific agents (`'*'` for all).
  - `-s/--skill <names…>` installs named skills (`'*'` for all).
  - `-l/--list` lists skills without installing.
  - `-y/--yes` skips prompts.
  - `--copy` copies instead of symlinking.
  - `--all` is shorthand for `--skill '*' --agent '*' -y`.
  - `--full-depth` searches past a root `SKILL.md`.
  - `--json` prints machine-readable output.
  - `--metadata <json>` attaches data to the telemetry event.
- **Other commands:** `use <source>@<skill> [--agent X]` runs a skill without installing it. Also available: `find [query]`, `list|ls`, `check`, `update`, `remove|rm`, `init [name]`, and the experimental `experimental_sync` and `experimental_install`.
- **Automatic agent detection.** The CLI detects installed agents (e.g. `~/.cursor`, `~/.claude`, `~/.gemini` exist) and prompts if none are found ([agents.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/agents.md)).
- **Single-skill repos.** If exactly one skill is discovered, it is auto-selected without a prompt ([add.ts L1991](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/add.ts#L1991)).

### 3.4 Listing on skills.sh

- **Listing is automatic.** "Skills appear on the leaderboard automatically through anonymous telemetry when users run `npx skills add`". Ranking is based on install counts ([skills.sh FAQ](https://www.skills.sh/docs/faq), [skills.sh docs](https://skills.sh/docs)). Vercel's own guide says the same: "No registry submission flow" ([Vercel KB](https://vercel.com/kb/guide/agent-skills-creating-installing-and-sharing-reusable-agent-context)).
- **Telemetry.** Events go to `https://www.skills.sh/tele/t` ([telemetry.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/telemetry.ts#L3-L4)). Repository identifiers are sent only when GitHub confirms the repo is public ([add.ts L2422](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/add.ts#L2422), [troubleshooting.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/troubleshooting.md)). `DISABLE_TELEMETRY=1` or `DO_NOT_TRACK=1` turns it off.
- **Search.** `npx skills find` queries `skills.sh/api/search` ([find.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/find.ts)), so a skill must have installs before it can be found there.
- **Security audits.** skills.sh runs "routine security audits" ([skills.sh docs](https://skills.sh/docs)). The CLI shows partner audit risk ratings (Gen/ATH, Socket, Snyk) at install time for confirmed-public GitHub repos ([add.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/add.ts), [telemetry.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/telemetry.ts)).
- **Badge.** `[![skills.sh](https://skills.sh/b/owner/repo)](https://skills.sh/owner/repo)` ([skills.sh docs](https://skills.sh/docs)).
- **Not documented:** any minimum install threshold before a skill appears, or how often the index refreshes. **[unverified]** Community reports in [vercel-labs/skills#1315](https://github.com/vercel-labs/skills/issues/1315) and [#880](https://github.com/vercel-labs/skills/issues/880) **[secondary]** say the same.

### 3.5 Repo layout: one skill or several

- **Single skill.** Either a root `SKILL.md` or `skills/<name>/SKILL.md` works. With a root `SKILL.md`, everything else in the repo ships with it (§3.2), and any other skills in the repo are hidden unless the user passes `--full-depth`.
- **Several skills.** Use `skills/<name>/SKILL.md`, or `skills/<category>/<name>/SKILL.md` up to two category levels ([creating-skills.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/creating-skills.md)). Users choose with `--skill <name>`.
- **Troubleshooting.** "No skills found" usually means the frontmatter is missing `name` or `description` ([troubleshooting.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/troubleshooting.md)).

---

## 4. Alternative distribution channels and agent-specific locations

### 4.1 npm packages

There is an **experimental** convention:

- **`skills experimental_sync`.** This command reads a project's installed dependencies and discovers each package's root `SKILL.md`, `skills/<name>/SKILL.md`, or `dist/skills/<name>/SKILL.md`. It links them into `.agents/skills/` and the selected agent directories, and records them in `skills-lock.json` ([commands.md § experimental_sync](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/commands.md)).
- **Package authors** are told to add a `skills/` directory with one subdirectory per skill and to include `skills` in `package.json` `files` ([antfu/skills-npm PROPOSAL.md](https://github.com/antfu/skills-npm/blob/37a3affb356011d52b6e10a6d2066716acd5a4ac/PROPOSAL.md)). This is a community spec by Anthony Fu that the vercel-labs/skills docs link to as the field specification.
- **Skill packs.** A `package.json` `"skills": [...]` field can declare remote skills, making a "skills pack" ([SPEC.md](https://github.com/antfu/skills-npm/blob/37a3affb356011d52b6e10a6d2066716acd5a4ac/SPEC.md), RFC [vercel-labs/skills#2323](https://github.com/vercel-labs/skills/issues/2323)).
- **Claude Code plugin marketplaces** also accept an `npm` plugin source ([plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)).
- **`npx skills add` does not accept npm package names.** Its documented sources are git or URL or local path, and npm is not listed ([commands.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/commands.md)). An npm package is therefore only useful for `experimental_sync` or skills-npm users, not for the headline `npx skills add` flow.

### 4.2 Claude Code: skill locations, plugins, and marketplaces

- **Skill locations.** Personal skills go in `~/.claude/skills/<name>/SKILL.md` and project skills in `.claude/skills/<name>/SKILL.md`. Plugin skills live at `<plugin>/skills/<name>/SKILL.md` and are namespaced `/plugin-name:skill-name`. Cloud and Cowork sessions do **not** read `~/.claude/skills` ([Claude Code skills](https://code.claude.com/docs/en/skills)).
- **`plugin.json`.** The plugin manifest at `.claude-plugin/plugin.json` is optional. `name` is its only required key, and other plugin files stay at the plugin root ([plugins-reference](https://code.claude.com/docs/en/plugins-reference)).
- **Single-skill plugins.** "A plugin with `SKILL.md` at its root, no `skills/`, and no `skills` key loads as a single skill" ([plugins-reference](https://code.claude.com/docs/en/plugins-reference)).
- **`marketplace.json`.** `.claude-plugin/marketplace.json` requires `name`, `owner`, and a `plugins[]` array of `{name, source}` entries. Relative `source` paths are resolved from the marketplace root, and `..` is not allowed. The entry name should equal the `plugin.json` name. Users run `claude plugin marketplace add owner/repo`, then `claude plugin install <plugin>@<marketplace>` ([plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)).
- **Plugin sources** can be a relative path, `github`, `git-subdir`, `url`, `archive`, `npm`, or `command` ([plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)).
- **Proven pattern.** anthropics/skills ships skills under `skills/` with a root marketplace whose entries use `"source": "./"`, `"strict": false`, and an explicit `"skills": ["./skills/pdf", …]` ([marketplace.json](https://github.com/anthropics/skills/blob/dbd4588f9e1033efb41dad4bef2f7947c8993d44/.claude-plugin/marketplace.json)). The `skills` CLI reads the same manifest (§3.1), and so does Codex, as a "legacy-compatible marketplace" (§4.4).

### 4.3 Cursor

- **Load locations** ([Cursor skills docs](https://cursor.com/docs/context/skills)):
  - Project: `.agents/skills/` and `.cursor/skills/`.
  - User: `~/.agents/skills/` and `~/.cursor/skills/`.
  - "For compatibility": `.claude/skills/`, `.codex/skills/`, `~/.claude/skills/`, and `~/.codex/skills/`.
- **Nested folders.** Cursor walks skill roots recursively. Nested project `.cursor/skills/` folders are auto-scoped to their subtree.
- **Cloud Agents.** Only `~/.cursor/skills/` can be synced to Cloud Agents. `~/.agents/skills/` stays local. Project skills travel with the repo.
- **Frontmatter.** Cursor documents `name` (must match the folder name), `description`, `paths`, `disable-model-invocation`, `icon`, `color`, and `metadata`.
- **Importing from GitHub.** Cursor does not import loose skills from a GitHub repo. To install from a repo through the Cursor UI, the skills must be packaged as a plugin with `.cursor-plugin/marketplace.json` ([Cursor skills docs](https://cursor.com/docs/context/skills)).
- **Plugin formats.** Cursor supports Cursor Plugins (`.cursor-plugin/plugin.json`) and the open **Agent Plugins** standard (root `plugin.json` with `$schema: https://agent-plugins.org/schemas/1.0.0/plugin.schema.json` and a `skills/` directory) ([Cursor plugins](https://cursor.com/docs/plugins), [agent-plugins.org](https://agent-plugins.org)).

### 4.4 OpenAI Codex

- **Load locations** ([Codex skills docs](https://developers.openai.com/codex/skills)):
  - Repo: `.agents/skills` in every directory from the current directory up to the repo root.
  - User: `$HOME/.agents/skills`.
  - Admin: `/etc/codex/skills`.
  - System: bundled with Codex.
  - Symlinked skill folders are followed.
- **`~/.codex/skills` is deprecated.** The Codex source marks `$CODEX_HOME/skills` as a "Deprecated user skills location … kept for backward compatibility" and also loads `~/.agents/skills` ([host_roots.rs L95-L108](https://github.com/openai/codex/blob/2cab11ca40aad193382348a7bda46da2fc47596a/codex-rs/ext/skills/src/host_roots.rs#L95-L108)). The current docs list only `~/.agents/skills`.
- **Parser behavior.** `name` falls back to the directory name when missing and is capped at 64 characters. `description` must be non-empty. Values are flattened to a single line. `metadata.short-description` is also read ([parser.rs](https://github.com/openai/codex/blob/2cab11ca40aad193382348a7bda46da2fc47596a/codex-rs/skills/src/parser.rs#L4-L92)).
- **Distribution.** Codex docs say "For installable distribution, prefer plugins". A portable package is a root `plugin.json` (Agent Plugins schema) plus `skills/`, with an optional `.codex-plugin/plugin.json` as a compatibility fallback. Repo marketplaces live at `.agents/plugins/marketplace.json`, and `.claude-plugin/marketplace.json` is read as "legacy-compatible" ([Codex plugins build](https://developers.openai.com/codex/plugins/build)).

### 4.5 `agents/openai.yaml`: what the local examples are for

The two local files are:

- `/home/linux/.agents/skills/fp-check/agents/openai.yaml`: `interface.display_name: "False Positive Check"`, `short_description: "Verify suspected vulnerabilities against code evidence"`, `icon_small` and `icon_large` set to `assets/trail-of-bits-mark.svg`, and `brand_color: "#D83A34"`.
- `/home/linux/.agents/skills/audit-context-building/agents/openai.yaml`: only icons and `brand_color`.

What the file does:

- **Purpose.** It is an optional Codex/ChatGPT-specific sidecar that "configure[s] UI metadata in the ChatGPT desktop app, … invocation policy, and … tool dependencies" ([Codex skills docs](https://developers.openai.com/codex/skills)).
- **Audience.** OpenAI's skill-creator reference says it is "an extended, product-specific config intended for the machine/harness to read, not the agent", and that other product-specific config can also live in `agents/` ([openai_yaml.md](https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.system/skill-creator/references/openai_yaml.md)).
- **Supported keys** ([Codex skills docs](https://developers.openai.com/codex/skills); [metadata.rs](https://github.com/openai/codex/blob/2cab11ca40aad193382348a7bda46da2fc47596a/codex-rs/skills/src/metadata.rs); [interface.rs](https://github.com/openai/codex/blob/2cab11ca40aad193382348a7bda46da2fc47596a/codex-rs/skills/src/interface.rs#L10-L21)):
  - `interface.display_name`, `short_description`, `icon_small`, `icon_large`, `brand_color`, and `default_prompt`.
  - `policy.allow_implicit_invocation` (default `true`). When it is `false`, Codex won't pick the skill implicitly, but `$skill` still works.
  - `dependencies.tools[]` (currently only `type: "mcp"`, with `value`, `description`, `transport`, and `url`).
- **Authoring conventions** ([openai_yaml.md](https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.system/skill-creator/references/openai_yaml.md)):
  - Quote string values.
  - Keep `short_description` to 25–64 characters.
  - Icon paths are relative to the skill directory, under `./assets/`.
  - `default_prompt` must mention `$skill-name`.
- **Prevalence.** Every curated and system skill in openai/skills has one, at `skills/.curated/*/agents/openai.yaml` and `skills/.system/*/agents/openai.yaml` ([openai/skills tree](https://github.com/openai/skills/tree/49f948faa9258a0c61caceaf225e179651397431/skills)).
- **Portability.** Because it lives outside the `SKILL.md` frontmatter, it doesn't trip spec validators. Other agents ignore the extra directory; the `skills` CLI copies all non-excluded files (§3.2).

### 4.6 Other agents' locations (for the README)

- **Gemini CLI.** User skills: `~/.gemini/skills/` or the `~/.agents/skills/` alias. Workspace skills: `.gemini/skills/` or `.agents/skills/`. Within a tier, the `.agents` alias wins. Gemini asks the user for consent on activation, then grants read access to the skill directory. `gemini skills install <git-url> [--path subdir]` installs from a repo ([Gemini CLI skills](https://geminicli.com/docs/cli/skills/)).
- **GitHub Copilot.** Project skills: `.github/skills`, `.claude/skills`, or `.agents/skills`. Personal skills: `~/.copilot/skills` or `~/.agents/skills` ([about agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)). Copilot automatically exposes all files in the skill directory ([Copilot how-to](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills)).
- **`gh skill` (GitHub CLI ≥ 2.90, preview)** ([Copilot how-to](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills); local `gh skill install --help` / `gh skill publish --help`, gh 2.103.2):
  - Commands: `install OWNER/REPO SKILL[@ver]`, `preview`, `search`, `update`, and `publish`.
  - Discovery conventions: `skills/*/SKILL.md`, `skills/{scope}/*/SKILL.md`, `*/SKILL.md`, and `plugins/{scope}/skills/*/SKILL.md`.
  - Versions: install resolves the **latest tagged release** first.
  - Metadata: install injects provenance into `metadata` (`github-*` keys).
  - `publish` validates strict naming, name == directory, and `allowed-tools` being a string, then offers to add the `agent-skills` topic and create a semver release.
- **OpenCode.** Loads `.opencode/skills/`, `.claude/skills/`, and `.agents/skills/` (walking up to the git worktree root), plus `~/.config/opencode/skills/`, `~/.claude/skills/`, and `~/.agents/skills/`. It uses only the spec fields and ignores unknown ones. It enforces the spec name regex and name == directory ([OpenCode skills](https://opencode.ai/docs/skills)).

---

## 5. Cross-agent portability

### 5.1 Which keys are portable

| Key | Status | Who acts on it |
| --- | --- | --- |
| `name`, `description` | Spec, required | All |
| `license`, `compatibility`, `metadata` | Spec, optional | Accepted by Claude Code but not acted on ([Claude Code docs](https://code.claude.com/docs/en/skills)); listed by OpenCode ([OpenCode](https://opencode.ai/docs/skills)) |
| `allowed-tools` | Spec, **experimental** | Claude Code (grant lasts for the invoking turn), Copilot (e.g. `shell`) ([Claude Code](https://code.claude.com/docs/en/skills), [Copilot](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills)). The skills CLI's compatibility table marks Kiro CLI and Zencoder "No" ([agents.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/agents.md)) |
| `disable-model-invocation` | Claude Code + Cursor extension | Not in spec ([Claude Code](https://code.claude.com/docs/en/skills), [Cursor](https://cursor.com/docs/context/skills)) |
| `paths` | Claude Code + Cursor extension | Not in spec |
| `user-invocable`, `when_to_use`, `argument-hint`, `arguments`, `disallowed-tools`, `model`, `effort`, `context: fork`, `agent`, `background`, `hooks`, `shell` | Claude Code only | [Claude Code docs](https://code.claude.com/docs/en/skills); `context: fork` and hooks are Claude Code-only per [agents.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/agents.md) |
| `icon`, `color`, legacy `globs` | Cursor only | [Cursor docs](https://cursor.com/docs/context/skills) |
| `metadata.short-description` | Read by Codex | [parser.rs](https://github.com/openai/codex/blob/2cab11ca40aad193382348a7bda46da2fc47596a/codex-rs/skills/src/parser.rs#L16-L20) |
| `metadata.internal` | Hides the skill in the `skills` CLI | [creating-skills.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/creating-skills.md) |
| `metadata.github-*`, `metadata.local-path` | Written by `gh skill install`; stripped by `gh skill publish --fix` | local `gh skill publish --help`; local experiment |

### 5.2 What breaks or degrades with non-spec keys

- **Hard failures.** claude.ai uploads, the Skills API, and `package_skill.py` fail with "Unexpected key(s) in SKILL.md frontmatter" ([Claude Code docs](https://code.claude.com/docs/en/skills)). `skills-ref validate` also fails ([validator.py](https://github.com/agentskills/agentskills/blob/69ef37e9424c0a7ea9dd2293b559e43ec8176379/skills-ref/src/skills_ref/validator.py)).
- **Silent ignores.** Claude Code ignores unrecognized keys ([Claude Code docs](https://code.claude.com/docs/en/skills)), and so does OpenCode ([OpenCode](https://opencode.ai/docs/skills)). The skill loads, but the behavior you asked for silently doesn't happen.
- **Body syntax.** Claude Code-only body features don't work elsewhere: `$ARGUMENTS`/`$0`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, and `` !`cmd` `` dynamic injection. On other agents they appear as literal text ([Claude Code docs](https://code.claude.com/docs/en/skills)). Relative paths are the portable alternative (§1.4).
- **Tool names differ.** `allowed-tools` values are not interchangeable: Claude Code uses `Bash(git:*) Read` ([spec example](https://agentskills.io/specification)), while Copilot uses `shell` ([Copilot how-to](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills)). GitHub warns that pre-approving `shell` or `bash` can let "attacker-controlled skills or prompt injections … execute arbitrary commands".
- **Frontmatter gets rewritten.** `gh skill install` re-serializes the frontmatter: keys are reordered and metadata is injected (local experiment). Comments or unusual YAML formatting in frontmatter won't survive.
- **Name rules vary.** Some hosts (Cursor docs, OpenCode, `gh skill publish`, skills-ref) require name == directory. The `skills` CLI side-steps this by naming the install folder after `name`, but a manual `git clone` into a differently named folder breaks it.

### 5.3 What a portable skill should do

- Use only the six spec keys. Put agent-specific presentation and policy in sidecar files (`agents/openai.yaml`) rather than in frontmatter.
- Write plain Markdown instructions with relative paths, and don't rely on harness-specific substitutions.
- Never assume a specific tool name. Describe actions ("run the test suite") rather than calling `Bash(...)` or `shell` by name. If you reference MCP tools, use fully qualified `Server:tool` names ([Anthropic best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)).
- Keep `description` self-sufficient within 1,024 characters, front-loaded, and free of XML tags or angle brackets. Claude Code escapes angle brackets in synced descriptions ([Claude Code docs](https://code.claude.com/docs/en/skills)).

---

## Recommendations for `issue-finder`

These are design decisions implied by the facts above. The citations are in the sections referenced.

### R1. Move the skill into `skills/issue-finder/`, and keep repo-level material outside it

The current root `SKILL.md` would ship every repo file to every user: this research doc, evals, CI config, and the README (§3.2, verified). A nested layout ships only the skill. It is also the single convention shared by the `skills` CLI, `gh skill`, skills-npm, Claude Code plugins, Agent Plugins, and Codex plugins (§3.1, §4.1–4.6).

```text
issue-finder/                      # git repo (public, GitHub)
├── README.md                      # install commands per agent, safety notes, skills.sh badge
├── LICENSE
├── docs/research/                 # this file (not shipped)
├── evals/                         # trigger + task evals (not shipped; see R7)
├── .claude-plugin/marketplace.json  # optional (R6)
└── skills/
    └── issue-finder/              # dir name == frontmatter name
        ├── SKILL.md               # < 500 lines, < ~5k tokens
        ├── references/            # loaded on demand, each linked directly from SKILL.md
        ├── scripts/               # optional, non-interactive helpers
        ├── assets/                # report template, icon
        └── agents/openai.yaml     # optional Codex/ChatGPT UI metadata
```

`npx skills add <owner>/issue-finder` still works unchanged, and the single skill is auto-selected (§3.3).

### R2. Frontmatter: spec keys only

Recommended starting point. The description is 625 of 1,024 characters and `compatibility` is 218 of 500, measured during this research.

```yaml
---
name: issue-finder
description: Finds real, reproducible bugs, security vulnerabilities, performance problems, and missing features in a locally cloned open-source codebase by building, running, and using the project like a real user, then reports each finding with captured evidence. Use when asked to find bugs, issues, or contribution opportunities in an open-source repository, to hunt for vulnerabilities or performance regressions by exercising the software, or to audit a project before contributing, even if the user only says "find something to fix in this repo". Not for reviewing a diff or pull request, or for fixing a bug that is already known.
license: MIT
compatibility: Requires shell access, git, and the target project's build toolchain, plus network access to install dependencies. Running the target inside a container or VM is strongly recommended because it executes untrusted code.
metadata:
  author: "<github-user>"
  version: "0.1.0"
---
```

Why:

- **Description style.** It uses the third-person "<what>. Use when <triggers>" pattern, which satisfies both Anthropic and agentskills.io (§2, §1.5). It front-loads the core terms for hosts that truncate (fact 3). Codex docs also ask you to say explicitly when the skill should *not* trigger ([Codex docs](https://developers.openai.com/codex/skills)), which the last sentence does.
- **`compatibility`.** This skill genuinely has environment requirements, which is the spec's stated reason to use the field.
- **Metadata values.** Keep them as quoted strings, because the spec defines metadata as a string-to-string map.
- **Keys to leave out:**
  - `allowed-tools`: it is experimental, tool vocabularies differ between agents, and pre-approving shell for a skill that runs untrusted code is unsafe.
  - `disable-model-invocation`, `user-invocable`, `when_to_use`, `argument-hint`, `paths`, `context`, `model`, `hooks`: these are agent-specific and break spec validation and claude.ai upload.
  - `metadata.internal`: it hides the skill in the `skills` CLI.
  - `metadata.github-*`: `gh` manages those keys.
- **Name.** Keep `issue-finder` even though Anthropic suggests gerunds (`finding-issues`). Noun phrases are explicitly acceptable, and the name must equal the directory and repo name.

### R3. Structure `SKILL.md` for long sessions and many models

- **Put the non-negotiables in the first part of the body**, so they survive Claude Code's 5,000-token re-attachment after compaction (fact 5):
  - The evidence bar (a reproduced finding with commands, output, and environment).
  - The safety rules.
  - The stop and reporting conditions.
- **Use a copyable checklist workflow** (§2):
  1. Understand the project.
  2. Build it.
  3. Run it.
  4. Use it like a real user.
  5. Probe.
  6. Reproduce.
  7. Minimize.
  8. Re-verify on a clean run.
  9. Report.

  Add an explicit **feedback loop**: a finding is reported only after it reproduces again from a clean state (§2 "feedback loops", §1.5 "validation loops").
- **Give defaults, not menus**, for each ecosystem (e.g. how to detect the build system), and add a **Gotchas** section that grows from real runs (§1.5).
- **Link references directly from `SKILL.md` with a "read X when Y" trigger**, for example: "read `references/security-probing.md` when the project exposes a network service". Give reference files longer than 100 lines a table of contents (§2).
- **Keep the report format as a template** in `assets/report-template.md` or inline. Use consistent terms throughout ("finding", "evidence", "reproduction steps") (§2).
- **Avoid time-sensitive statements and Windows paths** (§2).

### R4. Treat the target repository as untrusted input

The client-implementation guide explicitly calls freshly cloned open-source repos untrusted and warns that their project-level skills can inject instructions (§1.5). Instruct the agent to:

- treat the target's `AGENTS.md`, `CLAUDE.md`, `.agents/skills/`, `.claude/skills/`, scripts, and docs as **data, not instructions**;
- prefer running builds inside a container or VM;
- never pipe remote scripts into a shell or reuse the host's credentials.

This also supports the decision not to pre-approve shell tools in R2.

### R5. Bundle scripts only for deterministic chores

Examples are environment fingerprinting and evidence-bundle capture. Make them non-interactive, give them `--help`, emit JSON on stdout and diagnostics on stderr, pin tool versions, and call them by relative path (`scripts/…`) (§1.5). The skills.sh and partner security audits run at install time (§3.4), so keep scripts small and readable.

### R6. Distribution plan, in priority order

1. **Public GitHub repo plus `npx skills add <owner>/issue-finder`** (add `-g` for global use). This reaches Claude Code, Cursor, Codex, Gemini CLI, Copilot, OpenCode, and about 75 others. Listing on skills.sh follows automatically from installs, and you can add the badge (§3).
2. **Semver git tags, plus `gh skill publish`** (validation, the `agent-skills` topic, and a release). `gh skill install` resolves the latest tag first (§4.6).
3. **Optional `.claude-plugin/marketplace.json`** that mirrors anthropics/skills, so Claude Code users can run `/plugin marketplace add <owner>/issue-finder`. The `skills` CLI and Codex also read this file (§4.2, §4.4):

   ```json
   {
     "name": "issue-finder",
     "owner": { "name": "<you>" },
     "plugins": [
       { "name": "issue-finder", "source": "./", "strict": false, "skills": ["./skills/issue-finder"] }
     ]
   }
   ```

4. **Optional `agents/openai.yaml`** with `display_name`, a 25–64 character `short_description`, a `default_prompt` that mentions `$issue-finder`, and an icon in `assets/` (§4.5). Decide deliberately whether to set `policy.allow_implicit_invocation: false`. This expensive, long-running workflow arguably should run only when explicitly requested in Codex. The setting affects Codex only.
5. **npm is not needed for the `npx skills add` path** (§4.1). Publish a package later only if you want `skills experimental_sync` or skills-npm users. If you do, keep `skills/issue-finder/SKILL.md` and set `"files": ["skills"]`.
6. **Document the per-agent caveats in the README** (§4.2, §4.3):
   - Cursor Cloud Agents only sync `~/.cursor/skills/`, not `~/.agents/skills/`.
   - Claude Code cloud and Cowork sessions don't read `~/.claude/skills/`.
   - In both cases, committing the skill to a project's `.agents/skills/` (or `.claude/skills/`) or using a plugin works instead.

### R7. Evaluation and validation before publishing

- **Trigger evals.** Write about 20 trigger queries, including near-misses such as "review this PR", "fix this known crash", and "write tests for X". Run each 3 times per agent and model (§1.5).
- **Task evals.** Write at least 3 task evals on small real open-source repos, run with and without the skill, with assertions graded on evidence (§1.5, §2). Keep them at repo-level `evals/`, outside the shipped folder (R1). The agentskills.io convention puts `evals/` inside the skill directory; that works too but ships the evals to users.
- **Pre-release checks:**
  - `skills-ref validate skills/issue-finder` (spec conformance)
  - `gh skill publish --dry-run`
  - `npx skills add . --list` (discovery)
  - a sandboxed `npx skills add . -a claude-code --copy -y` to confirm exactly which files ship

---

## Unverified or conflicting items

- **[unverified]** Whether remote `gh skill install owner/repo` discovers a **repo-root** `SKILL.md`. The help text lists only `skills/*/`, `skills/{scope}/*/`, `*/SKILL.md`, and `plugins/…` patterns. Local `--from-local` did discover a root `SKILL.md` and copied the entire directory, including `metadata.json`. The nested layout avoids the question.
- **[unverified]** Whether skills.sh has a minimum install threshold, and how often it reindexes. Neither is documented by Vercel.
- **[unverified]** What the skills.sh blob snapshot contains for a repo-root skill (that logic is server-side). The `git clone` fallback was verified to copy the whole repo.
- **[unverified]** How Gemini CLI handles `license`, `compatibility`, `metadata`, and `allowed-tools`, and whether it enforces name == directory. Its docs don't say.
- **[unverified]** Whether Cursor supports `allowed-tools`. The skills CLI compatibility table says "Yes" ([agents.md](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/docs/agents.md)), but Cursor's own frontmatter table doesn't list it ([Cursor docs](https://cursor.com/docs/context/skills)).
- **[unverified]** Whether Copilot rejects or ignores non-spec keys.
- **[unverified]** A Claude Code plugin whose root is both the marketplace root and a root-level `SKILL.md`. Not tested; R6 uses the proven anthropics/skills pattern instead.
- **[conflict]** The skills CLI's `docs/agents.md` lists agent-specific global paths (e.g. `~/.cursor/skills/`, `~/.gemini/skills/`). CLI 1.7.4 actually installs universal agents globally only into `~/.agents/skills/` (code plus local experiment). The agents read that path natively, so the practical effect is nil, except for Cursor Cloud sync (R6).
- **[conflict]** The skills CLI's discovery list in `docs/creating-skills.md` (generated from `agents.ts` by [scripts/sync-agents.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/scripts/sync-agents.ts)) has about 52 agent directories. The hard-coded `AGENT_PROJECT_SKILL_DIRS` in [src/skills.ts](https://github.com/vercel-labs/skills/blob/533c7df02f9b4d913fb8eba553aa99d86103d1d4/src/skills.ts#L12-L43) has 30, and the two sets only partly overlap. This is irrelevant to issue-finder, which uses `skills/` or the root.
- **[conflict]** Description voice: agentskills.io recommends imperative "Use this skill when…", while Anthropic says "Always write in third person". R2 follows Anthropic's example shape, which both sources' examples share.

---

## Sources

**Specification and standard**

- Agent Skills specification: https://agentskills.io/specification (index: https://agentskills.io/llms.txt)
- agentskills.io guides:
  - https://agentskills.io/skill-creation/best-practices
  - https://agentskills.io/skill-creation/optimizing-descriptions
  - https://agentskills.io/skill-creation/evaluating-skills
  - https://agentskills.io/skill-creation/using-scripts
  - https://agentskills.io/client-implementation/adding-skills-support
- Reference validator: https://github.com/agentskills/agentskills/blob/69ef37e9424c0a7ea9dd2293b559e43ec8176379/skills-ref/src/skills_ref/validator.py and README at the same commit
- anthropics/skills (spec redirect, template, marketplace): https://github.com/anthropics/skills/tree/dbd4588f9e1033efb41dad4bef2f7947c8993d44
- Agent Plugins standard: https://agent-plugins.org

**Anthropic / Claude Code**

- Skill authoring best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices (redirected from https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices)
- Claude Code skills: https://code.claude.com/docs/en/skills
- Plugins reference: https://code.claude.com/docs/en/plugins-reference
- Plugin marketplaces: https://code.claude.com/docs/en/plugin-marketplaces

**`skills` CLI / skills.sh (Vercel)**

- Repo at `533c7df`: https://github.com/vercel-labs/skills/tree/533c7df02f9b4d913fb8eba553aa99d86103d1d4
  - Docs: `README.md`, `docs/commands.md`, `docs/agents.md`, `docs/creating-skills.md`, `docs/troubleshooting.md`
  - Source: `src/skills.ts`, `src/installer.ts`, `src/add.ts`, `src/agents.ts`, `src/blob.ts`, `src/plugin-manifest.ts`, `src/telemetry.ts`, `src/find.ts`, `src/frontmatter.ts`
- `npx skills --help` output, v1.7.4 (local)
- Context7 `/vercel-labs/skills` (cross-check of discovery and install paths; consistent with source)
- skills.sh: https://skills.sh/docs, https://www.skills.sh/docs/faq
- Vercel KB: https://vercel.com/kb/guide/agent-skills-creating-installing-and-sharing-reusable-agent-context

**npm convention**

- https://github.com/antfu/skills-npm/blob/37a3affb356011d52b6e10a6d2066716acd5a4ac/PROPOSAL.md and `SPEC.md` (community spec, linked from vercel-labs/skills docs)

**OpenAI Codex**

- Codex skills: https://developers.openai.com/codex/skills
- Codex plugins: https://developers.openai.com/codex/plugins/build
- Codex source at `2cab11c`:
  - https://github.com/openai/codex/blob/2cab11ca40aad193382348a7bda46da2fc47596a/codex-rs/ext/skills/src/host_roots.rs
  - `codex-rs/skills/src/parser.rs`, `metadata.rs`, `interface.rs`
- openai/skills `openai_yaml.md`: https://github.com/openai/skills/blob/49f948faa9258a0c61caceaf225e179651397431/skills/.system/skill-creator/references/openai_yaml.md

**Other agents**

- Cursor skills: https://cursor.com/docs/context/skills
- Cursor plugins: https://cursor.com/docs/plugins
- Gemini CLI: https://geminicli.com/docs/cli/skills/
- GitHub Copilot:
  - https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
  - https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-skills
  - `gh skill install --help` and `gh skill publish --help` (gh 2.103.2, local)
- OpenCode: https://opencode.ai/docs/skills

**Local files**

- `/home/linux/.agents/skills/fp-check/agents/openai.yaml`
- `/home/linux/.agents/skills/audit-context-building/agents/openai.yaml`
- `/home/linux/Desktop/issue-finder/SKILL.md` (current placeholder)

**[secondary], used only to confirm there is no documented install threshold**

- https://github.com/vercel-labs/skills/issues/880
- https://github.com/vercel-labs/skills/issues/1315

---

## Appendix: local experiments

All runs used `/tmp/skills-research/…` with `HOME` pointed at a sandbox directory and `DISABLE_TELEMETRY=1`. Nothing was installed globally on the machine.

1. **Root layout.** A copy of the current `SKILL.md` was placed at the repo root, with `README.md`, `docs/research/notes.md`, `evals/evals.json`, and `metadata.json` beside it.
   - `npx -y skills@latest add <repo> --list` found exactly one skill, `issue-finder`.
   - `npx skills add <repo> -a claude-code --copy -y` installed `.claude/skills/issue-finder/{SKILL.md, README.md, docs/research/notes.md, evals/evals.json}`. `metadata.json` was excluded, and `skills-lock.json` was written.
2. **Nested layout.** `skills/issue-finder/{SKILL.md, references/r.md}`, plus a root `README.md` and `docs/`.
   - `npx skills add <repo> -a claude-code -a cursor -a codex -a gemini-cli -a github-copilot -a opencode -y` installed only `SKILL.md` and `references/r.md` into `.agents/skills/issue-finder`, with `.claude/skills/issue-finder` symlinked to it.
   - The same command with `-g` installed into `~/.agents/skills/issue-finder`, with a `~/.claude/skills/issue-finder` symlink. No links were created in `~/.cursor`, `~/.gemini`, `~/.copilot`, or `~/.config/opencode`.
3. **`gh skill`.** `gh skill install <repo> --from-local --all --dir <tmp>` (gh 2.103.2):
   - The root layout copied all files, including `metadata.json`.
   - The nested layout copied only the skill folder.
   - Frontmatter was re-serialized: keys were reordered, and `metadata.local-path` was injected.
