---
issue: 9
title: Implement skill invocation announcement banners
branch: feature/9-skill-invocation-banners
status: pending
---

## Progress

| Step | Description | Status |
|------|-------------|--------|
| 1 | Define preamble templates | done |
| 2 | Insert preamble into issue-aware skills (14 files) | done |
| 3 | Insert preamble into non-issue skills (8 files) | done |
| 4 | Verify all 22 skills have preamble | done |

---

## Step 1 — Define preamble templates

**Status:** pending

Two preamble variants will be used. They are inserted between the last `---` before `## STEP 1` and `## STEP 1` itself in each SKILL.md.

### Variant A: Issue-aware preamble

Used for skills that typically run on a feature/fix branch tied to an issue:
`dev-adr`, `dev-audit`, `dev-debug`, `dev-docs`, `dev-hotfix`, `dev-implement`, `dev-parallel`, `dev-plan`, `dev-pr`, `dev-ship`, `dev-start`, `dev-test`, `dev-unblock`, `dev-rollback`

Template (placeholders `<SKILL-NAME>` and `<N>` are replaced per skill):

```markdown
## PREAMBLE — Announcement Banner

[SHELL] Detect context:
```bash
BRANCH=$(git branch --show-current)
```

If branch matches `feature/*` or `fix/*`:
- Extract issue number from branch name (e.g., `feature/42-add-login` → `42`)
- [SHELL] Fetch issue title:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> --jq '.title'
```

Display (with issue context):
```
────────────────────────────────────────
<SKILL-NAME> | Issue #<number> — <title>
<N> steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
<SKILL-NAME>
<N> steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---
```

### Variant B: Non-issue preamble

Used for skills that don't operate on a specific issue:
`dev-deps`, `dev-release`, `dev-status`, `next-version`, `paadhai-skill`, `project-init`, `project-plan`, `release-plan`

Template:

```markdown
## PREAMBLE — Announcement Banner

[SHELL] Detect context:
```bash
BRANCH=$(git branch --show-current)
```

Display:
```
────────────────────────────────────────
<SKILL-NAME>
<N> steps | Branch: <branch>
────────────────────────────────────────
```

---
```

**Expected output:** Two reusable text templates ready for insertion. No files changed yet.

---

## Step 2 — Insert preamble into issue-aware skills (14 files)

**Status:** pending

For each of the following 14 skills, insert **Variant A** preamble between the last `---` separator and `## STEP 1`. Replace `<SKILL-NAME>` with the skill name and `<N>` with the step count.

| Skill | Name in banner | Steps |
|-------|---------------|-------|
| `.claude/skills/dev-adr/SKILL.md` | dev-adr | 10 |
| `.claude/skills/dev-audit/SKILL.md` | dev-audit | 7 |
| `.claude/skills/dev-debug/SKILL.md` | dev-debug | 11 |
| `.claude/skills/dev-docs/SKILL.md` | dev-docs | 8 |
| `.claude/skills/dev-hotfix/SKILL.md` | dev-hotfix | 12 |
| `.claude/skills/dev-implement/SKILL.md` | dev-implement | 10 |
| `.claude/skills/dev-parallel/SKILL.md` | dev-parallel | 14 |
| `.claude/skills/dev-plan/SKILL.md` | dev-plan | 17 |
| `.claude/skills/dev-pr/SKILL.md` | dev-pr | 8 |
| `.claude/skills/dev-ship/SKILL.md` | dev-ship | 7 |
| `.claude/skills/dev-start/SKILL.md` | dev-start | 8 |
| `.claude/skills/dev-test/SKILL.md` | dev-test | 11 |
| `.claude/skills/dev-unblock/SKILL.md` | dev-unblock | 8 |
| `.claude/skills/dev-rollback/SKILL.md` | dev-rollback | 8 |

**Exact edit per file:** Find the `---` line immediately before `## STEP 1` and insert the preamble block after it (before `## STEP 1`).

For example, in `dev-start/SKILL.md` (Step 1 at line 14), the edit replaces:

```
---

## STEP 1 — Load Config
```

with:

```
---

## PREAMBLE — Announcement Banner

[SHELL] Detect context:
```bash
BRANCH=$(git branch --show-current)
```

If branch matches `feature/*` or `fix/*`:
- Extract issue number from branch name (e.g., `feature/42-add-login` → `42`)
- [SHELL] Fetch issue title:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> --jq '.title'
```

Display (with issue context):
```
────────────────────────────────────────
dev-start | Issue #<number> — <title>
8 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-start
8 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## STEP 1 — Load Config
```

Repeat for all 14 skills, substituting skill name and step count per the table above.

**Expected output:** 14 SKILL.md files modified, each containing `## PREAMBLE — Announcement Banner` before `## STEP 1`.

---

## Step 3 — Insert preamble into non-issue skills (8 files)

**Status:** pending

For each of the following 8 skills, insert **Variant B** preamble:

| Skill | Name in banner | Steps |
|-------|---------------|-------|
| `.claude/skills/dev-deps/SKILL.md` | dev-deps | 8 |
| `.claude/skills/dev-release/SKILL.md` | dev-release | 14 |
| `.claude/skills/dev-status/SKILL.md` | dev-status | 7 |
| `.claude/skills/next-version/SKILL.md` | next-version | 7 |
| `.claude/skills/paadhai-skill/SKILL.md` | paadhai-skill | 13 |
| `.claude/skills/project-init/SKILL.md` | project-init | 9 |
| `.claude/skills/project-plan/SKILL.md` | project-plan | 10 |
| `.claude/skills/release-plan/SKILL.md` | release-plan | 8 |

**Exact edit per file:** Same insertion point — between `---` and `## STEP 1`.

For example, in `dev-status/SKILL.md`:

```
---

## PREAMBLE — Announcement Banner

[SHELL] Detect context:
```bash
BRANCH=$(git branch --show-current)
```

Display:
```
────────────────────────────────────────
dev-status
7 steps | Branch: <branch>
────────────────────────────────────────
```

---

## STEP 1 — Load Config
```

Repeat for all 8 skills with correct name and step count.

**Expected output:** 8 SKILL.md files modified, each containing `## PREAMBLE — Announcement Banner` before `## STEP 1`.

---

## Step 4 — Verify all 22 skills have preamble

**Status:** pending

[SHELL] Count skills with preamble:
```bash
grep -rl "## PREAMBLE" .claude/skills/*/SKILL.md | wc -l
```

**Expected output:** `22`

[SHELL] Verify no skill is missing:
```bash
for d in .claude/skills/*/SKILL.md; do
  if ! grep -q "## PREAMBLE" "$d"; then
    echo "MISSING: $d"
  fi
done
```

**Expected output:** No output (all files have the preamble).

[SHELL] Spot-check banner format in 3 files:
```bash
grep -A 15 "## PREAMBLE" .claude/skills/dev-start/SKILL.md | head -20
grep -A 15 "## PREAMBLE" .claude/skills/dev-status/SKILL.md | head -20
grep -A 15 "## PREAMBLE" .claude/skills/dev-implement/SKILL.md | head -20
```

**Expected output:** Each shows the correct skill name, step count, and box-drawing `────` format.

---

## Deviations

(none)
