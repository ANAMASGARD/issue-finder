# Playbook: Kubernetes, Helm, controllers, and infrastructure tooling

- Render manifests/charts with `helm template` (or the project's own render path) and check the rendered output directly, not just the template source: wrong indentation, missing resource names, malformed selectors, and values that never reach the field they're documented to control are all visible only in the rendered output.
- Install into a real (kind/minikube/disposable) cluster where the sandbox supports it, rather than trusting template rendering alone to prove runtime behavior; a rendered manifest proves rendering, not scheduling, RBAC enforcement, or networking.
- Test upgrade and rollback explicitly: install an older supported version, upgrade in place, and check that state/config survives; then roll back and check the same.
- Test a controller's reconciliation loop for idempotency: apply the same resource twice, delete and recreate rapidly, and check for duplicate side effects or a stuck state.
- Test RBAC boundaries: apply as a service account with only the documented minimum permissions and confirm the documented feature actually works with exactly that permission set, no more.
- Test resource cleanup on deletion: delete the top-level resource and check whether everything it created (PVCs, secrets, child resources) is actually cleaned up, or left orphaned.
- Where an operator restarts or the cluster API is briefly unavailable, test reconnect and watch-recovery behavior rather than assuming it.
