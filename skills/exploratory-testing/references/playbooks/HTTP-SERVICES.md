# Playbook: HTTP APIs and backend services

- Drive the real API with `curl` or an authenticated `fetch`/HTTP client, not by reading the handler code and guessing. Capture the exact request and response for every journey.
- Check documented response schemas against actual responses: extra undocumented fields, missing documented fields, wrong types, inconsistent error-body shape across endpoints.
- Test pagination explicitly: first page, last page, a page number past the end, a negative or zero page size, and whether total counts are consistent across pages if the underlying data changes mid-pagination.
- Test idempotency on anything documented as idempotent (repeat the same request with the same idempotency key/ID and check for duplicate side effects).
- Test authentication and authorization boundaries directly: an unauthenticated request to a protected endpoint, a request with another user's resource ID, a request with an expired or malformed token. Record exact status codes and bodies.
- Test rate limiting and retries if documented: does the documented limit actually trigger, and does the documented retry-after behavior match what's returned?
- Test content negotiation and malformed input: wrong `Content-Type`, truncated body, deeply nested or oversized JSON, if the API accepts arbitrary payload shapes.
- For webhooks: test signature verification (a request with a missing or wrong signature should be rejected, not processed), and replay of a previously-seen payload.
