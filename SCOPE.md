# Scope

Issue Finder is a small, curated suite: six skills, each with one clear job in the hunt-verify-report pipeline. Every change is judged against the bar below.

## The bar

A change or proposal stays in scope only if it clears **both** parts:

1. **Evidence-driven.** It either closes a gap a real run surfaced (a false positive the verification gate let through, a phase that produced no checkable completion criterion, a project type the playbooks don't cover) or it tightens an existing gate. A proposal to relax a gate because it "feels too strict" does not clear this part without a concrete run where the gate produced a wrong outcome.
2. **Fits the philosophy.** It does not match anything in [`.out-of-scope/`](.out-of-scope/), and it does not weaken a safety invariant in `AGENTS.md` without a new ADR under `.agents/adr/` that records the tradeoff explicitly.

## By skill

- `issue-finder`, `issue-fixer`: the bar above, full strictness, since these are the user-invoked entry points everyone depends on.
- `exploratory-testing`, `verifying-findings`, `screening-duplicates`, `drafting-issues`: same bar. A new project-type playbook under `exploratory-testing/` is welcome when it is grounded in that project type's own real conventions (its own docs, its own test tooling), not a generic guess.

## Already decided

Each file in [`.out-of-scope/`](.out-of-scope/) records one rejected direction and why:

- [`auto-publishing.md`](.out-of-scope/auto-publishing.md)
- [`finding-quotas.md`](.out-of-scope/finding-quotas.md)
- [`scanner-only-mode.md`](.out-of-scope/scanner-only-mode.md)

## New skills

This suite is deliberately six skills. A behavior that composes from the existing six (a new verification heuristic, a new oracle, a new hunting lane) belongs inside one of them, not as a seventh skill. Forking the repo on skills.sh is the right move for a workflow specific to one person's stack.
