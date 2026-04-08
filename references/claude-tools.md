# Claude Code — Capability Marker Mapping

This file maps Devflow capability markers to Claude Code native tools.
Loaded at session start via `CLAUDE.md`.

| Marker | Claude Code Tool | Notes |
|--------|-----------------|-------|
| `[READ]` | `Read` tool | Read file contents |
| `[SHELL]` | `Bash` tool | Execute shell commands |
| `[SEARCH]` | `Grep` / `Glob` tools | Search codebase |
| `[WRITE]` | `Write` / `Edit` tools | Create or modify files |
| `[PARALLEL]` | Multiple `Agent` tool calls in one message | Launch parallel subagents |
| `[DELEGATE]` | `Agent` tool | Launch isolated subagent |
| `[FAST-MODEL]` | `model: "haiku"` parameter on Agent tool | Use fastest available model |
| `[SMART-MODEL]` | `model: "opus"` parameter on Agent tool | Use most capable model |
| `[PROGRESS]` | `TodoWrite` tool | Create and update a live step checklist. Graceful degradation: skip if TodoWrite unavailable |

## Subagent Support

Claude Code fully supports subagent dispatch via the `Agent` tool.

- `[PARALLEL]` → multiple `Agent` calls in a single message (true parallelism)
- `[DELEGATE]` → single `Agent` call with focused brief
- Model selection via `model` parameter: `"haiku"`, `"sonnet"`, `"opus"`

## Fallback

No fallback needed — Claude Code supports all markers natively.

## [PROGRESS] Convention

`[PROGRESS]` maps to the `TodoWrite` tool. Use it to maintain a live checklist of steps during skill execution.

### Initialization (at skill start, after config is loaded)

Create one TodoWrite item per numbered STEP in the skill. All items start as `pending`.

Item format:
```
Step N/Total: <step title>
```

### Updating items during execution

At the **start** of each step — update that item to `in_progress`:
```
Step 3/10: Analyze Task Dependencies [in_progress]
```

At the **end** of each step — update that item to `completed`, embedding result:
```
Step 3/10: Analyze Task Dependencies [completed]
Analysis complete
```

For steps that read files:
```
Step 2/10: Load Implementation Doc [completed]
Files read: docs/plans/issue-8/implementation.md, docs/plans/issue-8/plan.md
```

For steps that change files or run build/lint:
```
Step 7/10: Implementation Loop [completed]
Files changed: src/auth.ts, src/types.ts
Build: ✓  Lint: ✓
```

### Graceful degradation

If the TodoWrite tool is unavailable, skip all `[PROGRESS]` calls silently and continue execution. Never block on progress tracking.
