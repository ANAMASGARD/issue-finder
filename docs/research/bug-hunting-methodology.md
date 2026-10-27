# Bug-Hunting Methodology: Primary-Source Research

Research compiled to ground the "Issue Finder" agent skill in authoritative, citable methodology rather than folklore. Every claim below is tied to a primary or canonical source with a URL and a direct quote or close paraphrase, so each fact can be independently re-verified. Anything I could not pin to a primary source is explicitly marked `[unverified]`.

Compiled: 2026-10-27.

---

## 1. Exploratory testing structure

### 1.1 Heuristic Test Strategy Model (HTSM) and SFDIPOT

**Source:** James Bach, *Heuristic Test Strategy Model*, v6.3 (Satisfice, Inc., published/updated 2 December 2024). PDF: https://www.satisfice.com/download/heuristic-test-strategy-model (direct file: `https://www.satisfice.com/download/heuristic-test-strategy-model?filename=1587412934wpdm_htsm.pdf&wpdmdl=13`)

The HTSM is explicitly a strategy-design checklist, not a procedure to execute verbatim:

> "The Heuristic Test Strategy Model is a set of patterns for designing and choosing tests to perform. The immediate purpose of this model is to remind testers of what to think about during that process." (p.1)

It has four top-level focus areas: **Project Environment**, **Product Factors** (= SFDIPOT), **Quality Criteria Categories**, and **General Test Techniques**, feeding into "The Testing and Quality Story" — i.e., you cannot "verify" quality, only assemble evidence and tell a defensible story about it (p.1).

**SFDIPOT** is the "Product Factors" guideword list inside HTSM — pronounced "San Francisco Depot." Verbatim definitions from the HTSM v6.3 PDF (p.4):

| Letter | Element | What it covers (quoted/paraphrased from HTSM) |
|---|---|---|
| **S** | **Structure** | "Everything that constitutes the physical product": code (executables down to individual routines), hardware, services/servers, non-executable files, and "collateral" (docs, web pages, packaging, license agreements). |
| **F** | **Function** | "Everything that the product does": business rules (input constraints, conditional behavior, boundaries), multi-user/social/concurrency, calculations, security (rights, data protection, encryption), transformations, state transitions, multimedia, error handling, inter-function interactions, and built-in testability features (diagnostics, logs, asserts). |
| **D** | **Data** | "Everything that the product processes and produces": input/output, preset/default data, persistent data, interdependent data, sequences/combinations, cardinality (zero/one/many/max), big/little size variation, invalid/noise/corrupted data, and data lifecycle (create/access/modify/delete). |
| **I** | **Interfaces** | "Every conduit by which the product is accessed or expressed": user interfaces, system interfaces (disk, network, other programs), API/SDK, and import/export. |
| **P** | **Platform** | "Everything on which the product depends (and that is outside your project)": external hardware/software dependencies, embedded third-party components, and "product footprint" — resources consumed (memory, file handles). |
| **O** | **Operations** | "Every experience people could have with the product": user classes, physical environment, common/uncommon/extreme use, and "disfavored use" (ignorant, mistaken, careless, or malicious use). |
| **T** | **Time** | "Any relationship between the product and time": time-related data (timeouts, time zones, warranty periods), I/O timing relationships, pacing (fast/slow input, spikes, bursts, hangs), and concurrency. |

**Provenance of the mnemonic** (secondary-but-direct account by co-creator Michael Bolton, corroborating the HTSM's own claim): originally "SFDPO" (Structure, Function, Data, Platform, Operations); Bolton persuaded Bach to add **Time**, making it SFDIPOT. Source: https://developsense.com/blog/2014/07/how-models-change — "James Bach wrote an article on product elements, identifying Structure, Function, Data, Platform, and Operations (SFDPO) ... I missed a few test ideas ... had I thought of 'Time' as another guideword."

**Actionable procedure for an agent:** When first exploring an unfamiliar repo, walk SFDIPOT as a coverage checklist before writing any test or filing any issue:
1. **Structure** — inventory the codebase: entry points, binaries/services, build artifacts, non-code collateral (README, docs, packaging/install scripts).
2. **Function** — enumerate business rules, input validation, security-sensitive code paths, state machines, error-handling paths.
3. **Data** — identify input/output formats, default/seed data, persisted state, data lifecycle (create/update/delete), and boundary/invalid-data handling.
4. **Interfaces** — list every way the product is driven: CLI, HTTP API, GUI, library/API surface, import/export formats.
5. **Platform** — note OS/runtime/dependency versions, external services, resource limits (memory, file descriptors, disk).
6. **Operations** — consider who uses this (admin vs. normal user), common vs. rare vs. hostile usage patterns.
7. **Time** — consider timeouts, time zones, race conditions, concurrency, and fast/slow/bursty input.

Each dimension is a prompt to generate test ideas and hypotheses about where a real bug might live — not a form to fill in mechanically.

### 1.2 Session-Based Test Management (SBTM)

**Source:** Jonathan Bach, *Session-Based Test Management*, first published in *Software Testing and Quality Engineering* magazine, Nov. 2000; republished by Satisfice: https://www.satisfice.us/articles/sbtm.pdf (and index page https://www.satisfice.com/download/session-based-test-management, "written by my brother Jon and I based on the process we pioneered at Hewlett-Packard").

Core definitions, quoted directly:

> "In our practice of exploratory testing, a session, not a test case or bug report, is the basic testing work unit. What we call a session is an uninterrupted block of reviewable, chartered test effort. By 'chartered,' we mean that each session is associated with a mission ... By 'uninterrupted,' we mean no significant interruptions, no email, meetings, chatting or telephone calls. By 'reviewable,' we mean a report, called a session sheet, is produced that can be examined by a third-party."

- **Session length:** "In my team, sessions last 90 minutes, give or take ... If a session lasts closer to 45 minutes, we call it a short session. If it lasts closer to two hours, we call it a long session." Expect no more than ~3 sessions/day given overhead.
- **Charter template** (from Elisabeth Hendrickson, cited via SSW.Rules summarizing Bach's practice: https://www.ssw.com.au/rules/manage-report-exploratory-testing): `Explore (target) with (resources) to discover (information)`.
- **TBS task breakdown** — every session's time is self-reported across three buckets (satisfice.us/articles/sbtm.pdf):
  - **T**est design and execution — "scanning the product and looking for problems."
  - **B**ug investigation and reporting — "what happens once the tester stumbles into behavior that looks like it might be a problem."
  - **S**ession **s**etup — "anything else testers do that makes the first two tasks possible ... configuring equipment, locating materials, reading manuals, or writing a session report."
- **Session sheet sections** (verbatim list from the article): Session charter (mission + areas), Tester name(s), Date/time started, Task breakdown (TBS metrics), Data files, Test notes, Issues, Bugs.
- **On-charter vs. opportunity:** testers report % of time on-charter vs. following an unplanned lead; it's explicitly fine to "divert from their charter if they stumble into an off-charter problem that looks important."
- **Debrief agenda ("PROOF"):** Past (what happened), Results (what was achieved), Obstacles (what got in the way), Outlook (what's left to do), Feelings (how the tester feels about it).

**Actionable procedure for an agent:**
1. Before exploring, write a one-to-two-sentence charter: `Explore <target area> with <technique/data> to discover <risk/information>`.
2. Time-box the exploration (treat ~60–90 minutes of focused, uninterrupted investigation as one "session").
3. At the end of the session, produce a session-sheet-style artifact: charter, what was tested, time spent on (test execution vs. bug investigation vs. setup), any bugs found, any open issues/questions, and free-form notes — this becomes the evidentiary trail behind a reported bug.
4. If an interesting off-charter signal appears, it's legitimate to follow it, but note the deviation explicitly in the session notes.

### 1.3 Exploratory testing "tours" (Whittaker)

**Primary source for the concept itself:** James Whittaker, *An Ingredients List for Testing – Part Five*, Google Testing Blog, 1 Oct 2010: https://testing.googleblog.com/2010/10/ingredients-list-for-testing-part-five.html — written by Whittaker himself while leading testing at Google:

> "'Tours' are the metaphor we use at Google to name and describe testing techniques. Every tour encapsulates past testing knowledge ... It's a way to identify and store tribal knowledge of the overall team."

**Primary source for FedEx Tour in practice:** Google Testing Blog, *The FedEx Tour*, 20 Oct 2009 (guest post by Rajat Dewan, crediting Whittaker): https://testing.googleblog.com/2009/10/fedex-tour.html — "the FedEx tour talks about tracking the movement of data and how it gets consumed and transformed by the system."

**Primary source for the full named list of tours:** the publisher's (Pearson/InformIT) table of contents for Whittaker's book *Exploratory Software Testing: Tips, Tricks, Tours, and Techniques to Guide Test Design* (Addison-Wesley, 2009): https://www.informit.com/store/exploratory-software-testing-tips-tricks-tours-and-9780132651226 — chapter 5 lists, verbatim as section headings: The Money Tour, The Landmark Tour, The Intellectual Tour, The Back Alley Tour, The Obsessive-Compulsive Tour, The All-Nighter Tour, The Saboteur, The Collector's Tour, The Supermodel Tour, The Supporting Actor Tour, The Rained-Out Tour, The Tour-Crasher Tour; chapter 6 adds The FedEx Tour, The Garbage Collector's Tour, and The TOGOF Tour; a related library ToC (https://www.gbv.de/dms/ilmenau/toc/601955692.PDF) corroborates this chapter structure ("Tours of the Business District," "Tours Through the Historical District," etc. as chapter groupings).

`[unverified]` — I could not access the book's full text directly (it is not freely hosted), so the one-line *descriptions* of each tour below (beyond FedEx/Landmark, which are corroborated by Whittaker's own Google Testing Blog posts above) are paraphrased from a secondary summary rather than the book itself: test-able.blogspot.com, "Web Testing Exploratory Tours" (Nov 2013), http://test-able.blogspot.com/2013/11/web-testing-exploratory-tours.html. Treat the *names* and *chapter grouping* as primary-sourced (InformIT ToC) and the *descriptions* as secondary-sourced; they are, however, internally consistent with the TechTarget summary (https://www.techtarget.com/it-infrastructure/tip/Six-tours-for-exploratory-testing-the-business-district-of-your-application) of the same book.

| Tour | What it targets (paraphrased; see provenance note above) |
|---|---|
| **Guidebook Tour** | Follow the product's own documentation/user manual/demo script step by step, as a tourist follows a guidebook, looking for places where reality diverges from the docs. |
| **Money Tour** | Run through the features a salesperson would demo — the "money" features that sell the product — looking for problems in the most customer-visible paths. |
| **Landmark Tour** *(Google-confirmed)* | Pick a set of key features ("landmarks") and visit them in varied orders/paths; bugs often hide in order-dependent behavior ("do x before y instead of vice-versa"). |
| **Intellectual Tour** | Act like a skeptic asking the hardest questions: most complex function, maximum field/file sizes, most complex queries, power-user paths — stress the limits. |
| **FedEx Tour** *(Google-confirmed)* | Pick a piece of data and track it end-to-end through the system — where it's created, transformed, stored, displayed — the way a package is tracked in transit. |
| **Garbage Collector's Tour** | A fast, shallow spot-check across every screen/dialog in the shortest path, not stopping for depth — checking the obvious things everywhere. |
| **Bad Neighborhood Tour** | Revisit areas with a history of bugs; bugs cluster, so retest around known-buggy code after a fix lands. |
| **Museum Tour** | Target old/legacy code paths that are rarely revisited, poorly documented, and often undertested by unit tests written only for new code. |
| **Back Alley Tour** | Test the least-used, least-visible features — ones at the bottom of usage/coverage reports. |
| **All-Nighter Tour** | Leave the application running under continuous load without the normal clean restart/reset, to find bugs from accumulated state, leaked resources, or long-running sessions. |
| **Supermodel Tour** | Focus purely on the interface's look and rendering correctness, not functional correctness — does it render, refresh, and resize properly? |
| **Saboteur Tour** | Deliberately try to break the product through malicious or adversarial actions. |
| **Collector's Tour** | Collect "souvenirs" — treat each discovered bug as a trophy and use the bug list itself to guide further exploration. |
| **Obsessive-Compulsive / Supporting Actor / Rained-Out / Tour-Crasher / TOGOF Tours** | Named in the book's ToC; `[unverified]` precise definitions — I could not find a primary or reliable secondary description for these specific tours and will not guess at their meaning. |

**Actionable procedure for an agent:** Treat tours as pre-built "personas"/lenses to run in sequence over a codebase you don't know, to get fast, varied coverage without manually designing test cases:
1. Run a **Guidebook Tour**: follow the README/quickstart/docs verbatim as a brand-new user would, noting every place behavior doesn't match what's documented.
2. Run a **Landmark Tour**: identify 5–10 key features/commands and exercise them in multiple orders, not just the documented happy-path order.
3. Run an **Intellectual Tour**: push every size/length/complexity limit you can find (max input size, deeply nested structures, huge numbers, long strings, many concurrent requests).
4. Run a **FedEx Tour**: pick one piece of data (e.g., a user-supplied string, an uploaded file, a config value) and trace it from input to every place it's stored, transformed, or rendered, checking consistency at each hop.
5. Run a **Bad Neighborhood / Museum Tour**: use `git log`/`git blame` (Section 7) to find the oldest, least-changed, or historically bug-prone files and give them focused attention.

---

## 2. Oracles for judging whether behavior is "wrong": FEW HICCUPPS

**Primary source:** Michael Bolton, *FEW HICCUPPS*, DevelopSense blog, 23 July 2012 (last edited 2017-01-26): https://developsense.com/blog/2012/07/few-hiccupps — this is the canonical, author-published consolidation of the heuristic, explicitly attributed to work originated by James Bach: "The original list came from James Bach." Earlier/longer version: Michael Bolton, *Oracles*, https://www.developsense.com/resource/Oracles.pdf (adapted from the 2005 *Better Software* article "Testing Without a Map").

**Definition of "oracle" (from the Oracles PDF, p.1):**

> "An oracle is a heuristic principle or mechanism by which someone recognizes a problem ... Oracles are by their nature heuristic. That is, oracles are fallible and context-dependent. Oracles do not tell us conclusively that there is a problem; rather, they suggest that there may be a problem."

**The mnemonic, letter by letter**, quoted/paraphrased directly from the DevelopSense post:

| Letter | Heuristic | Precise meaning |
|---|---|---|
| **F** | **Familiarity** | "We expect the system to be *inconsistent* with patterns of familiar problems." (Note: this is the one *inconsistency*-seeking heuristic in the set — testers start by looking for bug patterns they've seen before, which gives fast traction but can bias/mislead if over-relied upon.) |
| **E** | **Explainability** | "We expect a system to be understandable to the degree that we can articulately explain its behaviour to ourselves and others." If you (or the product's own developers) can't explain *why* it behaves a certain way, that's itself a signal worth investigating. |
| **W** | **World** | "We expect the product to be consistent with things that we know about or can observe in the world" — general real-world knowledge, independent of the other heuristics. |
| **H** | **History** | "We expect the present version of the system to be consistent with past versions of it." (A regression is, by this definition, a History inconsistency.) |
| **I** | **Image** | "We expect the system to be consistent with an image that the organization wants to project, with its brand, or with its reputation." |
| **C** | **Comparable Products** | "We expect the system to be consistent with systems that are in some way comparable" — same product line, competitors, or even non-competing products that process the same kind of data. |
| **C** | **Claims** | "We expect the system to be consistent with things important people say about it" — in writing (specs, docs, manuals) or in conversation (meetings, announcements). A documented behavior that the code doesn't match is a Claims violation. |
| **U** | **User('s) Desires** | Originally "User Expectations": "We believe that the system should be consistent with ideas about what reasonable users might want." (Bolton later renamed this "Users' Desires" in a 2014-12-05 update to the article, for reasons explained in a linked follow-up.) |
| **P** | **Product** | "We expect each element of the system (or product) to be consistent with comparable elements in the same system" — i.e., internal self-consistency (e.g., two similar commands should behave similarly). |
| **P** | **Purpose** | "We expect the system to be consistent with the explicit and implicit uses to which people might put it." |
| **S** | **Statutes (and Standards)** | "We expect a system to be consistent with relevant statutes, acts, laws, regulations, or standards." The key distinction from Claims: "Claims come from inside the project. For Standards and Statutes, the mandate comes from outside the project" (e.g., violating an RFC, a published UI convention, or an accessibility law even if the project never explicitly claimed to follow it). |

**How it's used to justify "bug" vs. "looks weird":** Bolton is explicit that vague "doesn't meet expectations" reports are a "tautology," and that credibility comes from naming *which* consistency principle is violated:

> "A tester's report is more credible when decision-makers (program managers, programmers) can understand clearly why the tester believes an observation points to a problem."

Also critical: every heuristic is fallible and can conflict with another — "An inconsistency with one of the principles above doesn't guarantee that there's a problem ... Our oracles can also mislead us."

**Actionable procedure for an agent:** When something looks suspicious, before writing it up as a bug, explicitly name which HICCUPPS consistency principle it violates and say so in the report, e.g.:
- *History*: "This output differs from what the same command produced in the previous release / the CHANGELOG says this should still work."
- *Claims*: "The README/docstring/API doc says X; the code does Y."
- *Comparable Products*: "Every other subcommand accepts `--json`; this one silently ignores it" (also doubles as *Product* self-consistency).
- *Purpose*: "This is a config-validation tool, and it accepts an obviously invalid config without error — that's inconsistent with its stated purpose."
- *Statutes/Standards*: "The HTTP response violates RFC 7231 §X" or "fails WCAG 2.1 contrast requirements."
- *World*: "This computation produces a result that's mathematically impossible / physically impossible."

If none of the nine heuristics can be invoked to justify the finding, treat it as a weaker, "curiosity" rather than a confirmed bug, and say so rather than asserting a defect.

---

## 3. Bug report quality (Mozilla, Chromium)

### 3.1 Mozilla Bug Writing Guidelines

**Source:** Mozilla, *Bug Writing Guidelines*, https://bugzilla.mozilla.org/page.cgi?id=bug-writing.html (canonical Bugzilla-hosted page for the project that originated Bugzilla).

Required discipline, quoted/paraphrased:
- **One issue per report:** "Open a new bug report for each issue! ... If you have multiple issues, please file separate bug reports."
- **Reproduction is mandatory, and its reliability must be stated:**
  > "If you have precise steps to reproduce — great! ... If you can reproduce occasionally, but not after following specific steps, you must provide additional information for the bug to be useful. If you can't reproduce the problem, there's probably no use in reporting it, unless you provide unique information about its occurrence."
- **Currency check before filing:** "Make sure your software is up to date. Ideally, test an in-development version to see whether your bug has already been fixed."
- **Minimization:** for product-specific bugs, "first check if you can reproduce the bug in a new Firefox profile. If the bug only happens in your existing profile, try to figure out what settings, extensions, or files in your profile are needed to reproduce the bug" — i.e., strip configuration/state until the minimal triggering condition is found.
- **Summary quality:** "How would you describe the bug using approximately 10 words? ... It should explain the problem, not your suggested solution." Given examples: Good — "Cancelling a File Copy dialog crashes File Manager"; Bad — "Software crashes."
- **Steps-to-reproduce is the single most load-bearing field:** "Steps to reproduce are the most important part of any bug report. If a developer is able to reproduce the bug, the bug is very likely to be fixed. If the steps are unclear, it might not even be possible to know whether the bug has been fixed." The guide prescribes a table format with explicit **actual vs. expected results** fields and a note on **reproducibility** ("at will, occasionally, or not at all").
- Required contextual fields: version, OS/platform, Build ID.

### 3.2 Chromium Bug Reporting / Life Cycle Guidelines

**Source:** The Chromium Projects, *Bug Life Cycle and Reporting Guidelines*, https://www.chromium.org/for-testers/bug-reporting-guidelines/

Core checklist, quoted/paraphrased directly:
- "Make sure the bug is verified with the latest Chromium (or Chrome canary) build." — i.e., reproduce on the current build before filing, exactly mirroring Mozilla's currency check.
- "Provide a high-level problem description." / "Mention detailed steps to replicate the issue." / "Include the expected behavior."
- "Verify the bug in other browsers and provide the information" — cross-implementation comparison as part of triage (this is effectively the *Comparable Products* oracle from Section 2, operationalized as a reporting requirement).
- "Include screenshots, if they might help." / "If a bug can be reduced to a simplified test, then create a simplified test and attach it to the bug." — explicit minimization requirement (reduced test case).
- Type-specific evidence requirements, each with its own Chromium page:
  - **Crash bugs** (https://www.chromium.org/for-testers/bug-reporting-guidelines/reporting-crash-bug/): attach a crash ID from `chrome://crashes`, or raw minidump/crash-report files if reporting isn't enabled.
  - **Hang bugs** (https://www.chromium.org/for-testers/bug-reporting-guidelines/hanging-tabs/): attach a process minidump of the hung process (Process Explorer on Windows; `kill -ABRT`/`-SEGV` to force a dump on Mac/Linux).
  - **Performance bugs** (https://www.chromium.org/developers/how-tos/submitting-a-performance-bug/): attach a `chrome://tracing` recording, "the duration of your recording should be about 10 seconds or less," plus version, OS, and URLs.
- **Security bugs** (https://www.chromium.org/for-testers/faq/): filed with a dedicated "Security Bug" template; marking an issue as a security "Vulnerability" type automatically restricts visibility and notifies `security@chromium.org` — i.e., the project has a structural mechanism to keep exploit details non-public (see Section 6).

### 3.3 Severity assessment (synthesis across both sources)

Neither Mozilla's nor Chromium's guide gives a numeric severity formula in the pages cited; both instead gate severity/priority on **reproducibility + impact scope** (crash/hang/data-loss > functional defect > cosmetic) and on whether the bug is a **regression** (inconsistent with History, in HICCUPPS terms) vs. a pre-existing issue. `[unverified]` — a more granular Mozilla/Bugzilla severity rubric (e.g., the specific blocker/critical/major/normal/minor/trivial definitions) exists in Bugzilla's field documentation but was not directly fetched for this research pass; do not assert specific severity-level definitions as verified without re-checking Bugzilla's own field help text.

**Actionable procedure for an agent, synthesized:**
1. One finding per report. Never bundle unrelated symptoms.
2. State a precise, problem-describing title (~10 words, no proposed fix in the title).
3. Reproduce on the current/latest code (HEAD or latest release) before reporting — stale reproduction is treated as presumptively invalid by both projects.
4. Provide minimized, numbered steps to reproduce, each describing both the literal action and its intent.
5. State reproducibility rate explicitly: always / intermittent (give a frequency if possible) / could not reproduce (and say why it's still worth reporting, if it is).
6. Separate **Actual Result** from **Expected Result** explicitly, and justify "expected" using one of the oracle heuristics from Section 2.
7. Attach the smallest artifact that reproduces the problem: reduced test case, minimal diff, minimal config, or minimal input file — never just "it's broken, trust me."
8. Include environment facts: version/commit hash, OS/platform, relevant build flags or config.
9. For crashes/hangs: attach a stack trace, crash dump, or debugger output, not just a description of the symptom.
10. For performance regressions: attach timing/trace evidence per Section 8, not a single anecdotal timing.
11. For anything security-relevant: do **not** put exploit details in a public issue — follow Section 6's private-disclosure process instead.

---

## 4. OWASP Web Security Testing Guide (WSTG)

**Source (structure):** OWASP Foundation, *WSTG – Latest*, https://owasp.org/www-project-web-security-testing-guide/latest/README — fetched directly from owasp.org.

**Top-level structure** (verbatim section titles from owasp.org):

> "0. Foreword / 1. About / 2. Introduction / 3. The OWASP Testing Framework / 4. Web Application Security Testing / 5. Reporting" plus "Appendix A. Testing Tools Resource / B. Suggested Reading / C. Fuzzing / D. Encoded Injection / E. History / F. Leveraging Dev Tools."

**Chapter 4 ("Web Application Security Testing") categories**, from https://wstg.owasp.org/latest/4-Web_Application_Security_Testing/:

> 4.0 Introduction and Objectives · 4.1 Information Gathering · 4.2 Configuration and Deployment Management · 4.3 Identity Management · 4.4 Authentication · 4.5 Authorization · 4.6 Session Management · 4.7 Injection · 4.8 Error Handling · 4.9 Weak Cryptography · 4.10 Business Logic · 4.11 Client-side · 4.12 API Testing · 4.13 WebAssembly Testing

Each numbered sub-category (e.g., 4.1.x, 4.4.x) decomposes into individual named tests such as "Testing for Default Credentials," "Testing Directory Traversal File Include," "Testing for Reflected Cross Site Scripting," etc. (confirmed via the stable-version appendix table of contents at https://owasp.org/www-project-web-security-testing-guide/stable/6-Appendix/, which enumerates the full WSTG-4.x.y test catalog).

**How OWASP recommends testing be scoped:** from the Testing Framework foreword, https://owasp.org/www-project-web-security-testing-guide/latest/3-The_OWASP_Testing_Framework/1-The_Web_Security_Testing_Framework:

> "When performing security testing, continuously re-prioritize. There are infinite ways an application could fail, and organizations always have limited testing time and resources. Spend that time on security issues that present real risk to the business ... Avoid treating the guide as a checklist ... Use it as a strong place to start."

> "Automated security tools ... are still generic ... The most serious issues are frequently intertwined with business logic and custom design, which is where the techniques in this guide matter most." — i.e., WSTG explicitly positions manual/semi-automated technique as necessary *beyond* scanners for the highest-value findings.

**How OWASP recommends evidence/reporting:** from Chapter 5, https://owasp.org/www-project-web-security-testing-guide/latest/5-Reporting/01-Reporting_Structure:
- A **Findings Summary** table: `Ref. ID | Title | Risk Level`.
- Each **Findings Detail** must include: Reference ID; vulnerability title; exploitability/likelihood (how easy, whether working exploit code exists, access level required, attacker motivation); impact; an overall risk rating using suggested values **Informational, Low, Medium, High, Critical** ("Ensure that you detail the values you decide to use in an appendix"); optionally a CVSS score ("On certain engagements it is required to have a CVSS score ... other times it just adds complexity"); a detailed description of the vulnerability and how to exploit it (masking sensitive data such as passwords/PII); and remediation steps.
- **Reproducible Test Artifacts** are explicitly called out: "curl commands demonstrating the request," "Proof-of-Concept (PoC) such as CSRF forms," "HAR files capturing request/response flows," "Simple automation scripts (e.g., Selenium, Puppeteer)" — "These artifacts can help developers quickly validate and retest vulnerabilities."
- Recommended appendices: test methodology used, severity/risk-rating explanation, cleaned tool output ("Make sure to clean the output and not just dump it"), and a checklist of tests conducted.

Older guidance (WSTG v4.1 Introduction, https://owasp.org/www-project-web-security-testing-guide/v41/2-Introduction/README) adds that a complete report should include, per vulnerability: type classification, the specific threat it's exposed to, root cause, testing technique used to find it, remediation, and severity rating (CVSS or high/medium/low).

**Actionable procedure for an agent doing web-app security testing:**
1. Scope the engagement against the WSTG 4.1–4.13 categories relevant to the target (don't blindly run every test — prioritize by what's exposed: auth, session handling, input-driven endpoints, APIs).
2. For every candidate finding, capture a reproducible artifact (a `curl` command or minimal script) rather than relying on a one-off manual screenshot.
3. Write the finding with: title, risk rating (state your rating scale), exploitability factors, impact, description (with secrets/PII masked), and remediation guidance — matching the WSTG 5.1 structure.
4. Treat automated scanner output as a *lead* to manually verify, not a finding to report as-is — WSTG explicitly frames scanners as breadth tools that need manual judgment for business-logic-level bugs.

---

## 5. CVSS v4.0 scoring (FIRST.org)

**Source:** FIRST.org, *Common Vulnerability Scoring System version 4.0: Specification Document*, Document Version 1.2: https://www.first.org/cvss/v4.0/specification-document (PDF mirror: https://www.first.org/cvss/v4-0/cvss-v40-specification.pdf)

### 5.1 The four metric groups

Quoted directly from the spec:

> "CVSS consists of four metric groups: Base, Threat, Environmental, and Supplemental. The Base group represents the intrinsic qualities of a vulnerability that are constant over time and across user environments, the Threat group reflects the characteristics of a vulnerability that change over time, and the Environmental group represents the characteristics of a vulnerability that are unique to a user's environment ... Supplemental metrics do not modify the final score, and are used as additional insight into the characteristics of a vulnerability."

| Group | Who typically sets it | Purpose (quoted) |
|---|---|---|
| **Base** | "vulnerability bulletin analysts, product vendors, or application vendors" | "reflects the severity of a vulnerability according to its intrinsic characteristics which are constant over time and assumes the reasonable worst-case impact across different deployed environments." |
| **Threat** | the consumer, using threat intelligence | "adjust[s] the severity of a vulnerability based on factors, such as the availability of proof-of-concept code or active exploitation." |
| **Environmental** | the consumer, for their own deployment | "further refine[s] the resulting severity score to a specific computing environment ... presence of mitigations ... and the criticality attributes of the vulnerable system." |
| **Supplemental** | the assessment provider, optionally | "describe and measure additional extrinsic attributes of a vulnerability, intended to add context" — explicitly does **not** change the numeric score. |

Score naming convention: **CVSS-B** (Base only), **CVSS-BT** (Base+Threat), **CVSS-BE** (Base+Environmental), **CVSS-BTE** (all three, the fully refined score).

### 5.2 Base metrics (the ones an agent can usually estimate from observed facts alone)

The Base group splits into **Exploitability** metrics (describe the vulnerable system/attack path) and **Impact** metrics (describe the consequence), each quoted/paraphrased from the spec:

**Exploitability metrics:**
- **Attack Vector (AV)** — `Network (N)` / `Adjacent (A)` / `Local (L)` / `Physical (P)`. "Adjacent" = "limited at the protocol level to a logically adjacent topology" (e.g., same LAN/Bluetooth); "Local" = attacker needs local/console/SSH access or relies on tricking a user; "Physical" = "the attacker is required to physically touch or manipulate the vulnerable system."
- **Attack Complexity (AC)** — `Low` / `High`. Captures whether extra, attacker-independent conditions must hold for the attack to work, besides what's captured by Attack Requirements. Note: "detailed knowledge of the vulnerable system is outside the scope of Attack Complexity" — assume the attacker already knows the general configuration.
- **Attack Requirements (AT)** *(new in v4.0 vs. v3.x)* — captures "prerequisite deployment and execution conditions ... that enable the attack," distinct from Attack Complexity because these conditions arise naturally from how the system is deployed, not from deliberate security controls.
- **Privileges Required (PR)** — `None` / `Low` / `High`. "Usually None for hard-coded credential vulnerabilities or vulnerabilities requiring social engineering (e.g., reflected cross-site scripting, cross-site request forgery...)."
- **User Interaction (UI)** — whether a victim must take some action (e.g., open a document, click a link) for the attack to succeed.

**Impact metrics** — uniquely in v4.0, each of Confidentiality/Integrity/Availability is scored **twice**: once for the **Vulnerable System** (VC/VI/VA) and once for any **Subsequent System** impacted (SC/SI/SA), replacing v3.x's single "Scope" flag:
- **Confidentiality (VC/SC)** — `High` ("total loss ... all information ... divulged to the attacker," e.g., "steals the administrator's password") / `Low` (partial, limited disclosure) / `None`.
- **Integrity (VI/SI)** — `High` ("total loss of integrity ... able to modify any/all files") / `Low` (limited, attacker lacks control over what's modified) / `None`.
- **Availability (VA/SA)** — `High` ("total loss of availability ... sustained ... or persistent") / `Low` / `None`.

### 5.3 Threat metrics

- **Exploit Maturity (E)** — `Not Defined (X)` (default; "equivalent to Attacked (A) ... assuming the worst case") / `Attacked (A)` (reported attacks or publicly/privately available exploit toolkits) / (additional lower-maturity values exist in the full table, e.g., POC/Unreported, per the spec's Table 12).

### 5.4 Environmental metrics

Mirrors the Base metrics with an `M` prefix (e.g., `MAV`, `MAC`, `MPR`, `MSI`, `MSA`...) to let the consumer override any Base value for their specific deployment, plus three standalone **Security Requirements** metrics: **Confidentiality Requirement (CR)**, **Integrity Requirement (IR)**, **Availability Requirement (AR)** (each `Not Defined/High/Medium/Low`), reflecting how important that property is to the consumer's business. A special `Safety (S)` value is available on Modified Subsequent-System Integrity/Availability (MSI/MSA) when "exploitation ... has the potential to impact human safety."

### 5.5 Supplemental metrics (context only — never change the score)

Per the spec: **Safety (S)**, **Automatable (AU)** — "Can an attacker automate exploitation events for this vulnerability across multiple targets?" (based on kill-chain steps 1–4: recon, weaponization, delivery, exploitation) — **Recovery (R)**, **Value Density (V)** (`Diffuse` vs. `Concentrated` — how much an attacker gains per single exploitation event), **Vulnerability Response Effort (RE)**, and **Provider Urgency (U)** (`Clear/Green/Amber/Red` pass-through rating from the vendor).

**Actionable procedure for an agent scoring a finding from observed facts alone:**
1. Always compute at least a **Base** score (CVSS-B); Threat/Environmental require information (exploit intel, deployment specifics) an outside researcher usually can't know, so state them as "Not Defined" rather than guessing.
2. For each Base metric, answer from what you actually observed, not assumption:
   - AV: how must the attacker reach the vulnerable code — over the network, same subnet, local shell, or physical access?
   - AC / AT: does the exploit work reliably and deterministically, or does it depend on race conditions/specific configuration the attacker doesn't control?
   - PR: does triggering it require being authenticated, and at what privilege level?
   - UI: does a victim have to click/open/run something?
   - VC/VI/VA (and SC/SI/SA if a second system is affected, e.g., a browser rendering attacker-controlled HTML): what's the worst-case confidentiality/integrity/availability consequence you actually demonstrated or can rigorously argue?
3. Report the resulting vector string (e.g., `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`) alongside the qualitative severity, and be explicit that Threat/Environmental refinement is left to the consuming organization.
4. Do not report a High/Critical severity based on *theoretical* worst-case impact unless Base Impact metrics are honestly justified by what you actually showed in your PoC — overclaiming severity undermines report credibility (ties back to Section 2's oracle-justification discipline).

---

## 6. Coordinated vulnerability disclosure

### 6.1 What CVD is and why

**Primary source:** Allen D. Householder, Garret Wassermann, Art Manion, Chris King, *The CERT® Guide to Coordinated Vulnerability Disclosure*, CMU/SEI-2017-SR-022, Software Engineering Institute, Carnegie Mellon University, Aug 2017. PDF: https://www.sei.cmu.edu/library/file_redirect/2017_003_001_503340.pdf ; web edition: https://certcc.github.io/CERT-Guide-to-CVD/

> "Coordinated Vulnerability Disclosure (CVD) is the process of gathering information from vulnerability finders, coordinating the sharing of that information between relevant stakeholders, and disclosing the existence of software vulnerabilities and their mitigations to various stakeholders including the public. The CERT Coordination Center has been coordinating the disclosure of software vulnerabilities since its inception in 1988."

### 6.2 OpenSSF guidance specifically for independent researchers ("Finders")

**Primary source:** OpenSSF Vulnerability Disclosure Working Group, *Guidance for Security Researchers to Coordinate Vulnerability Disclosures with Open Source Software Projects*, https://oss-vulnerability-guide.openssf.org/finder-guide.html (source markdown: https://github.com/ossf/oss-vulnerability-guide/blob/main/finder-guide.md)

**What CVD means in practice:**

> "The CVD process involves privately disclosing the vulnerability details, creating and testing a fix for the vulnerability, and then disclosing the fix and details with all downstream consumers simultaneously ... Maintaining an information embargo during the mitigation and patching phase is key to protecting the users here."

**Security policy / SECURITY.md expectations.** A project's security policy "typically includes": how to report (email, issue tracker, etc.), how sensitive info should be handled (encryption, TLP markers), what the reporter can expect (response timelines, handling decisions — "Bug Bar"), and **safe harbor**:

> "Legal safe harbor (an explicit statement that promises no legal action will be taken against vulnerability reports made in good faith)."

> "A security policy can look like a SECURITY.md file in a repository or a SECURITY.txt file on the project's website..."

**If there's no visible security contact,** the guide recommends, in order: publicly ask for a security contact via the issue tracker; reach out to maintainers directly (email/chat); check if the project belongs to a foundation with a security team; contact commercial vendors who embed/support the project; use the `oss-security` mailing list; or contact **MITRE/CVE or CERT/CC** for coordination help — "avoid sharing sensitive information until you've set up an appropriate communication channel with the right people."

**What a good report should include** (direct list from the guide): the problem, affected versions/product, steps taken to find it, a PoC ("after you have established a secure channel"), the vulnerable source lines and root cause if known, when it was introduced, impact if exploited, a CVSS estimate, applicable CWE, whether it's being actively exploited, suggested remediation, any disclosure timeline constraints, and whether the information has been shared with anyone else already.

**Timelines:** the guide does not mandate a fixed number of days, but stresses setting explicit expectations up front: "Stating an up-front vulnerability disclosure timeline can set clear expectations around how and when disclosure will occur ... ensure that the maintainer has a reasonable amount of time to fix the vulnerability, that users aren't left unaware for an extended period of time, and that a fix is released as soon as possible." `[unverified]` — I did not find a single FIRST/OpenSSF/CERT-mandated universal day-count (e.g., "90 days") in these primary documents; specific day-counts (like Google Project Zero's 90-day policy) belong to individual organizations' own policies, not a universal open-source standard, and should not be asserted as a general rule.

**Disclosure options table** (from the guide, with CERT/CC's own definition embedded): *No Disclosure*, **Coordinated** (OpenSSF-preferred; citing CERT/CC's definition verbatim: "gathering information from vulnerability finders, coordinating the sharing of that information between relevant stakeholders, and disclosing the existence of software vulnerabilities and their mitigations to various stakeholders, including the public"), **Limited** (partial public disclosure, e.g. no PoC released), **Full** (complete public disclosure), and **0-day** (full disclosure with no advance coordination — explicitly *not* OpenSSF-preferred).

**Getting a CVE:** "A reporter can obtain a CVE identifier from the CVE program at any point during the disclosure process ... ideally, before public disclosure." MITRE is "CNA of Last Resort" if no better-scoped CNA exists.

### 6.3 GitHub's mechanisms (docs.github.com, fetched directly)

**Private vulnerability reporting** — https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/privately-reporting-a-security-vulnerability :

> "If a public repository has private vulnerability reporting enabled, anyone can submit a private vulnerability report to the repository maintainers ... Click **Report a vulnerability** to open the advisory form ... only the title and description are mandatory. ... We recommend security researchers provide as much information as possible... When the report is submitted, GitHub automatically adds the reporter of the vulnerability as a collaborator and as a credited user on the proposed advisory."

Important distinction, quoted directly: **"Private vulnerability reporting is separate from a repository's `SECURITY.md` file. You can only report vulnerabilities privately for repositories where this feature is enabled, and you don't need to follow the instructions in `SECURITY.md`"** when that feature is on — but if it's *not* enabled, "you need to initiate the reporting process by following the instructions in the security policy for the repository, or by creating an issue asking the maintainers for a preferred security contact" (https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/report-privately).

**Enabling it (maintainer side)** — https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/configure-vulnerability-reporting/configure-for-a-repository : Settings → Security and quality → Advanced Security → enable "Private vulnerability reporting"; researchers then see a "Report a vulnerability" button on the Advisories page.

**Managing the report (maintainer side)** — https://docs.github.com/en/code-security/how-tos/report-and-fix-vulnerabilities/fix-reported-vulnerabilities/manage-vulnerability-reports : maintainers can accept, ask questions, or close the report, and can "Start a temporary private fork" to collaborate on a fix privately before any public advisory is published.

### 6.4 What NOT to do (synthesized from the above primary sources)

- Do **not** file a public GitHub issue containing exploit details or a working PoC for an unpatched vulnerability — use GitHub's private vulnerability reporting feature where available, or the project's documented `SECURITY.md` contact, before any public disclosure (docs.github.com, OpenSSF finder guide).
- Do **not** build or run a destructive/irreversible PoC against systems you don't control or own (e.g., a live production instance) — the OpenSSF guide frames PoC-sharing as something to do only "after you have established a secure channel to the maintainer," implying controlled, consented demonstration rather than uncontrolled live exploitation.
- Do **not** assume a universal fixed embargo length; set and communicate your own reasonable disclosure timeline explicitly, since CVD depends on "an information embargo during the mitigation and patching phase" being respected by agreement, not by a single hard global rule.
- Do **not** publicly disclose before a fix (or an agreed timeline) without first attempting coordinated private contact — OpenSSF explicitly ranks "0-day" disclosure as an available-but-not-preferred option, distinct from its "preferred" Coordinated and Limited options.
- Do **not** skip requesting a CVE if the project is shipped to end users — "it should receive a CVE" per the OpenSSF guide, and doing so before public disclosure lets the identifier be included in the advisory.

**Actionable procedure for an agent that finds a credible security issue in an open-source project it doesn't maintain:**
1. Look for `SECURITY.md` / a security policy in the repo root or `.github/` first.
2. Check whether the repository's "Security" tab offers a **"Report a vulnerability"** button (GitHub private vulnerability reporting) — if so, use it instead of a public issue.
3. If neither exists, do not post exploit details publicly. Instead, either open a non-sensitive issue asking "is there a security contact for this project?" or email/contact listed maintainers directly, per the OpenSSF finder guide's fallback list (including contacting CERT/CC as a last resort for coordination help).
4. Write the report using the OpenSSF "useful information" checklist in §6.2 above: problem, affected versions, reproduction steps, root cause/location if known, impact, CVSS estimate, suggested remediation.
5. State your own intended disclosure timeline up front and ask the maintainer to confirm or negotiate it.
6. Do not publish the finding (blog, issue, social media) until the embargo/timeline is honored or the maintainer has shipped and announced a fix — and prefer "Limited" disclosure (withholding a working exploit) over "Full" disclosure even after the fix ships, unless there's a clear reason not to.

---

## 7. GitHub/git search for duplicate and prior-art screening

### 7.1 `gh` CLI search

**Sources:** GitHub CLI manual, https://cli.github.com/manual/gh_issue_list and https://cli.github.com/manual/gh_search_issues ; GitHub Docs, *Filtering and searching issues and pull requests*, https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/filtering-and-searching-issues-and-pull-requests?tool=cli

**Two different mechanisms, confirmed directly from the manual pages:**

1. **`gh issue list --search <query>` / `gh pr list --search <query>`** — scoped to the *current repository*; the query is "one quoted string (it is a flag value)". Per the official manual:
   > "List issues in a GitHub repository. By default, this only lists open issues. ... On supported GitHub hosts, advanced issue search syntax can be used in the `--search` query."

   Example from GitHub Docs:
   ```
   gh issue list --search 'no:assignee label:"help wanted",bug sort:created-asc'
   gh pr list --search "team:octo-org/octo-team"
   ```

2. **`gh search issues [<query>] [flags]` / `gh search prs`** — searches *across all of GitHub* (or scoped via `--repo`/`--owner`), using GitHub's search index, and *also* exposes qualifiers as dedicated flags (`--author`, `--label`, `--state`, `--match title|body|comments`, etc.). Per the manual:
   > "Search for issues on GitHub. The command supports constructing queries using the GitHub search syntax, using the parameter and qualifier flags, or a combination of the two." Advanced boolean syntax (`OR`/`AND`) "must be passed as separate arguments, rather than within a quoted multi-word string."

   Example: `gh search issues repo:cli/cli is:open author:monalisa`

3. **`gh api search/issues`** — raw REST access, per GitHub's REST reference (https://docs.github.com/en/rest/reference/search): `GET /search/issues` with a `q` query string built from the same qualifiers, e.g. `q=windows+label:bug+language:python+state:open&sort=created&order=asc`. Useful for an agent needing structured JSON and pagination/`totalCount` beyond what `gh issue list`/`gh search` expose directly (`gh api --paginate` + `--jq`).

### 7.2 GitHub search qualifiers for issues/PRs

**Source:** GitHub Docs, *Searching issues and pull requests*, https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests (fetched directly)

Quoted directly:
- `is:issue` / `is:pr` (or `type:issue` / `type:pr`): "By default, GitHub search will return both issues and pull requests ... restrict search results to just issues or pull requests using the `type` or `is` qualifier." E.g. `is:issue label:bug is:closed`.
- `state:open` / `state:closed` (equivalently `is:open` / `is:closed`): "filter issues and pull requests based on whether they're open or closed." E.g. `performance is:open is:issue`.
- `in:title`, `in:body`, `in:comments` (combinable, e.g. `in:title,body`): "With the `in` qualifier you can restrict your search to the title, body, comments, or any combination of these. When you omit this qualifier, the title, body, and comments are all searched." E.g. `error in:title,body`.
- Additional qualifiers useful for dedup screening (same page / https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/filtering-and-searching-issues-and-pull-requests): `author:`, `involves:`, `assignee:`, `label:"..."` (comma = OR, repeated flag = AND), `linked:pr`/`linked:issue`, `reason:completed`/`reason:"not planned"` for closed issues, `org:`/`user:`/`repo:` to scope.

### 7.3 `git log` techniques (git-scm.com)

**Source:** Git, *git-log Documentation*, https://git-scm.com/docs/git-log (official Git project docs)

- **`git log -S<string>`** (the "pickaxe"): "Look for differences that change the number of occurrences of the specified `<string>` (i.e. addition/deletion) in a file ... use the feature iteratively to feed the interesting block in the preimage back into `-S`, and keep going until you get the very first version of the block." Add `--pickaxe-regex` to make `-S` treat its argument as a regex.
- **`git log -G<regex>`**: "Look for differences whose patch text contains added/removed lines that match `<regex>`." The doc gives the exact distinguishing example:
  > "consider a commit with the following diff in the same file: `+ return frotz(nitfol, two->ptr, 1, 0); ... - hit = frotz(nitfol, mf2.ptr, 1, 0);` ... `git log -G"frotz\(nitfol"` will show this commit, [but] `git log -S"frotz\(nitfol" --pickaxe-regex` will not (because the number of occurrences of that string did not change)." — i.e., `-G` finds any touching commit; `-S` finds only commits that change the *count* of occurrences.
- **`--pickaxe-all`**: "When `-S` or `-G` finds a change, show all the changes in that changeset, not just the files that contain the change" — useful to see the full commit, not just the matching file.
- **`git log --grep=<pattern>`**: (confirmed via the same git-log doc's option listing) searches commit *messages* for a pattern, as distinct from `-S`/`-G` which search the diff content.
- **`git log -L<start>,<end>:<file>`** / **`-L:<funcname>:<file>`**: "Trace the evolution of the line range given by `<start>,<end>`, or by the function name regex, within the `<file>` ... Implies `--patch`." This shows every commit that touched a specific line range or function over time — directly useful for understanding *why* a specific buggy block looks the way it does.

### 7.4 `git blame` (git-scm.com)

**Source:** Git, *git-blame Documentation*, https://git-scm.com/docs/git-blame

> "git-blame - Show what revision and author last modified each line of a file ... Annotates each line in the given file with information from the revision which last modified the line."

- **`git blame -L <start>,<end> <file>`**: "`-L` restricts annotation to the requested lines." Same range syntax as `git log -L` (absolute line numbers, or `/regex/` to locate a start/end line, or `+N`/`-N` offsets).
- The doc explicitly cross-references pickaxe once blame hits a deletion: "The report does not tell you anything about lines which have been deleted or replaced; you need to use a tool such as `git diff` or the 'pickaxe' interface," with the worked example `git log --pretty=oneline -S'blame_usage'`.
- `-M` / `-C` flags: detect lines moved within a file (`-M`) or copied/moved across files (`-C`) so blame can follow refactors rather than falsely attributing a moved block to the commit that only relocated it.

**Actionable procedure for an agent doing duplicate/prior-art screening before filing a new issue:**
1. In-repo check first (cheap, scoped): `gh issue list --search "<keywords> in:title,body" --state all -L 100` and `gh pr list --search "<keywords>" --state all -L 100` to catch open/closed issues and PRs (including ones that fixed-and-closed the same symptom).
2. Cross-repo / fork-aware check: `gh search issues "<keywords>" repo:<owner>/<repo> is:issue` or broader `gh search issues "<keywords>" org:<org>` if the bug might be filed against a related repo in the same org.
3. For structured/large-scale queries (counts, pagination beyond `gh`'s defaults), fall back to `gh api search/issues -f q='<keywords> repo:owner/name is:issue'` or `gh api graphql` for `totalCount`.
4. Once a candidate suspect code region is identified, use `git log -S'<exact symbol or literal>' --oneline` to find exactly when that code was introduced/removed, and `git log -G'<regex>' --oneline` to find any commit whose diff touches matching text even without a net occurrence-count change.
5. Use `git log --grep='<keyword>' --oneline` to search commit messages for related bug-fix language (e.g., "fix", "regression", the symptom name).
6. Use `git log -L<start>,<end>:<file>` to see the full history of the suspect block, and `git blame -L<start>,<end> <file>` to find the most recent change and its commit/author for context before concluding the finding is novel.
7. Only after this screening finds no existing report/PR should the agent proceed to file a new issue — and if it does find a near-duplicate, it should link to it rather than duplicate it, per the "Open a new bug report for each issue" vs. "check if the bug has already been reported" guidance in Mozilla's bug-writing guidelines (Section 3).

---

## 8. Performance regression measurement basics

**Source:** Brendan Gregg, *Active Benchmarking*, https://www.brendangregg.com/activebenchmarking.html ; *The USE Method*, https://www.brendangregg.com/usemethod.html ; *Evaluating the Evaluation: A Benchmarking Checklist*, https://www.brendangregg.com/blog/2018-06-30/benchmarking-checklist.html ; *Performance Analysis Methodology*, https://www.brendangregg.com/methodology.html — all fetched directly from brendangregg.com, the author's own site.

### 8.1 Baseline, then observe while it runs — not just a single timing

> "To perform active benchmarking: 1. If possible, configure the benchmark to run for a long duration in a steady state: e.g., hours. 2. While the benchmark is running, analyze the performance of all components involved using other tools, to identify the true limiter of the benchmark."

> "With active benchmarking, you analyze performance while the benchmark is still running (not just after it's done), using other tools. You can confirm that the benchmark tests what you intend it to, and that you understand what that is. Data becomes Information."

Gregg gives a concrete litmus test for whether someone actually did this rigorously:

> "How to tell if someone else did active benchmarking: Did they run other tools while the benchmark was running? Can they provide screenshots? Can they explain why the benchmark result was X, and not 2X (twice as fast)? i.e., what is the limiting factor?"

### 8.2 The USE Method — what to check while a benchmark runs

> "The Utilization Saturation and Errors (USE) Method is a methodology for analyzing the performance of any system ... For every resource, check: 1. Utilization 2. Saturation 3. Errors."

Practical tool list given directly in the Active Benchmarking page: `vmstat, iostat, mpstat, sar, top, tcpdump/snoop, perf, bcc+eBPF/DTrace/SystemTap, strace/truss`.

### 8.3 The 7-point benchmark trustworthiness checklist

From *Evaluating the Evaluation* — Gregg's own enumerated checklist for whether a benchmark result (yours or someone else's) is trustworthy evidence rather than a one-off number:

1. **Why not double?** — "If the benchmark reported 20k ops/sec, you should ask: why not 40k ops/sec? This is really asking 'what's the limiter?'" — i.e., every result must come with an identified bottleneck, not just a number.
2. **Was it tuned?** — was the system under test configured realistically (not accidentally left in an unoptimized/default state)?
3. **Did it break limits?** — sanity-check the result against known hardware ceilings (network bandwidth, bus bandwidth, disk throughput) to catch instrumentation errors.
4. **Did it error?** — confirm the workload didn't silently fail/short-circuit requests while still reporting a rate.
5. **Does it reproduce?** — re-run and check variance.
6. **Does it matter?** — is the benchmarked workload representative of real usage, or a synthetic case nobody hits?
7. **Did it even happen?** — sanity-check that the benchmark actually executed the intended workload at all (not a measurement/harness bug reporting a number for a no-op).

### 8.4 Common pitfalls (Gregg's explicit "Problem Checklist")

From Active Benchmarking:

> "Common pitfalls that can be identified using active benchmarking, are when the benchmark is: Perturbed by other system events, including neighbors. Throttled by software imposed resource controls. Throttled by the network between the benchmark client and the server. Limited by the benchmark software being single threaded. Testing different client or server software versions, when doing comparative benchmarking. Testing disk I/O instead of file system I/O. Applying an unrealistic workload."

### 8.5 On warm-up, repetition, variance (synthesis)

Gregg's pages, as fetched, emphasize **steady-state, long-duration runs** and **repeatability/reproducibility** as explicit checklist items ("Does it reproduce?") and **active observation during the run** rather than prescribing a specific numeric warm-up period or statistical test. `[unverified]` — I did not find, in the pages fetched directly from brendangregg.com, a specific prescribed warm-up duration, number of repetitions, or named statistical method (e.g., confidence intervals, specific outlier-rejection technique) for a "trustworthy" micro-benchmark; those come from profiler-specific or language-specific sources (e.g., JMH, Criterion, Google Benchmark docs) which were not in scope for this pass. Treat "run for a long duration in steady state" and "does it reproduce" as the verified minimum bar, and do not assert a specific numeric standard (e.g., "run N=30 times") as sourced to Gregg.

**Actionable procedure for an agent investigating a suspected performance regression:**
1. **Establish a baseline** on the known-good revision (or current released version) before touching anything — get a number to compare against.
2. **Bisect**: if a regression is suspected across history, use `git bisect` combined with the same controlled benchmark at each step to localize the commit that introduced the regression (not covered in Gregg's pages directly but implied by his baseline-first framing — flagged here as the natural extension, not a quoted claim).
3. Run the benchmark **in a steady state for a non-trivial duration**, not a single short invocation — avoid reporting cold-start timings as representative.
4. While it runs, use OS-level tools (whatever `vmstat`/`top`/`perf`/equivalent is available in the environment) to observe **utilization, saturation, and errors** (USE Method) on CPU, memory, disk, and network — don't just trust the benchmark harness's self-reported number.
5. Before declaring a result real, run it through Gregg's 7-question checklist: identify the actual limiter ("why not double?"), confirm realistic tuning, sanity-check against known hardware/throughput ceilings, check for silent errors, **re-run to confirm reproducibility**, confirm the workload is representative, and confirm the benchmark actually exercised the intended code path.
6. Report results with the identified limiting factor and supporting evidence (e.g., "CPU-bound, single-threaded — confirmed via per-core utilization during the run"), not just a bare before/after number — this mirrors Gregg's own standard for what counts as credible evidence: "include the limiting factor (or suspected limiting factor) along with the benchmark results... For evidence, this statement could include a screenshot."

---

## Summary of explicitly unverified items

For transparency, everything flagged `[unverified]` above, consolidated:

1. Precise definitions of the **Obsessive-Compulsive, Supporting Actor, Rained-Out, Tour-Crasher, and TOGOF** tours from Whittaker's book (names are primary-sourced via the publisher's table of contents; definitions were not found in a source I could treat as primary or reliably secondary).
2. A specific, numeric, universally-mandated **CVD embargo/timeline length** (e.g., "90 days") as a cross-industry open-source standard — the sources reviewed describe setting an explicit, negotiated timeline rather than mandating one fixed number.
3. Mozilla Bugzilla's specific **severity-level definitions** (blocker/critical/major/normal/minor/trivial) — not directly fetched in this pass; do not assert specific definitions without re-checking Bugzilla's own field documentation.
4. A specific **warm-up duration, repetition count, or named statistical method** for trustworthy micro-benchmarking — Gregg's pages establish the qualitative bar (steady-state, reproducible, actively observed) but not a numeric standard; profiler/benchmark-framework-specific docs would be needed for that level of precision.
