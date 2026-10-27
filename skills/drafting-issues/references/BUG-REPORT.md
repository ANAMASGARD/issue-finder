# Bug report template

```markdown
## Description

<One or two sentences: the supported user action, the exact wrong result, and why it matters.>

## Environment

- Component/package: <name>
- Version / commit SHA: <exact>
- OS / runtime: <exact>
- Installation source: <source build | release artifact | package manager>
- Relevant configuration: <only what's relevant>

## Steps to reproduce

1. <minimal, copyable command or action, from a clean checkout>
2. <next step>
3. <...>

## Expected behavior

<What should happen, citing the doc/spec/comment that says so.>

## Actual behavior

<Exact output, exit code, or malformed result. Redacted.>

\`\`\`
<verbatim captured output, secrets redacted>
\`\`\`

## Cause

<Only if actually traced and verified: file:line and mechanism. Omit this section entirely if not confidently known, rather than guessing.>

## Impact and affected scope

<Who/what is affected, based only on what was demonstrated. State explicitly what wasn't tested.>

## Additional context

<Links to related (non-duplicate) reports found during screening, if any.>
```

Rules for filling this in:

- No section states something as fact unless it was actually verified; use "not verified: ..." explicitly for anything else.
- Never include a suggested fix in the Description or title. A separate, clearly labeled "Possible direction" note after Impact is fine if the user wants it, but it's optional and never the lead.
- If the target repo has its own issue template/form, map these sections onto it rather than ignoring it; only fall back to this template wholesale when none exists.
