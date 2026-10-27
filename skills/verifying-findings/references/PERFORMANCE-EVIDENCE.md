# Performance and resource-usage candidates

A single before/after timing number is not evidence. Use this procedure before reporting any performance regression or resource-usage claim as `Confirmed and actionable`.

## Procedure

1. **Baseline first.** Measure the known-good revision (an older tag, or the pinned baseline) before touching anything, so there's a real number to compare against.
2. **Bisect if the regression's origin isn't already known.** Use `git bisect` with the same controlled measurement at each step to localize the exact commit, rather than assuming which change caused it.
3. **Steady state, non-trivial duration.** Run the workload long enough to reach steady state; a single short/cold-start invocation isn't representative.
4. **Observe while it runs, don't just trust the harness's self-reported number.** Use whatever OS-level tools are available (`vmstat`, `top`, `perf`, or equivalent) to check Utilization, Saturation, and Errors (the USE Method) on CPU, memory, disk, and network during the run.
5. **Run the 7-question trustworthiness check before believing the result:**
   - Why not double? Identify the actual limiting factor; a bare number with no identified bottleneck isn't trustworthy.
   - Was it tuned realistically, not left in an accidental unoptimized state?
   - Does it break known hardware/throughput ceilings? (A sign of a measurement error.)
   - Did it silently error while still reporting a rate?
   - Does it reproduce on a re-run? (Check variance, not just one run.)
   - Does the workload actually matter? Is it representative of real usage?
   - Did the benchmark actually execute the intended code path at all?
6. **Report with the identified limiting factor**, not a bare number: e.g., "CPU-bound, single-threaded, confirmed via per-core utilization during the run," with the supporting observation attached as evidence.

## Common pitfalls to rule out before concluding

Perturbation by unrelated system load or noisy neighbors; software-imposed resource limits (cgroups, container quotas); network bottleneck between client and server rather than the component under test; a single-threaded benchmark harness masquerading as a measurement of a multi-threaded system; comparing different client or server software versions by accident; measuring disk I/O when you meant to measure filesystem-layer behavior; an unrealistic synthetic workload that doesn't resemble real usage.

A performance candidate that hasn't gone through this procedure gets `Needs additional runtime validation`, not `Confirmed and actionable`, no matter how convincing the single number looked.
