# Playbook: CLI tools

- Run every subcommand with `--help` and diff its claims against what actually happens; an undocumented flag or a documented flag that's silently ignored is a Claims-oracle lead.
- Check exit codes on both success and every documented failure mode, not just stdout text; a CLI that prints an error but exits `0` is a classic Function-dimension bug.
- Test piping: stdin from a pipe vs. a TTY, output piped to another program (does it still work without a TTY for prompts/colors?), and `Ctrl-C` mid-operation (does cleanup happen?).
- Test argument parsing edges: `--flag=value` vs `--flag value`, short-flag bundling, repeated flags, flags after a `--` separator, missing required positional args, extra unexpected args.
- Compare config-file precedence against what's documented: env var vs. flag vs. config file vs. default, in the order the docs claim.
- Run with no network (if it's supposed to work offline) and with a slow/flaky network (if it's supposed to retry) to check documented resilience claims.
- Check the exact text of error messages a first-time user would hit (missing required input, bad path, permission denied) for whether they explain the actual problem.
