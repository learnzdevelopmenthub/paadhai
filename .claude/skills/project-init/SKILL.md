---
name: project-init
description: Use when setting up a new or existing project — verify GitHub access, initialize repo, write .paadhai.json
---

# project-init: Project Setup

Set up a new or existing GitHub project, write `.paadhai.json`, create branches and project board.

---

## STEP 1 — Verify Prerequisites

[SHELL] Check GitHub CLI auth:
```bash
gh auth status
```

Display authenticated account. If fails → stop:
> GitHub CLI not authenticated. Run `gh auth login` first.

[SHELL] Check if git repo exists:
```bash
git rev-parse --is-inside-work-tree 2>/dev/null || echo "not-a-repo"
```

If not a repo → `git init`.

---

## STEP 2 — Detect Existing Project

[SHELL] Check for existing GitHub remote:
```bash
git remote get-url origin 2>/dev/null || echo "no-remote"
```

If remote exists → **Existing Project Flow** (Step 2b).
If no remote → **New Project Flow** (continue to Step 3).

### Step 2b — Existing Project Detection

[SHELL] Extract owner/repo from remote URL:
```bash
git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/'
```

[SHELL] Verify repo on GitHub:
```bash
gh repo view {owner/repo} --json name,owner,defaultBranchRef,isPrivate
```

[DELEGATE][FAST-MODEL] Auto-detect existing setup:
- Default branch name
- Does `develop` branch exist?
- Open milestones (count + titles)
- Open issues (count)
- Project boards linked to repo

Display detected values to user.

---

## STEP 3 — Gather Project Info

Single input round — ask all questions at once.

**New project:**
- Repo name (will be created on GitHub)?
- Visibility: public or private?
- Branch strategy: develop → main (default) or other?
- Language / framework?
- Build command (e.g., `npm run build`, `cargo build`, `make`)?
- Lint command (e.g., `npm run lint`, `cargo clippy`)?
- Test command (e.g., `npm test`, `cargo test`, `pytest`)?
- Create new project board or use existing?
- Target product version? (leave blank for first release)

**Existing project:**
- Pre-fill all detected values from Step 2b
- Ask user to confirm or override each
- Target product version? (leave blank to keep current or omit)

---

## STEP 4 — Discover Project Board IDs

If using a GitHub project board:

[DELEGATE][FAST-MODEL] List projects:
```bash
gh project list --owner {owner} --format json
```

Find the target project. Then query field IDs:
```bash
gh api graphql -f query='{ 
  organization(login: "{owner}") { 
    projectV2(number: {project_number}) { 
      id
      fields(first: 20) { 
        nodes { 
          ... on ProjectV2SingleSelectField { 
            id name options { id name } 
          } 
        } 
      } 
    } 
  } 
}'
```

Extract: `project_id`, `status_field_id`, and option IDs for "Todo", "In Progress", "Done".

---

## STEP 5 — Action Summary + Human Gate

Display ALL planned actions:

```
Actions to perform:
─────────────────────────────────────────────
Repo          : {owner}/{repo-name} [create / already exists]
.paadhai.json : Will write to project root
  {full .paadhai.json content}

Branches      : develop [create / already exists], main [already exists]
Project board : {board-name} [create / link existing]
─────────────────────────────────────────────
```

For existing projects — clearly mark:
- `[no action]` for things that already exist
- `[will create]` for new things

**G-01: "Proceed with setup? (yes/no)"**

Wait for explicit "yes".

---

## STEP 6 — Execute (after G-01)

All at once — no intermediate confirmations.

[WRITE] `.paadhai.json` to project root:
```json
{
  "version": "1",
  "project_version": "{project_version}",
  "repo": {
    "owner": "{owner}",
    "name": "{repo-name}",
    "develop_branch": "develop",
    "main_branch": "main"
  },
  "github": {
    "project_id": "{project_id}",
    "project_number": {project_number},
    "status_field_id": "{status_field_id}",
    "statuses": {
      "todo": "{todo_option_id}",
      "in_progress": "{in_progress_option_id}",
      "done": "{done_option_id}"
    }
  },
  "stack": {
    "language": "{language}",
    "build_cmd": "{build_cmd}",
    "lint_cmd": "{lint_cmd}",
    "test_cmd": "{test_cmd}"
  },
  "branches": {
    "feature": "feature/",
    "fix": "fix/",
    "release": "release/"
  }
}
```

> If the user left target version blank, omit the `project_version` field entirely.

[SHELL] Create GitHub repo (new projects only):
```bash
gh repo create {repo-name} --{public|private} --source=. --remote=origin --push
```

[SHELL] Create `develop` branch (if missing):
```bash
git checkout -b develop
git push -u origin develop
```

[DELEGATE][FAST-MODEL] Create or link project board (if needed).

---

## STEP 7 — Branch Protection (Optional)

**G-16: "Enable branch protection rules on main and develop? (yes/skip)"**

If **skip** → proceed to Step 8.

If **yes** → apply protection via GitHub API:

[SHELL] Protect `{config.repo.main_branch}` (require PR review + CI, no force push):
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/branches/{config.repo.main_branch}/protection" \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

[SHELL] Protect `{config.repo.develop_branch}` (require CI, no force push):
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/branches/{config.repo.develop_branch}/protection" \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews=null \
  --field restrictions=null
```

If either API call fails (e.g., free-plan repository limitation) → warn and skip gracefully:
> Branch protection requires a paid GitHub plan for private repos. Skipping.

---

## STEP 8 — Display Results

```
✓ Repo          : https://github.com/{owner}/{repo-name}
✓ .paadhai.json : written
✓ develop       : pushed to origin
✓ Project board : {board-url}
✓ Branch protection: <enabled / skipped>
```

---

## STEP 9 — Smart Handoff

- **New project, no SRS** → "Run /project-plan to define your requirements."
- **Existing project, no SRS** → "Run /project-plan to create the SRS."
- **Existing project, SRS exists, no issues** → "Run /release-plan to create milestones and issues."
- **Existing project, issues exist** → "Run /dev-start #<issue-number> to begin development."
