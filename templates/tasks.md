---
issue: <number>
title: <title>
total_groups: <count>
---

# Tasks — Issue #<number>: <title>

> **Source artifact** for the Paadhai SDLC pipeline. Atomic, ordered tasks grouped for execution. Each group declares `parallel: true|false`. `dev-implement` reads this file and auto-routes parallel-flagged groups to `dev-parallel`.

## Overview

<1–2 sentence summary of the implementation strategy and how it's broken into groups.>

## Task Groups

Each group has a single `parallel` flag (true or false). All tasks within a group are sequential within the group regardless of the flag — the flag controls whether the GROUP can run in parallel with other groups.

### Group 1: <descriptive name>

**parallel: false**
**depends_on: none**

#### Task 1.1: <atomic, verifiable action>
- [ ] <concrete subaction with exact file or command>
- [ ] <subaction>
- **Reference:** REQ-1, REQ-2 (and/or design decision N)
- **Files:** <expected files to create/modify>
- **Verification:** <command or check that confirms this task is done>
- **Status:** pending

#### Task 1.2: <atomic action>
- [ ] <subaction>
- **Reference:** REQ-3
- **Files:** <…>
- **Verification:** <…>
- **Status:** pending

### Group 2: <descriptive name>

**parallel: true**
**depends_on: Group 1**

#### Task 2.1: <…>
…

#### Task 2.2: <…>
…

#### Task 2.3: <…>
…

### Group 3: <descriptive name>

**parallel: false**
**depends_on: Group 2**

#### Task 3.1: <…>
…

## Dependencies

```
Group 1 (no deps, parallel: false)
   ↓
Group 2 (depends on Group 1, parallel: true) ← auto-routes to dev-parallel
   ↓
Group 3 (depends on Group 2, parallel: false)
```

## Definition of Done

- [ ] All tasks marked `Status: done`
- [ ] `{config.stack.build_cmd}` — zero errors
- [ ] `{config.stack.lint_cmd}` — zero errors
- [ ] `{config.stack.test_cmd}` — all pass
- [ ] All REQ-IDs from requirements.md addressed (verify via grep)

## Deviations

<Empty initially. dev-implement and dev-parallel append notes here when a step differs from plan.>
