# Playbook: parsers, compilers, linters, formatters, and data-processing tools

- Round-trip test: parse then re-emit (format, pretty-print, re-serialize) and check the result is stable (a second round-trip produces no further change) and semantically equivalent to the input.
- Feed the tool its own test fixtures from a different version or a sibling tool in the same ecosystem, not only its own curated examples, to catch cases the project's own tests happen not to cover.
- Test malformed and edge-case input directly: empty file, file with only whitespace/comments, truncated file, wrong encoding (non-UTF-8 bytes), extremely long single line, deeply nested structure near or past any documented limit.
- Check exit codes and diagnostic output on invalid input: does it fail loudly with a useful message and non-zero exit, or does it silently produce wrong output?
- For a linter/formatter: check that its own "fix" mode is idempotent (running it twice produces the same result as running it once) and that fixing one issue doesn't introduce a different one it would itself flag.
- For a data-processing pipeline: test with realistic-sized data, not just toy examples, and check memory/time behavior against any documented expectation (only report this as a performance finding with the controlled-benchmark evidence `verifying-findings/references/PERFORMANCE-EVIDENCE.md` requires).
