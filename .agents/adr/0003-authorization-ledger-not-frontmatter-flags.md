> **Superseded in part by [ADR 0004](0004-two-skill-find-then-fix.md).** The `ENGAGEMENT.md` ledger described below is gone. Bounded, reversible git operations (stash, fetch, rebase onto a freshly fetched upstream tip, local branch creation, local commits) are now pre-authorized rather than ledger-gated. Push, opening a public issue, opening a PR, and submitting a security report still default to no, now asked for explicitly in chat at the point each would fire, rather than recorded in a file read later. This page is kept for the reasoning that still applies to those four actions and to the security-sensitive override.

# Authorization lives in `ENGAGEMENT.md`, not in skill frontmatter or chat-turn phrasing alone

The source master prompt for this suite expressed per-action permissions (commit, push, rebase, force-push, open a public issue, open a PR, prepare a private fix, submit a private security report) as prompt-template variables the user filled in once at the start of a conversation. That works for a single long chat, but this suite is designed to survive context compaction, a fresh session days later, and a different harness entirely picking up the same target checkout.

## Decision

Every external-action authorization is recorded as a line in `.issue-finder/ENGAGEMENT.md`, written during `issue-finder`'s Brief phase and read by name before any action it gates: commit, push, rebase, force-push-with-lease, open a public issue, open a PR, submit a private security report. Each one defaults to **no** unless the user explicitly set it to yes for that engagement. `issue-fixer`, run later or in a different session, reads the same file rather than re-asking the user to restate every permission in natural language, and rather than assuming any previous turn's spoken "sure, go ahead" still applies.

The security-sensitive disposition in `verifying-findings` overrides every one of these regardless of what `ENGAGEMENT.md` says, matching the master prompt's own non-negotiable rule that security severity never inherits the ordinary PR/issue authorizations.

## Consequence

A target checkout can be revisited (new session, new harness, new day) and `issue-fixer` still refuses to push or open a PR unless `ENGAGEMENT.md` says so, because the ledger is a file, not conversation memory. Changing an authorization means editing that file or explicitly telling the running agent to update it; it is never inferred from an agent's own judgment that "the user probably meant yes this time too."
