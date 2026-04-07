---
name: dev-status
description: Use when checking project progress — read-only dashboard of issues, milestones, and board status
---

# dev-status: Project Dashboard

Read-only status view: scan implementation docs, milestone stats, board columns.

**Read-only** — this skill makes no changes to code, branches, or board.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/project-init` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}` / `{config.repo.main_branch}`
- `{config.github.project_id}`
- `{config.github.status_field_id}`

---

## STEP 2 — Milestone Summary

[SHELL] Fetch milestones:
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/milestones?state=all" \
  --jq '.[] | {title: .title, open: .open_issues, closed: .closed_issues, due: .due_on, state: .state}'
```

Display:
```
Milestones
═══════════════════════════════════════
Milestone          | Open | Closed | %    | Due        | State
───────────────────┼──────┼────────┼──────┼────────────┼──────
v0.1 — Core        |  0   |   5    | 100% | 2026-04-15 | closed
v0.2 — Auth        |  3   |   2    |  40% | 2026-05-01 | open
```

---

## STEP 3 — Board Column Counts

[SHELL] Query project board via GraphQL:
```bash
gh api graphql -f query='
  query {
    node(id: "{config.github.project_id}") {
      ... on ProjectV2 {
        items(first: 100) {
          nodes {
            fieldValues(first: 10) {
              nodes {
                ... on ProjectV2ItemFieldSingleSelectValue {
                  name
                }
              }
            }
          }
        }
      }
    }
  }'
```

Count items per status column.

Display:
```
Project Board
═══════════════════════════════════════
Todo          : <count>
In Progress   : <count>
Done          : <count>
```

---

## STEP 4 — Active Branches

[SHELL] List feature/fix branches:
```bash
git branch -r --format="%(refname:short)|%(committerdate:short)" | grep -E "^origin/(feature|fix)/"
```

Display:
```
Active Branches
═══════════════════════════════════════
Branch                          | Issue | Last Commit
────────────────────────────────┼───────┼────────────
origin/feature/42-add-login     | #42   | 2026-04-07
origin/fix/51-rate-limit        | #51   | 2026-04-06
```

---

## STEP 5 — Implementation Doc Scan

[SHELL] Find all implementation docs:
```bash
find docs/plans -name "implementation.md" 2>/dev/null
```

[READ] each found file. Extract the progress table — count steps by status (`done` / `pending`).

Display:
```
Implementation Progress
═══════════════════════════════════════
Issue  | Title            | Done | Total | %
───────┼──────────────────┼──────┼───────┼──────
#42    | Add login        |  4   |   6   |  67%
#51    | Fix rate limit   |  1   |   4   |  25%
```

If no implementation docs found:
> No implementation docs found in docs/plans/.

---

## STEP 6 — Open PRs

[SHELL] List open PRs:
```bash
gh pr list --json number,title,headRefName,statusCheckRollup,reviewDecision \
  --jq '.[] | {number, title, branch: .headRefName, ci: (.statusCheckRollup // [] | map(.conclusion) | unique | join(",")), review: (.reviewDecision // "PENDING")}'
```

Display:
```
Open Pull Requests
═══════════════════════════════════════
PR   | Title            | CI      | Review
─────┼──────────────────┼─────────┼────────
#45  | feat: add login  | SUCCESS | APPROVED
#53  | fix: rate limit  | FAILURE | PENDING
```

If no open PRs:
> No open pull requests.

---

## STEP 7 — Display Dashboard

Combine all sections into a single formatted output:

```
Project Dashboard — {config.repo.owner}/{config.repo.name}
════════════════════════════════════════════════════════════

<Milestones section>

<Board section>

<Active Branches section>

<Implementation Progress section>

<Open PRs section>
```

No handoff — this is an informational skill.
