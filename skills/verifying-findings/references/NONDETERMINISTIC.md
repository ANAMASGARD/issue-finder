# Intermittent, racy, and nondeterministic candidates

Some real bugs don't reproduce every time. Gate 3's "run twice on a pinned baseline" still applies, but the standard of evidence shifts from "always fails" to "fails at a stated, demonstrated rate."

## Procedure

1. **Run enough times to state a rate, not a vibe.** A handful of runs isn't enough to distinguish "roughly 1 in 3" from "roughly 1 in 20"; run enough iterations that the stated frequency is itself defensible, and say how many runs you used to arrive at it.
2. **Look for the actual nondeterminism source** rather than treating "it's flaky" as the explanation: a race between goroutines/threads, an unseeded or wall-clock-dependent random value, test-ordering dependence, a timing-dependent network call, environment-dependent floating point, or genuine external-service flakiness.
3. **For suspected races/concurrency bugs**, if the language/runtime has a race detector (e.g., Go's `-race`, ThreadSanitizer, similar), run the reproduction under it; a detector catching a real data race is strong, cheap corroborating evidence even if the race only sometimes manifests as an observable failure.
4. **Try to force it deterministically** before giving up on a tight reproduction: added delays/sleeps at the suspected race window, a stress-run (many parallel iterations), or fixing a random seed if the nondeterminism is seed-driven, documenting that this is an artificial amplification used only to study the bug, not the natural trigger.
5. **State the reproduction rate explicitly in the record**: "always", "intermittent, approximately N% over M runs", or "could not reproduce despite M attempts". Never just "sometimes."

## Disposition implications

- A rate you can state with real numbers, with a plausible traced mechanism (even if you couldn't force it every time), can still be `Confirmed and actionable`. Intermittent is not automatically weaker evidence if the mechanism is understood and the rate is honestly reported.
- A suspected-but-unreproduced nondeterministic bug with no mechanism identified and no stated rate gets `Needs additional runtime validation`; say exactly what you tried (how many runs, what you varied) so the next person doesn't repeat the same unsuccessful attempts.
- Never claim "always reproduces" for something you only observed once or twice; that's the single most common way a nondeterministic bug's report quality collapses on first independent review.
