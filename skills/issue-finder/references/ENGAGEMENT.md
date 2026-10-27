# `ENGAGEMENT.md` template

Write this to `.issue-finder/ENGAGEMENT.md` at the start of Phase 1. Fill every field; don't leave an authorization blank. `issue-fixer` and every other skill in this suite read this file by name before any gated action, in a session that may be days later or in a different harness.

```markdown
# Engagement: <target repo name>

- **Started:** <date>
- **Target:** <owner/repo or local path>
- **Local workspace:** <absolute path to the checkout>
- **Scope mode:** single-repository | organization
- **Primary focus:** <component or journey, or "infer from risk and user impact">
- **Investigation budget:** <default 3 for one repo, 6-10 for an organization>

## Authorizations (default NO unless stated otherwise by the user)

- Local investigation and isolated testing: YES (always true for this suite)
- Create an issue-specific local branch after a finding is confirmed: <YES/NO>
- Create local source changes and regression tests after confirmation: <YES/NO>
- Commit changes: <YES/NO>
- Push branches: <YES/NO>
- Rebase or otherwise rewrite existing branch history: <YES/NO>
- Force-push with lease: <YES/NO>
- Create public GitHub/GitLab issues: <YES/NO>
- Create pull requests: <YES/NO>
- Prepare a private local fix for a security-sensitive finding: <YES/NO>
- Submit a private security report on the maintainers' channel: <YES/NO>

## Notes

<Anything else the user said that constrains this engagement: a component to avoid,
a time budget, a known-flaky test to ignore, a semgrep ruleset authorization, etc.>
```

A security-sensitive disposition overrides every authorization above regardless of what it says (non-negotiable 5 in `SKILL.md`); don't add a workaround field for that.
