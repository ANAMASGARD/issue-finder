# Playbook: libraries and SDKs

There's no running app to click through; "using it like a real user" means writing small real programs against the public API the way a consumer would, not reading the implementation.

- Follow every code example in the README/docs verbatim, in a fresh scratch project with only the library as a dependency, exactly as a new consumer would copy-paste it. A broken quickstart example is one of the highest-value Claims-oracle leads available.
- Exercise the public API surface, not internals: if something is only reachable by importing a "private" or underscore-prefixed module, that's a documentation/API-design lead, not a legitimate test path.
- Check documented type signatures against actual accepted/returned types, especially for optional parameters, overloads, and default values.
- Check error behavior: does a documented exception/error type actually get thrown in the documented circumstance, and is the message useful?
- Test version-compatibility claims: if the project claims to support a range of runtime/language versions, check with the oldest and newest supported versions if both are available in the sandbox.
- Test resource cleanup contracts: if the library hands out a handle/connection/file that's documented as needing to be closed, verify what happens when it isn't (leak, warning, silent) versus what's documented.
- Check thread-safety or concurrency claims directly if the docs make one, with a small concurrent-use program, rather than trusting the claim.
