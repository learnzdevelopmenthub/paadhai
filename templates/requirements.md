# Requirements — Issue #<number>: <title>

> **Source artifact** for the Paadhai SDLC pipeline. EARS-format acceptance criteria with stable REQ-IDs that downstream skills (`dev-test`, `dev-implement`, `dev-audit`) reference directly.

## Overview

<1–2 sentence description of what is being built and why>

## Context

<Issue background. Link to SRS section, milestone goal, or upstream conversation. Keep it short — design rationale lives in design.md, not here.>

## Acceptance Criteria

EARS templates: **The system shall** <action> | **When** <trigger>**, the system shall** <action> | **The system shall NOT** <forbidden behavior>.

Every criterion gets a stable ID (REQ-1, REQ-2, …). These IDs are referenced in `design.md`, `tasks.md`, and the test plan, so do not renumber them after this file is committed. To remove a criterion, mark it `superseded` or `dropped` rather than reusing the ID.

### REQ-1: <short title>
The system shall <criterion>.

### REQ-2: <short title>
When <trigger>, the system shall <action>.

### REQ-3: <short title>
The system shall NOT <forbidden behavior>.

<…add more as needed…>

## Definitions

- **<term>**: <definition>
- **<term>**: <definition>

## Assumptions

- <assumption that holds for this issue, e.g., "TLS is enforced in production">
- <assumption>

## Non-Functional Requirements (optional)

- **Performance**: <e.g., "endpoint p95 latency < 200ms under nominal load">
- **Security**: <reference REQ-IDs that capture security requirements>
- **Compatibility**: <e.g., "must work on Node 20+">
