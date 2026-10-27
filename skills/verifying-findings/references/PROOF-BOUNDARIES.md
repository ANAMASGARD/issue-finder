# Proof boundaries

A proof boundary is an honest statement of exactly what was and wasn't demonstrated. State it in two parts:

- **Tested:** the exact commands/requests run, the exact environment (OS, runtime version, config), and the exact input that triggers it.
- **Not tested:** every adjacent thing you did *not* check: other platforms, other configurations, other input shapes that might also trigger it, and whether it holds on other supported versions.

## Rationalizations to reject

Every one of these has shown up repeatedly across independently-built verification skills. Name the rationalization out loud when you catch yourself making it, then take the listed corrective action instead.

| Rationalization | Why it's wrong | Correct action |
| --- | --- | --- |
| "This is clearly critical." | Models are biased toward seeing bugs and overrating severity. | Run the full devil's-advocate pass; severity follows demonstrated impact only. |
| "It's obviously reachable, I don't need to check." | Reachability is often wrong in practice (feature flags, config gates, auth walls). | Actually trace a real caller or trigger; don't assume. |
| "I'm confident it reproduces, I don't need to run it twice." | A single run can't distinguish a real bug from a fluke, bad baseline, or stale cache. | Run it twice on a pinned baseline, exactly as Gate 3 requires. |
| "The theoretical worst case is bad, so I'll report that severity." | Overclaiming severity on unobserved worst-case impact destroys report credibility. | Report only what you demonstrated; note the theoretical ceiling separately if relevant, clearly labeled as unverified. |
| "It's a small change, probably low risk." | Severity correlates with impact, not with diff size; tiny changes have caused critical vulnerabilities. | Classify by actual demonstrated risk, never by how much code was touched. |
| "No artifact, I'll just describe it in chat." | A finding that isn't written to a file is a finding that gets lost at compaction or session end. | Always write the record to `findings/IF-###-<slug>/record.md`; chat-only output doesn't count as done. |
| "It's probably already fixed, I won't bother checking." | Skipping the fresh-baseline recheck produces false "Confirmed" reports that are actually `Already fixed upstream`. | Always re-run the minimal repro against the current upstream default branch before finalizing a disposition. |
| "I already found three bugs here, this must be a bad file." | Familiarity bias inflates confidence without new evidence. | Apply the same six gates to every candidate regardless of how many related ones already confirmed. |
