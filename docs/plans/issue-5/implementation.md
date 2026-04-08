---
issue: 5
title: "feat: add version-aware planning workflow for major version cycles"
branch: feature/5-version-aware-planning-workflow
status: pending
---

# Implementation Doc — Issue #5

## Progress

| Step | Description | Status |
|------|-------------|--------|
| 1 | Update `.paadhai.json` — add `project_version` field | done |
| 2 | Update `/project-init` — add target version question | done |
| 3 | Update `/project-plan` — version-aware SRS paths | done |
| 4 | Update `/release-plan` — version-scoped milestones | done |

---

## Step 1: Update `.paadhai.json` — add `project_version` field

**Action**: Edit `.paadhai.json` to add a `project_version` field at root level.

**Change**: Add `"project_version": "1.0"` after the existing `"version": "1"` line.

**Before** (lines 1-3):
```json
{
  "version": "1",
  "repo": {
```

**After**:
```json
{
  "version": "1",
  "project_version": "1.0",
  "repo": {
```

**Expected outcome**: `.paadhai.json` has a `project_version` field. All existing skills ignore it (they don't read it yet). No breaking change.

---

## Step 2: Update `/project-init` — add target version question

**File**: `.claude/skills/project-init/SKILL.md`

### 2a: Add question to Step 3

**Action**: In **Step 3 — Gather Project Info**, add a new question to both the "New project" and "Existing project" lists.

**New project list — append after "Create new project board or use existing?"**:
```markdown
- Target product version? (leave blank for first release)
```

**Existing project list — append after "Ask user to confirm or override each"**:
```markdown
- Target product version? (leave blank to keep current or omit)
```

### 2b: Add field to Step 6 JSON template

**Action**: In **Step 6 — Execute**, update the `.paadhai.json` template to include `project_version`.

**Add after `"version": "1",` line in the JSON template**:
```json
  "project_version": "{project_version}",
```

**Add a note below the JSON block**:
```markdown
> If the user left target version blank, omit the `project_version` field entirely.
```

**Expected outcome**: Running `/project-init` now asks for target version and writes it to config. Blank = field omitted = backward compatible.

---

## Step 3: Update `/project-plan` — version-aware SRS paths

**File**: `.claude/skills/project-plan/SKILL.md`

### 3a: Update Step 1 — derive SRS path from config

**Action**: Replace the current Step 1 content with version-aware path derivation.

**Current Step 1**:
```markdown
## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.
```

**New Step 1**:
```markdown
## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Derive SRS output path from config:
- If `project_version` exists → `{srs_path}` = `docs/srs-v{project_version}.md`
- If `project_version` absent → `{srs_path}` = `docs/srs.md`
```

### 3b: Update Step 2 — load prior SRS as context

**Action**: Add prior SRS loading logic to Step 2.

**Current Step 2**:
```markdown
## STEP 2 — Read Existing Context

[READ] any existing docs in `docs/` or source files if project has code already. Understand current state before asking questions.
```

**New Step 2**:
```markdown
## STEP 2 — Read Existing Context

[READ] any existing docs in `docs/` or source files if project has code already. Understand current state before asking questions.

If `project_version` is set in config:
- [READ] Look for prior SRS files: glob `docs/srs-v*.md` and `docs/srs.md`
- If a prior SRS exists, load it as context and display:
  > Loaded prior SRS (`{prior_srs_filename}`) as reference for delta planning.
- Use the prior SRS to understand existing features, so the user can focus on what's new or changed in this version.
```

### 3c: Update Step 9 — save to derived path

**Action**: Replace hardcoded `docs/srs.md` with `{srs_path}`.

**Current Step 9**:
```markdown
## STEP 9 — Save

[WRITE] Save SRS to `docs/srs.md`.

[SHELL] Commit:
\```bash
git add docs/srs.md
git commit -m "docs(srs): add confirmed SRS

Refs: product description confirmed by user."
\```
```

**New Step 9**:
```markdown
## STEP 9 — Save

[WRITE] Save SRS to `{srs_path}`.

[SHELL] Commit:
\```bash
git add {srs_path}
git commit -m "docs(srs): add confirmed SRS for v{project_version}

Refs: product description confirmed by user."
\```

> If no `project_version`, commit message omits the version suffix: `"docs(srs): add confirmed SRS"`.
```

### 3d: Update Step 10 — handoff with actual path

**Current Step 10**:
```markdown
## STEP 10 — Handoff

\```
SRS saved to docs/srs.md.
Next step: run /release-plan to create your GitHub project milestones and issues.
\```
```

**New Step 10**:
```markdown
## STEP 10 — Handoff

\```
SRS saved to {srs_path}.
Next step: run /release-plan to create your GitHub project milestones and issues.
\```
```

**Expected outcome**: `/project-plan` saves versioned SRS files, loads prior SRS as context, and all references use the derived path.

---

## Step 4: Update `/release-plan` — version-scoped milestones

**File**: `.claude/skills/release-plan/SKILL.md`

### 4a: Update Step 1 — version-aware SRS loading

**Action**: Replace hardcoded `docs/srs.md` with version-aware path derivation.

**Current Step 1**:
```markdown
## STEP 1 — Load Config + SRS

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

[READ] `docs/srs.md` — hard stop if missing:

> No SRS found at docs/srs.md. Run `/paadhai:project-plan` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.github.project_id}` / `{config.github.status_field_id}` / `{config.github.statuses.todo}`
```

**New Step 1**:
```markdown
## STEP 1 — Load Config + SRS

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Derive SRS path from config:
- If `project_version` exists → `{srs_path}` = `docs/srs-v{project_version}.md`
- If `project_version` absent → `{srs_path}` = `docs/srs.md`

[READ] `{srs_path}` — hard stop if missing:

> No SRS found at {srs_path}. Run `/paadhai:project-plan` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.github.project_id}` / `{config.github.status_field_id}` / `{config.github.statuses.todo}`
- `{config.project_version}` (if present)
```

### 4b: Update Step 2 — version-scoped milestone naming

**Action**: Add version-aware milestone naming logic.

**Current Step 2**:
```markdown
## STEP 2 — Analyze Requirements

Read all functional requirements (FR-*) in the SRS. Group them into milestones by logical delivery increments (e.g., v0.1 — Core, v0.2 — API, v0.3 — Release).

Rules:
- Each milestone should be independently shippable
- Each milestone should take roughly equal effort
- Dependencies between milestones should be explicit
```

**New Step 2**:
```markdown
## STEP 2 — Analyze Requirements

Read all functional requirements (FR-*) in the SRS. Group them into milestones by logical delivery increments.

Milestone naming uses the project version as a base:
- If `project_version` = `"2.0"` → milestones: `v2.1 — Name`, `v2.2 — Name`, `v2.3 — Name`
- If `project_version` absent → milestones: `v0.1 — Name`, `v0.2 — Name`, `v0.3 — Name` (current behavior)

Rules:
- Each milestone should be independently shippable
- Each milestone should take roughly equal effort
- Dependencies between milestones should be explicit
```

### 4c: Update Step 4 — presentation reflects version

**Action**: Update the example in Step 4 to show version-aware milestones.

**Current example line in Step 4**:
```
Milestone v0.1 — <name> (<n> issues)
```

**New example**:
```
Milestone v{major}.1 — <name> (<n> issues)
```

No other changes to Step 4 — the display template already uses the milestone title dynamically.

**Expected outcome**: `/release-plan` reads the versioned SRS and creates milestones prefixed with the correct major version.

---

## Deviations

_(none)_
