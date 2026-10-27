# Auto-publishing a confirmed finding

Rejected direction: once `verifying-findings` reaches "Confirmed and actionable" and the score clears the ranking bar, automatically open the public issue or PR.

## Why this is out of scope

A confirmed, well-scored finding is still the agent's own judgment about someone else's project. Maintainers differ wildly in what they want from an automated report, whether they accept AI-assisted contributions at all, and how they want a security-sensitive finding routed. `drafting-issues` already reads the target's own CONTRIBUTING file, issue templates, and AI-contribution policy before writing a draft; folding publication into the same automatic step removes the one checkpoint where a human confirms the draft actually reads well, names the right severity, and doesn't leak something the redaction pass missed.

This is also why `ENGAGEMENT.md`'s authorization for "create public GitHub issues" and "create pull requests" each default to no and are asked for as separate, explicit grants, never bundled into "I authorize the hunt."
