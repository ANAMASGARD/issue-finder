# Changesets

This folder is managed by [`@changesets/cli`](https://github.com/changesets/changesets). Run `npm run changeset` after any user-visible change to a skill's behavior, then `npm run version` to apply it (bumps `package.json` and syncs `.claude-plugin/plugin.json` / `.cursor-plugin/plugin.json` via `scripts/sync-plugin-version.mjs`).

See the [common questions doc](https://github.com/changesets/changesets/blob/main/docs/common-questions.md) for background.
