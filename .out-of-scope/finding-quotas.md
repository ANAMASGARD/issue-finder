# A minimum number of findings per engagement

Rejected direction: require `issue-finder` to surface at least N candidates, or treat an engagement that ends with zero confirmed findings as having failed.

## Why this is out of scope

The source master prompt states this explicitly and this suite keeps it as a hard rule: "A successful result may contain zero confirmed issues." A quota creates exactly the incentive this suite is built to resist: manufacturing a finding, inflating a style nit into a bug, or reporting unverified scanner noise to hit a number. `verifying-findings`'s evidence gates are the actual bar; a clean, well-tested project with no live issues that clear those gates is a correct and complete result, reported as such in `REPORT.md`, not as a shortfall.
