# PR draft template (local only)

```markdown
## Fixes IF-### (link to the local finding record, and to the filed issue if one was published)

### Problem

<One or two sentences, matching the finding's confirmed description, no overstatement.>

### Root cause

<The traced mechanism, file:line, same as the finding record's Gate 4.>

### Fix

<What changed and why this is the smallest change that addresses the root cause. Explicitly note anything NOT changed that might look related but wasn't, to preempt scope-creep questions.>

### Testing

<The validation ladder actually run: which commands, what passed. Include the new regression test's name/path.>

### Compatibility

<Confirmation that public interfaces/schemas/output formats are unchanged, or an explicit, justified note if the verified finding required a documented change to one of them.>
```

## Rules

- This file lives in the local worktree only (e.g. `.issue-finder/drafts/IF-###-pr-draft.md` or directly in the worktree for easy copy-paste); opening the actual PR is a separate, explicitly authorized action.
- Never claim test coverage or validation steps that weren't actually run.
- If an independent review (installed code-review skill or fresh subagent) raised something not yet addressed, either address it or state explicitly in the draft why it wasn't, don't silently drop a review comment.
- Match the target project's own PR template when one exists, mapping these sections onto it rather than ignoring it.
