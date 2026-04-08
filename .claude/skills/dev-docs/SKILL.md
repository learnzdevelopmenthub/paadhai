---
name: dev-docs
description: Use when generating project documentation — API reference, user guide, or architecture overview
---

# dev-docs: Documentation Generation

Generate API reference, user guide, or architecture documentation from the current codebase.

**Output:** `docs/api.md` / `docs/guide.md` / `docs/architecture.md`

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.stack.language}`
- `{config.repo.owner}` / `{config.repo.name}`

---

## STEP 2 — Determine Scope

Ask user:
> "What documentation should be generated?
> - **api** — API reference (endpoints, schemas, error codes)
> - **user** — User guide (getting started, configuration, examples)
> - **architecture** — Architecture overview (components, data flow, diagrams)
> - **all** — Generate all three"

Store: `<doc-scope>` = api / user / architecture / all

---

## STEP 3 — Read Codebase

[DELEGATE][FAST-MODEL] Scan the codebase based on selected scope:

**For `api`:** Read route/controller/handler files, schema definitions, middleware, error types. Target: 10+ files.

**For `user`:** Read README, configuration files, CLI entrypoints, example files, environment variables. Target: 5–10 files.

**For `architecture`:** Read entrypoint files, service/module boundaries, database models, config, deployment files. Target: 10–15 files.

**For `all`:** Read all of the above.

---

## STEP 4 — Generate Documentation

Generate documentation content based on scope:

**API (`docs/api.md`):**
```markdown
# API Reference

## Overview
<base URL, auth, versioning>

## Endpoints

### <METHOD> <path>
**Description:** <what it does>
**Auth:** <required / optional / none>

**Request:**
\`\`\`json
<request schema>
\`\`\`

**Response:**
\`\`\`json
<response schema>
\`\`\`

**Errors:**
| Code | Meaning |
|------|---------|
| 400 | <description> |

---
```

**User Guide (`docs/guide.md`):**
```markdown
# User Guide

## Getting Started
<prerequisites, installation steps>

## Configuration
| Variable | Required | Default | Description |
|----------|----------|---------|-------------|

## Usage
<common workflows with examples>

## Troubleshooting
<common issues and fixes>
```

**Architecture (`docs/architecture.md`):**
```markdown
# Architecture Overview

## System Components
<description of each major component>

## Component Diagram
\`\`\`mermaid
graph TD
  A[<component>] --> B[<component>]
\`\`\`

## Data Flow
<description + sequence diagram if applicable>

## Key Design Decisions
<major tradeoffs made>
```

---

## STEP 5 — Present Documentation

Show the generated documentation (or summary if very long).

**G-20: "Write this documentation to docs/? (yes / edit)"**

- **yes** → proceed to Step 6
- **edit** → take feedback, regenerate relevant sections, re-present

---

## STEP 6 — Write Documentation

[WRITE] Write the approved content:
- `api` scope → `docs/api.md`
- `user` scope → `docs/guide.md`
- `architecture` scope → `docs/architecture.md`
- `all` scope → all three files

---

## STEP 7 — Commit

[SHELL] Commit documentation:
```bash
git add docs/
git commit -m "docs(<scope>): generate <type> documentation

Auto-generated from codebase scan.

Refs: <scope> documentation"
```

Where `<scope>` = api / user / architecture / all.

---

## STEP 8 — Handoff

```
Documentation generated.
═══════════════════════════
Scope    : <scope>
Files    : <list of files written>
Gate     : G-20 approved

This is a standalone utility — no pipeline next step.
Re-run /dev-docs after major feature releases or architectural changes.
```
