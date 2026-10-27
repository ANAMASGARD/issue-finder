# Issue Finder glossary

The shared vocabulary across all six skills and their docs. A term defined here should be used consistently, not reworded per skill.

**Engagement**:
One `/issue-finder` run against one target checkout, scoped and bounded by `ENGAGEMENT.md` in that checkout's `.issue-finder/` workspace. Carries the authorization ledger (what external actions, if any, are allowed) and the investigation budget.
_Avoid_: session (ambiguous with a chat session), audit (implies a compliance deliverable this isn't).

**Lead**:
An observation from `exploratory-testing` that behavior might be wrong: a surprise judged against a named oracle. Not yet a **finding**. Most leads die during verification.
_Avoid_: bug (too early), issue (reserved for a tracker artifact).

**Candidate**:
A lead under active investigation by `verifying-findings`, tracked as one row in `candidates.md` with an ID like `IF-003`. A candidate ends in exactly one **disposition**.

**Disposition**:
The single verdict a candidate ends in: Confirmed and actionable, Confirmed but already reported, Already fixed upstream, Enhancement requiring maintainer discussion, Needs additional runtime validation, Rejected hypothesis, or Security-sensitive: private handling required. See `skills/verifying-findings/SKILL.md`.

**Finding**:
A candidate with the disposition Confirmed and actionable (or the security-sensitive equivalent). The only kind of candidate that reaches `drafting-issues`.

**Oracle**:
The specific, named reason a behavior is judged wrong, not just surprising, drawn from FEW HICCUPPS (familiarity, explainability, world, history, image, comparable products, claims, user's desires, product, purpose, statutes/standards). Every lead cites one. See `skills/exploratory-testing/references/ORACLES.md`.

**Journey**:
One chartered exploration of the target, scoped to a persona and a tour, recorded in `journeys.md` as pass, fail, partial, or blocked. The unit of work inside `exploratory-testing`.

**Draft**:
The maintainer-ready artifact `drafting-issues` writes for a finding: a bug report, a feature request, or (for security-sensitive findings) a private advisory. Lives under `.issue-finder/drafts/` or `.issue-finder/private/`. Never published without separate, explicit authorization.

**Proof boundary**:
An explicit statement of what a piece of evidence does and does not establish (a passing unit test proves its exercised function, not the hosted CI pipeline). Every candidate record states its proof boundaries. See `skills/verifying-findings/references/PROOF-BOUNDARIES.md`.

**Grounding**:
The step where `issue-finder` records the target's exact repository state, its available capabilities (toolchains, network, sandbox), and reads the target's own instruction files as data. See `skills/issue-finder/references/GROUNDING.md`.

## Relationships

- An **engagement** investigates many **leads**.
- A **lead** that enters verification becomes a **candidate**.
- A **candidate** ends in exactly one **disposition**.
- A candidate with a Confirmed disposition is a **finding**.
- A **finding** produces exactly one **draft**.
