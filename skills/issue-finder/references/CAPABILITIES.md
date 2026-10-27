# `capabilities.md` fields

Inventory what's actually usable in this environment, and record what isn't as a named testing boundary rather than a silent gap:

- Language toolchains and exact versions (`node --version`, `python3 --version`, `go version`, etc., whichever the target needs).
- Package manager and network access (can dependencies actually be installed?).
- Containers available (`docker info` / `podman info`), and whether a VM or disposable cloud sandbox is reachable instead.
- Browser automation available (a Playwright/Puppeteer-capable environment, or an MCP browser tool) for web UI targets.
- Static analysis engines available: Semgrep, CodeQL, language-native linters, dependency-audit tools. Record exact versions; a tool "being available" at all is not the same as having rules suited to this target's language.
- Cloud/provider credentials and safe test accounts, only if the user has explicitly provided and scoped them for this engagement. Default to assuming none.
- Optional companion skills installed in this harness; see [OPTIONAL-SKILLS.md](OPTIONAL-SKILLS.md) for the routing table.
- **Sandbox choice for executing target code**, and why (see `GROUNDING.md`).

A capability marked unavailable here is something `verifying-findings` must cite later as a stated proof boundary whenever a candidate's verification would have needed it (e.g. "not tested under real Kubernetes networking; only a local mock was available").
