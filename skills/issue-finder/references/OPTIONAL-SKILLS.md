# Routing to optional companion tools

This suite never assumes any of the following are installed. Check the harness's available skills/tools at the start of Phase 2 and record what's present in `capabilities.md`. A missing tool is a stated testing boundary, never a reason to fabricate a result the tool would have produced.

| If installed | Use it for | Never for |
| --- | --- | --- |
| A Semgrep-running skill | A first-pass pattern search feeding leads into Phase 5, and generalizing a confirmed finding into a variant-search query (`VARIANTS.md`) | Reporting a raw hit as a finding; it still goes through `verifying-findings` in full |
| A CodeQL-running skill | Interprocedural taint tracking for a specific confirmed source/sink hypothesis, when a build and database are available | Initial discovery without a hypothesis already in hand |
| A false-positive-verification skill | A second, independent pass confirming a security candidate's reachability before it reaches "Confirmed and actionable" | Initial bug hunting; it verifies a claim you already have |
| A variant-analysis skill | The mechanics of `VARIANTS.md`, if a more capable implementation exists in this harness | Skipping the manual variant search when it's not installed |
| Browser automation (Playwright/Puppeteer MCP, or similar) | Driving a web UI target in `exploratory-testing` | Headless-only verification of something that needs real user interaction (file pickers, OS permission dialogs) |
| Context7 or another live-docs tool | Checking the target's declared library/framework's real current API when a lead hinges on "is this a documented behavior or a bug," so the expected-behavior claim is version-correct | Business-logic debugging unrelated to a library's own contract |
| A systematic-debugging or diagnosing-bugs skill | The feedback-loop discipline (build a red-capable repro, minimize, instrument) inside `verifying-findings`'s reproduction step, if a more detailed implementation exists in this harness | Replacing `verifying-findings`'s disposition and evidence-gate requirements |
| A TDD skill | Writing the regression test in `issue-fixer`, if invoked later | Anything inside `issue-finder` itself, which never writes source |
| A code-review skill | `issue-fixer`'s independent review step before the PR draft | Reviewing `issue-finder`'s own output, which isn't a diff |

If the user has authorized a specific static-analysis engine, mode, and exact ruleset in `ENGAGEMENT.md` notes, honor exactly that scope; running a broader scan than authorized is out of bounds even if the tool supports it.
