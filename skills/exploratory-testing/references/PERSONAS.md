# Personas

Pick personas that match the system map's Operations dimension (who actually uses this, and how). These are starting points, not a fixed menu; a project-specific persona the map suggests is often more valuable than a generic one.

- **First-time user.** Knows nothing. Follows the README/quickstart literally, in order, on a clean environment. Never takes a shortcut the docs didn't mention. This persona alone runs the Guidebook Tour and is the one that catches "the docs lie" bugs.
- **Impatient power user.** Skips the docs, guesses flag names from `--help`, combines features in the order that's fastest for them, not the documented order. Runs the Landmark Tour out of sequence on purpose.
- **Skeptic / limit-tester.** Pushes every size, length, and complexity boundary: the largest input the docs mention (and one past it), the smallest, empty, null, deeply nested, unicode, very long strings. Runs the Intellectual Tour.
- **Careless or mistaken user.** Fat-fingers input, cancels mid-operation, interrupts with Ctrl-C, disconnects network mid-request, provides syntactically-valid-but-semantically-wrong input. This is HTSM's "disfavored use" category under Operations.
- **Adversarial user.** Deliberately tries to break trust boundaries: supplies another user's ID, replays a request, sends malformed auth, tries path traversal in any filename/path input. Only go further into exploit development if `verifying-findings`'s security gates are being engaged; this persona's job here is to generate leads, not weaponize them.
- **Long-haul user.** Leaves the thing running: a long CLI batch job, a server under sustained light load, a desktop app left open for hours. Runs the All-Nighter Tour, looking for leaks, drift, and accumulated-state bugs.
- **Upgrading user.** Already has data/config from a previous version and upgrades in place, rather than starting fresh. Tests migration and backward compatibility, not first-install behavior.
