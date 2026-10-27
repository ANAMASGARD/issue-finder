# Project types: environment choice and how a real user drives each one

Pick the lightest environment that actually exercises the code. Never default to a container or VM out of caution alone; the invariants below are what force a heavier environment, not habit.

**Default:** the project's own documented dev setup, with project-local dependencies (`venv`, `node_modules`, `cargo`'s target dir, Go modules). Run `scripts/detect-project.sh` first and read what it finds before choosing.

**Use the project's own compose file or devcontainer** when it ships one, or the project needs a sibling service (database, queue, cache) to do anything real.

**Use a container or VM only when:** install needs root or system packages outside the project directory; the code changes system state (installs a service, edits system config, needs elevated privileges); or install hooks (`postinstall`, `setup.py` with arbitrary code) can't be reviewed before running.

**Never, regardless of project type:** touch real user accounts, real cloud resources, real payment rails, or any production system. Use temp directories, bundled fixtures, emulators, local test credentials, and `--dry-run` flags. If a documented feature can only be verified against a live third-party service, say so as a stated testing boundary instead of using real credentials.

## By type

**CLI.** Recognize: a `bin` field, a `cmd/` or `bin/` directory, a single executable entrypoint. Drive it: run `--help`, then every documented subcommand and flag from the README/examples, including combinations the docs show together. Typical bugs: flags that parse but do nothing, exit codes that don't match documented behavior, piped stdin/stdout edge cases, missing or wrong error messages on bad input.

**Library/SDK.** Recognize: published to a package registry, no standalone entrypoint, consumed via import. Drive it: write a small throwaway program using every documented public function/class exactly as the README/examples show, including the documented edge cases (empty input, boundary values, the error path the docs describe). Typical bugs: a documented example that doesn't actually run, a type signature that doesn't match runtime behavior, an edge case the docs promise handling for but the code doesn't.

**Web UI.** Recognize: a frontend framework config, a `public/` or `index.html` entrypoint. Drive it: install, start the dev server, and click through every documented user flow with a real browser tool (navigate, snapshot the accessibility tree, click, type, read console and network). Typical bugs: a documented flow that 404s or throws in the console, a form that submits but silently fails, state that doesn't survive a reload.

**HTTP/API service.** Recognize: a server entrypoint, route definitions, an OpenAPI/Swagger file. Drive it: start it locally, then call every documented endpoint with `curl` using the documented request shapes, including the documented error responses. Typical bugs: a documented endpoint that 500s, a response shape that doesn't match the docs, missing input validation on a documented-as-required field.

**Full-stack app.** Recognize: both a web UI and an API/service layer in the same repo. Drive it: start the whole stack per its own docs (often a single compose file or a documented multi-process dev command), then treat it as a Web UI from the browser while watching the API/service logs. Typical bugs: a client-side success state that doesn't match what actually persisted server-side.

**Mobile (iOS/Android).** Recognize: `ios/`, `android/`, or a cross-platform framework config (Flutter, React Native, Expo). Drive it: build and run on the documented simulator/emulator target; a physical device is out of scope unless the user explicitly has one connected. Typical bugs: a documented gesture or screen that crashes, state lost on backgrounding, a permission flow that doesn't match the docs.

**Desktop app.** Recognize: an Electron/Tauri/native GUI toolkit config. Drive it: build and launch it in a virtual display (`xvfb-run` or equivalent) if no display is available, then exercise it the same way as a Web UI, via accessibility tree and screenshots. Typical bugs: a menu action that does nothing, a dialog that can't be dismissed, state not persisted between launches.

**Infra/IaC (Terraform, Helm, Kubernetes manifests, Pulumi).** Recognize: `*.tf`, `Chart.yaml`, raw manifests, a Pulumi program. Drive it: `plan`/`diff`/`template`/`lint` against a local or disposable target (never a real cloud account unless the user explicitly provides a sandboxed one); read every value the docs claim is configurable and confirm it actually reaches the rendered output. Typical bugs: a documented value that's silently ignored, a default that contradicts the docs, a resource missing from one environment's overlay that exists in another's.

**Data/language tooling (linters, formatters, codegen, query engines).** Recognize: operates on other people's source files or data rather than being an end-user app itself. Drive it: run it against both the project's own fixtures and a small file you write matching each documented rule/transform. Typical bugs: a documented rule that doesn't fire, a false positive on correct code, output that doesn't match a documented format exactly.

**Browser extension / editor plugin.** Recognize: a manifest file for the specific host (extension `manifest.json`, a `package.json` with an editor-plugin engine field). Drive it: load it unpacked into the documented host application and exercise every documented command/menu entry. Typical bugs: a documented keybinding that doesn't fire, a permission the manifest doesn't declare that the code actually needs.
