# Worked example: Helm chart CronJob volume mount

A generalized, fictional case showing all six gates and a full record, start to finish. The shape is common: a Helm chart grows a `Deployment` template first, then a `CronJob` template gets added later by copying the pod spec, and one nested field silently doesn't make the trip.

## The lead

While running the Guidebook tour (`exploratory-testing`) and following the chart's own README example for enabling a scheduled cleanup job, a journey noted: the `Deployment`'s pods mount the configured `extraVolumes` correctly, but pods created by the chart's `CronJob` do not, even though `values.yaml` documents `extraVolumes` as applying to "all workloads" in the chart. Oracle cited: **Claims** — the values schema's own comment says "applies to all workloads"; the CronJob's pods don't get it.

## Claim, restated

"The chart's `extraVolumes` value is documented as applying to every workload template the chart renders, but when rendered, the `CronJob` template's pod spec doesn't include the configured volumes or their mounts, while the `Deployment` template's does."

## Gate 1: Version-correct contract

`values.yaml` at the pinned commit, comment above the `extraVolumes` key: `# Additional volumes mounted on all workload pods (Deployment, CronJob, Job).` This is an explicit, current, version-correct contract, not an assumption.

## Gate 2: Reachable path

Setting `extraVolumes` in `values.yaml` and enabling the CronJob (`cronjob.enabled: true`, both documented, supported configuration flags) is exactly the chart's own documented path to reach this; no artificial setup needed.

## Gate 3: Red reproduction

- Baseline: pinned chart version at commit `<sha>`.
- Minimal repro: `helm template . --set cronjob.enabled=true --set extraVolumes[0].name=test --set extraVolumes[0].configMap.name=test-cm` (values trimmed to the minimum needed to trigger it).
- Run 1: rendered `Deployment` manifest contains `volumes: [...name: test...]` and a matching `volumeMounts` entry; rendered `CronJob` manifest's `jobTemplate.spec.template.spec` contains neither.
- Run 2: identical result on a second invocation, same baseline, confirming it's not a rendering-order fluke.
- Minimized: reduced from the chart's full documented example values down to the single `extraVolumes` entry and the `cronjob.enabled` flag; still fails identically.

## Gate 4: Root cause

`templates/cronjob.yaml:41` references `.Values.extraVolumes` for `volumeMounts` inside the container block, but the `volumes:` key at the pod-spec level (`templates/cronjob.yaml:58`) was never added, unlike `templates/deployment.yaml:38` and `:55` which have both. The mount reference exists; the volume definition backing it doesn't, for this template only. `git blame templates/cronjob.yaml:58` points to the commit that introduced the CronJob template by partially copying the Deployment template.

## Gate 5: Negative control and disproof attempt

- Negative control: the same `helm template` run against the `Deployment` template (not CronJob) with the same values correctly produces both the `volumes` and `volumeMounts` entries, confirming the mechanism (templating itself) works; the defect is specific to the `cronjob.yaml` template.
- Disproof attempts: checked the chart's `CHANGELOG.md` and open/closed issues for an existing fix or an intentional note that CronJob volumes are out of scope — none found (this step is formally handed to `screening-duplicates` next, but a quick check here avoided wasting further gate time if it had already been fixed). Checked the current upstream default branch at its latest commit — the same gap is present there too, ruling out `Already fixed upstream`.

## Gate 6: Proof boundaries, impact, scope

- Tested: `helm template` rendering only, on the pinned baseline and current upstream HEAD, with a single `extraVolumes` entry of type `configMap`.
- Not tested: actual cluster scheduling behavior (whether the CronJob's pod fails to start, or silently runs without the volume — rendering alone proves the manifest is wrong, not yet the runtime consequence); other volume types (`secret`, `emptyDir`, PVC) might or might not hit the same gap, not yet checked individually.
- Impact: every user of this chart who enables the CronJob and relies on `extraVolumes` for it (as the docs tell them they can) gets a CronJob pod silently missing a volume mount it was told would be present — likely a crash loop or silent misbehavior at runtime, not yet directly observed in a live cluster in this pass.
- Scope: the chart's CronJob feature, all currently supported chart versions that include both this comment and this template gap (checked: yes, present across the last three tagged releases).

## Disposition

**Confirmed and actionable.** All six gates passed with direct evidence; impact is clearly stated with its proof boundary (rendering-level, not yet runtime-level) made explicit rather than overstated.

## What happens next

This record moves to `screening-duplicates` for a full query-set search (not just the quick check done in Gate 5), then to ranking, then to `drafting-issues` if it clears both. If the user later asks for a fix, `issue-fixer` starts from this exact record, including its root-cause citation, rather than re-deriving it.
