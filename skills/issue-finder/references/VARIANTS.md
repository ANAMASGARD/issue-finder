# Variant search

After a candidate is confirmed and ranked, check whether its root cause has siblings elsewhere in the codebase, one property at a time, before drafting.

1. **Build an exact query** that reliably finds the original instance: the specific function/type/pattern, not a vague keyword. A grep, an AST-aware search, or a Semgrep rule generalized from the confirmed instance (see `OPTIONAL-SKILLS.md`) all work; confirm it actually surfaces the known instance before trusting it on the rest of the codebase.
2. **Generalize one dimension at a time**: the same function called from a different site, the same pattern in a sibling language binding, the same missing check on a neighboring endpoint, the same unguarded call in a different package.
3. **Inspect every result** the query returns; a result with a different root cause sharing surface similarity is not a variant. Stop widening the query once noise outweighs signal.
4. **Verify each variant independently** through the same `verifying-findings` gates. A variant that merely looks similar but doesn't reproduce is not reported.
5. **Give each confirmed variant its own candidate row and its own disposition.** Never bundle unrelated variants into the first candidate's record; a maintainer reviewing one fix should not have to untangle three bugs from one description.

Record "variant search: none found" explicitly when the query ran and turned up nothing, so the final report shows this step happened rather than being silently skipped.
