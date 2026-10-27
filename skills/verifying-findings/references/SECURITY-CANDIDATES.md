# Security-sensitive candidates

Read this the moment a candidate's suspected impact touches unauthorized access, data exposure, privilege escalation, injection, authentication/authorization bypass, or anything else that would be embarrassing or harmful if public before a fix exists. The disposition is `Security-sensitive: private handling required` the instant this applies, overriding every other disposition, even if some gates below aren't fully passed yet — "needs more validation" and "security-sensitive" are not mutually exclusive, and the private-handling rule wins.

## What changes immediately

- **No public issue, ever**, for this candidate, regardless of any other authorization already granted in `ENGAGEMENT.md`. `drafting-issues` will refuse to create anything but a private `SECURITY-ADVISORY.md` draft for it.
- **No destructive or irreversible proof-of-concept.** Demonstrate the vulnerability's existence with the smallest, safest action that proves the claim; never run a PoC against a system you don't own or control, and never perform an action with real-world side effects (data deletion, privilege grant, mass requests) to "prove" impact.
- **Write evidence only to `.issue-finder/private/`** (mode 0700, files mode 0600), never to `findings/` or anywhere else in the normal workspace.
- **Check for the project's private reporting channel** before doing anything else: a `SECURITY.md` contact, or GitHub's "Report a vulnerability" private advisory feature. This is `drafting-issues`'s job once the candidate reaches that stage, but note it here too since the user may need to be told early if neither exists.

## Six mandatory gates, specialized for security claims

All six must pass before `Confirmed and actionable` can even be considered (it will still end in the private-handling disposition instead, but it still needs real evidence):

1. **Process** — is the vulnerable code path actually part of a process/request the target runs, not dead code or a disabled feature?
2. **Reachability** — can an attacker actually reach this path given the project's real deployment model and auth boundaries, not just in an artificial internal call?
3. **Real Impact** — what does the attacker actually gain, demonstrated, not assumed? State it in terms of confidentiality, integrity, or availability loss you actually showed.
4. **PoC Validation** — does a minimal, safe, non-destructive proof-of-concept actually trigger the claimed behavior?
5. **Math/Logic Bounds** — for anything involving calculations, encoding, or protocol logic, does the exploit actually hold up arithmetically/logically, or does it only look plausible on paper?
6. **Environment** — does this reproduce in the project's actual supported deployment configuration, not a weakened or misconfigured one you set up yourself?

A candidate that fails any of these gates is not "confirmed at lower confidence," it's `Rejected hypothesis` or `Needs additional runtime validation`, same as any other candidate.

## Severity: CVSS Base only

Estimate a CVSS v4.0 **Base** score only, from what you actually observed:

- **Attack Vector**: Network / Adjacent / Local / Physical — how must the attacker reach this?
- **Attack Complexity**: Low / High — does it work reliably, or does it need conditions outside attacker control?
- **Privileges Required**: None / Low / High.
- **User Interaction**: does a victim have to act (click, open, run something)?
- **Confidentiality / Integrity / Availability impact** (and the same for any Subsequent System affected): High / Low / None, based only on what you actually demonstrated.

Report the vector string alongside the qualitative severity (e.g., `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`). Leave Threat and Environmental metrics as "Not Defined": an outside researcher can't know the deploying organization's environment or real-world exploitation intel, and shouldn't guess. Never report a High/Critical severity based on theoretical worst-case impact that your Base Impact metrics aren't honestly justified by.

## Authorization

Nothing about finding a real security candidate expands authorization beyond what `ENGAGEMENT.md` already grants. If the user hasn't explicitly authorized "private security report," the candidate still gets fully verified and recorded, it just waits in `.issue-finder/private/` until the user grants that specific authorization.
