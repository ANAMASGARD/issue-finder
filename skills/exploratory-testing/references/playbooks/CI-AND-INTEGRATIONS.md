# Playbook: CI actions, bots, and third-party integrations

- For a reusable CI action/workflow: run it in a real (disposable, forked) repository with varied caller inputs, not just the one example in its own README; check what happens with a missing optional input, an input of the wrong type, and a permission scope narrower than the action expects.
- Check artifact names, paths, and permissions produced by one job against what a documented downstream job expects to consume; a mismatch here is a cross-component-contract lead (`HUNTING-LANES.md` lane 3).
- For a bot or chat integration (Slack, Discord, GitHub App, etc.): test webhook signature verification directly (a request with a missing/invalid signature must be rejected), replay of a previously-delivered payload (idempotency), and duplicate-delivery handling.
- Test rate limits and partial failures: what happens when the integration's own API returns a 429 or a 5xx mid-operation; does the bot retry, drop the message, or double-post it?
- Test scope/permission boundaries: does the integration request only the permissions it documents needing, and does it actually fail gracefully (not crash) if a broader action is attempted without the right scope?
- Test threading/channel behavior explicitly if documented: does a reply land in the right thread, does an edited source message update a posted one, does a deleted source message get reflected?
