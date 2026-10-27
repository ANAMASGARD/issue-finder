# Validation ladder

Run in order; don't skip a rung because an earlier one passed.

1. **The new regression test, against the unchanged baseline.** Confirm it fails, and that it fails for the reason you expect (read the failure output, don't just check the exit code), before writing any fix.
2. **The new regression test, against the fix.** Confirm it now passes.
3. **The original minimal reproduction from the finding's record.** Confirm it no longer fails.
4. **Affected-package tests.** The full test suite for whatever package/module/crate the change touched.
5. **The relevant repository-wide checks**: full test suite, lint, formatter (check, don't auto-apply unless that's the project's own convention), type checks, static analysis, race-detector run if the language/runtime supports one and the fix touches concurrency.
6. **For a performance fix**: repeat the controlled benchmark (not a single run) and report variance, following `verifying-findings/references/PERFORMANCE-EVIDENCE.md`'s procedure, so the "fixed" claim has the same evidentiary bar as the original finding did.
7. **For cross-repository or cross-package behavior**: verify both the producer and consumer side of the contract still agree, and document the required release order if one side needs to ship first.
8. **Inspect the final diff, `git status`, and any generated/untracked files.** Confirm nothing unintended got swept in.
9. **Confirm public interfaces, schemas, output formats, and compatibility remain unchanged**, unless the verified finding specifically required a documented, intentional change to one of them.

Do not weaken step 1's test to make step 2 pass. Do not replace the real failing boundary with a mock unless the real one is genuinely unavailable in this sandbox, and that limitation is stated explicitly in the PR draft.
