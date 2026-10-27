## What it does

Drives the real, running target the way a human user would, through chartered exploration sessions, to surface leads worth investigating. The defining constraint: a conclusion drawn only from reading source, without actually running the software, is never allowed to be marked `pass`.

## When to reach for it

- Invocation mode: model-invoked. Call it by name, or `issue-finder` calls it automatically during its "use it like a real user" phase.
- Reach for this directly when you want to QA, dogfood, or explore a built application or CLI on its own, without the full hunting pipeline around it.

## Prerequisites

The target must already be installed and runnable in a sandbox; `issue-finder`'s Grounding phase sets this up when this skill is called as part of the full pipeline.

## Personas, tours, and oracles

Sessions are chartered (`Explore <target> with <technique> to discover <risk>`), run with a persona from `PERSONAS.md`, using named tours from `TOURS-AND-HEURISTICS.md` (Guidebook, Landmark, Intellectual, FedEx, and others) matched to a project-type playbook (CLI, web UI, HTTP services, libraries, Kubernetes, CI integrations, data/language tools, desktop and mobile, or security tools). Every surprise gets judged against a named letter of FEW HICCUPPS (`ORACLES.md`) before it's recorded as a lead; "it feels wrong" without a named oracle is a curiosity, not a lead.

## Self-audit

A session that ran suspiciously fast or produced only clean `pass` verdicts on a charter that targeted limits gets marked `incomplete`, not inflated to a false `pass`. This is deliberate: a thorough-looking but rushed session is worse than an honestly incomplete one.

## It's working if

- `.issue-finder/journeys.md` has one row per chartered session, each with a stated result and evidence path.
- Every lead recorded names the oracle it violates.
- Nothing in its output is ever labeled a confirmed finding; that's `verifying-findings`'s job.

## Where it fits

Feeds leads to `verifying-findings`, either through `issue-finder`'s Hunt phase or directly when called standalone.
