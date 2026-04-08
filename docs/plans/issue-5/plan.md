---
issue: 5
title: "feat: add version-aware planning workflow for major version cycles"
branch: feature/5-version-aware-planning-workflow
milestone: null
status: confirmed
confirmed_at: 2026-04-08
---

# Plan — Issue #5: Version-Aware Planning Workflow

## Overview

Add version awareness to the planning pipeline (`/project-plan` → `/release-plan`) so users can plan multiple major versions without overwriting prior SRS artifacts or milestone naming.

## Files to Modify

| File | What Changes |
|------|-------------|
| `.paadhai.json` | Add `project_version` field at root level |
| `.claude/skills/project-init/SKILL.md` | Add "Target version?" question in Step 3, include `project_version` in Step 6 JSON template |
| `.claude/skills/project-plan/SKILL.md` | Version-aware SRS path derivation, load prior SRS as context, update output/handoff references |
| `.claude/skills/release-plan/SKILL.md` | Version-scoped SRS loading, version-scoped milestone naming, update handoff |

## Implementation Steps

### Step 1: Update `.paadhai.json` schema
- Add `"project_version": "1.0"` field at root level (alongside existing `"version": "1"`)
- `version` = Paadhai config schema version, `project_version` = user's product version

### Step 2: Update `/project-init` (SKILL.md)
- **Step 3**: Add question: "Target product version? (leave blank for first release)"
- **Step 6**: Add `project_version` field to the JSON template (omit if blank)

### Step 3: Update `/project-plan` (SKILL.md)
- **Step 1**: After loading config, derive SRS path:
  - If `project_version` exists → `docs/srs-v{project_version}.md`
  - If absent → `docs/srs.md` (backward compat)
- **Step 2**: If versioned, also load the previous version's SRS (glob `docs/srs-v*.md` or `docs/srs.md`) as context. Display: "Loaded v{prev} SRS as reference for delta planning."
- **Step 9**: Save to the derived path
- **Step 10**: Update handoff message with actual path

### Step 4: Update `/release-plan` (SKILL.md)
- **Step 1**: Derive SRS path same way as project-plan. Hard stop if the versioned file is missing.
- **Step 2**: Milestone naming uses version prefix:
  - If `project_version` = `"2.0"` → milestones: `v2.1 — Name`, `v2.2 — Name`
  - If absent → current behavior: `v0.1 — Name`, `v0.2 — Name`
- **Step 4**: Presentation reflects version-scoped milestones

## Test Cases

- **Happy path**: Set `project_version: "2.0"`, run project-plan → SRS saved as `docs/srs-v2.0.md`, run release-plan → milestones named `v2.1`, `v2.2`
- **Backward compat**: No `project_version` in config → both skills behave exactly as today (`docs/srs.md`, milestones `v0.1`)
- **Prior SRS context**: With `project_version: "2.0"` and existing `docs/srs.md`, project-plan loads it as reference automatically

## Security Considerations

No security-relevant attack surfaces identified for this issue.

## AC Mapping

| AC | How Addressed |
|----|--------------|
| `.paadhai.json` includes `project_version` | Step 1 — add field |
| `/project-plan` saves versioned SRS files and loads prior SRS | Step 3 — path derivation + prior SRS loading |
| `/release-plan` creates version-scoped milestones | Step 4 — version prefix in milestone names |
| Existing v1 artifacts preserved | Steps 3-4 — new files, no overwrites |
| Backward compatible | Steps 2-4 — all changes gated on `project_version` existence |

## Definition of Done

- [ ] All ACs checked
- [ ] Skills with no `project_version` behave identically to current behavior
- [ ] Versioned SRS path works end-to-end in both skills
