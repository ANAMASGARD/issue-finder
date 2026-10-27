# Forge-specific search recipes

## GitHub (`gh`)

Scoped to the current repo:

```bash
gh issue list --search '"<exact error text>" in:title,body' --state all -L 100
gh pr list --search '<keywords>' --state all -L 100
```

Across all of GitHub or a specific org, using GitHub's search index and qualifier flags:

```bash
gh search issues '<keywords>' --repo <owner>/<repo> --state all
gh search issues '<keywords>' --owner <org> --match title,body
gh search prs '<keywords>' --repo <owner>/<repo> --state all
```

Raw REST for structured JSON, pagination, or counts beyond `gh`'s defaults:

```bash
gh api search/issues -f q='<keywords> repo:<owner>/<repo> is:issue' --paginate --jq '.items[] | {title, html_url, state}'
```

Useful qualifiers: `is:issue` / `is:pr`, `state:open` / `state:closed`, `in:title,body,comments` (omit `in:` to search all three), `label:"..."`, `linked:pr` / `linked:issue`, `reason:completed` / `reason:"not planned"` for why a closed issue was closed.

GitHub Security Advisories, for security-sensitive candidates:

```bash
gh api graphql -f query='{ securityAdvisories(first: 20, orderBy: {field: PUBLISHED_AT, direction: DESC}) { nodes { summary permalink } } }'
```

Or check `https://github.com/<owner>/<repo>/security/advisories` directly.

## GitLab (`glab`), including self-hosted instances

```bash
glab issue list --search '<keywords>' --repo <owner>/<repo>
glab mr list --search '<keywords>' --repo <owner>/<repo>
```

For a self-hosted instance (e.g. `gitlab.gnome.org`), set the host explicitly:

```bash
glab issue list --repo gitlab.gnome.org/<group>/<project> --search '<keywords>'
```

If `glab` isn't configured for that host, fall back to the instance's own search UI/API: `https://<host>/api/v4/projects/<id>/issues?search=<keywords>&scope=all`.

## Gitea / Forgejo

REST search, no dedicated CLI assumed:

```bash
curl -s "https://<host>/api/v1/repos/<owner>/<repo>/issues?q=<keywords>&type=all&state=all"
```

## Bugzilla (used by Mozilla, GNOME-adjacent projects, others)

Use the instance's own advanced search (`<host>/buglist.cgi`) or REST API:

```bash
curl -s "https://<host>/rest/bug?quicksearch=<keywords>"
```

## Jira

```bash
curl -s -u "<user>:<token>" "https://<host>/rest/api/2/search?jql=text~%22<keywords>%22"
```

## Launchpad

```bash
curl -s "https://api.launchpad.net/devel/<project>?ws.op=searchTasks&search_text=<keywords>"
```

## Mailing lists

Many older projects (kernel-adjacent, GNU tools) triage primarily via mailing list, not a tracker. Search the project's public archive (often searchable via its own web UI, or indexed by `lore.kernel.org`-style tools for kernel-adjacent projects) for the exact error text and component name before concluding "no prior report" for such a project.

## OSV (Open Source Vulnerabilities), for security-sensitive candidates

```bash
curl -s -X POST "https://api.osv.dev/v1/query" -d '{"package": {"name": "<package>", "ecosystem": "<ecosystem>"}}'
```

## git history, for all forges

```bash
git log --grep='<keyword>' --oneline              # commit messages
git log -S'<exact symbol or literal>' --oneline    # commits that changed the count of occurrences
git log -G'<regex>' --oneline                      # commits whose diff touches matching text at all
git log -L<start>,<end>:<file>                     # full history of a specific line range
git blame -L<start>,<end> <file>                   # who last touched these lines, and when
```

`-S` finds only commits that changed how many times a string appears; `-G` finds any commit whose diff touches text matching the pattern, even if the count didn't change. Use both; they catch different things.
