# The canonical install block

One wording, copied verbatim into `README.md`. Change it here first, then propagate.

## Claude Code, Codex, GitHub Copilot (CLI and VS Code)

<canonical-block name="claude-plugin-agents">

```bash
claude plugin marketplace add ANAMASGARD/issue-finder
claude plugin install issue-finder@anamasgard
```

Codex and Copilot CLI read the same `.claude-plugin/` manifests:

```bash
codex plugin marketplace add ANAMASGARD/issue-finder
codex plugin add issue-finder@anamasgard
```

```bash
copilot plugin marketplace add ANAMASGARD/issue-finder
copilot plugin install issue-finder@anamasgard
```

</canonical-block>

## Cursor

<canonical-block name="cursor-plugin">

Open the Command Palette and run **Plugins: Add Marketplace**, then paste `https://github.com/ANAMASGARD/issue-finder`. Or, from a terminal in the project:

```bash
npx skills@latest add ANAMASGARD/issue-finder --skill '*' -a cursor
```

</canonical-block>

## Gemini CLI

<canonical-block name="gemini">

```bash
gemini skills install https://github.com/ANAMASGARD/issue-finder.git --path skills
```

Re-run to update; Gemini does not auto-update skills.

</canonical-block>

## Any other agent, or editable files

<canonical-block name="other-agents">

```bash
npx skills@latest add ANAMASGARD/issue-finder -a <agent>  # cursor, opencode, windsurf, devin, amp; omit -a to choose
```

When the installer asks which skills to take, choose all six: `issue-finder`, `exploratory-testing`, `verifying-findings`, `screening-duplicates`, `drafting-issues`, `issue-fixer`. Installing only `issue-finder` leaves it unable to call its companions. To update, run `npx skills@latest update`, and re-run `add` to pick up new skills.

</canonical-block>

## Single-skill install

<canonical-block name="single-skill">

```bash
npx skills@latest add ANAMASGARD/issue-finder --skill issue-finder --skill exploratory-testing --skill verifying-findings --skill screening-duplicates --skill drafting-issues
```

Omit `issue-fixer` only if you never want this suite touching source code, even on request.

</canonical-block>
