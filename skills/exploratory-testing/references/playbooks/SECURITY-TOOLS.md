# Playbook: scanners and security tools (the target itself is a scanner)

When the project under test is itself a security/static-analysis tool (a linter, SAST scanner, SBOM generator, policy engine), its own false positives and false negatives are the product's core correctness claim, and need the same evidence discipline as any other bug.

- Build a small, known-answer fixture set: code with a known, deliberately-introduced issue the tool claims to detect, and clean code it should pass. Run the tool against both and check for false negatives (missed the known issue) and false positives (flagged clean code).
- Check the tool's own documented detection claims against its actual ruleset/signature list; a documented check that has no corresponding rule is a Claims-oracle lead.
- Check output format claims directly: if it claims SARIF output, validate the output against the SARIF schema, not just "it produced some JSON."
- Check exit codes against documented CI-integration behavior: does it exit non-zero exactly when documented (e.g., "on any high-severity finding"), and zero otherwise?
- Test against a large real-world codebase (not just the toy fixture) for performance and for crash/hang behavior on messy real input, which is where the most realistic false negatives tend to surface.
- Never let a static-analysis tool's own output short-circuit this suite's own evidence gates: a scanner's "detected" result is a lead, not a finding, until `verifying-findings` reproduces it directly on the target it was run against (see `.out-of-scope/scanner-only-mode.md`).
