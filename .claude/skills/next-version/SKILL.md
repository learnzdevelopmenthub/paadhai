---
name: next-version
description: Use when bumping the project to a new major version — updates .paadhai.json, commits, and optionally chains into /project-plan → /release-plan
---

# next-version: Bump Project Version

Bump project_version in .paadhai.json, validate semver, commit, and optionally chain the planning pipeline.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.project_version}` (current version)

---

## STEP 2 — Display Current Version

Display:
```
Current project_version: {config.project_version}
```

Ask user: **"What is the new version?"** (e.g., `2.0`, `3.0`)

---

## STEP 3 — Validate New Version

Check:
- Format must be valid semver major.minor (e.g., `2.0`, `3.1`)
- New version must be greater than `{config.project_version}`

If invalid → display error and re-ask.

---

## STEP 4 — Action Summary + Human Gate

Display:
```
Version Bump
═══════════════════════════
Current : {config.project_version}
New     : <new-version>
File    : .paadhai.json
```

**G-22: "Bump version and commit? (yes/no)"**

Wait for explicit user confirmation. Do not proceed without "yes".

---

## STEP 5 — Execute (after G-22 approval)

[READ] `.paadhai.json`

[WRITE] Update `project_version` field to the new version in `.paadhai.json`.

[SHELL] Commit the change:
```bash
git add .paadhai.json
git commit -m "chore: bump project_version to <new-version>"
```

---

## STEP 6 — Display Results

```
✓ project_version : <old-version> → <new-version>
✓ Committed       : chore: bump project_version to <new-version>
```

---

## STEP 7 — Handoff

Ask: **"Continue to /project-plan → /release-plan? (yes/no)"**

- **yes** → tell user to run `/project-plan`
- **no** → done

```
Version bumped. Next steps when ready:
  1. /project-plan — generate SRS for v<new-version>
  2. /release-plan — create milestones + issues
```

Do not start planning here. This skill's job is done.
