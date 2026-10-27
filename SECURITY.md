# Security policy

This file covers two different things. Read the right section.

## Reporting a vulnerability in Issue Finder itself

If you find a vulnerability in this repository's own skill files or scripts (for example, a script that could be tricked into running attacker-controlled commands), please use GitHub's private vulnerability reporting: open the **Security** tab on this repository and select **Report a vulnerability**, rather than filing a public issue. See [GitHub's documentation on privately reporting a security vulnerability](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability).

## When Issue Finder finds a vulnerability in a *target* project

This is the more common case, and it is handled entirely inside the skill, not this file. When a lead's impact involves unauthorized access, data exposure, or privilege escalation, `issue-finder` treats it as security-sensitive:

- `scripts/sync-and-branch.sh` creates `.issue-finder/private/` at directory mode `0700` up front, before any hunting starts. The finding's full reproduction, root cause, and impact are written only there.
- The scorecard and `REPORT.md` show only "Security finding (details in private/)" with its confidence and priority, never a description, a code snippet, or a reproduction step, regardless of what's authorized for ordinary findings.
- Nothing is submitted anywhere (no GitHub private advisory, no email to a security contact) without you explicitly authorizing that specific action in chat, at that exact point.
- `issue-fixer` will prepare a local patch for a security-sensitive finding only if you authorize local branch and source changes for it specifically, and it never opens a public PR for one; the patch is handed back for private coordination instead.
- The agent never uses production systems, real user data, destructive payloads, or denial-of-service techniques to demonstrate the issue, and never persists access.

If you decide to submit the finding, the target project's own `SECURITY.md` is the authority on how. Most GitHub-hosted projects accept reports through **Security → Report a vulnerability**, which opens a private advisory thread with maintainers (see the GitHub docs link above). Projects without a `SECURITY.md` and without GitHub private reporting enabled should be treated as not having a documented channel; say so explicitly rather than guessing at a contact.
