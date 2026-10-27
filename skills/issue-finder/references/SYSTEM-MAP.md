# System map: the SFDIPOT checklist

Before hunting, build a concise map of the product using all seven dimensions of Heuristic Test Strategy Model's SFDIPOT, so no category of the system goes unconsidered. Skip a dimension only when it genuinely doesn't apply (a pure library has no "Platform" story beyond language versions), and say so rather than leaving it blank.

- **Structure.** What the system is made of: languages, modules, services, how code is organized, what's generated versus hand-written, major dependencies.
- **Function.** What it does: core features, supported commands/endpoints/views, the calculations or transformations it performs, error handling and recovery paths.
- **Data.** What it consumes, stores, and emits: input formats, persisted state, config schema, data lifecycle (created, migrated, deleted), encoding and size boundaries.
- **Interfaces.** Every entrypoint a consumer touches: CLI, HTTP API, GUI, library API, webhook, plugin surface, file formats it reads/writes.
- **Platform.** What it depends on externally: OS, runtime/language versions, external services it calls, hardware or browser requirements.
- **Operations.** How it's actually used and run day to day: typical workflows, common configurations, how it's deployed/installed/upgraded, how real users are likely to combine features.
- **Time.** Where timing, ordering, and concurrency matter: race-prone paths, timeouts and retries, startup/shutdown sequencing, scheduled or event-driven behavior.

Write `.issue-finder/system-map.md` as one subsection per dimension that applied, each with concrete specifics (file paths, entrypoint names, actual config keys), not generic restatements of the dimension's definition. This map is what `exploratory-testing` uses to choose personas and journeys, and what `verifying-findings` uses to judge whether a path is "reachable in a supported configuration."
