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

## Subagent Support

Claude Code fully supports subagent dispatch via the `Agent` tool.

- `[PARALLEL]` → multiple `Agent` calls in a single message (true parallelism)
- `[DELEGATE]` → single `Agent` call with focused brief
- Model selection via `model` parameter: `"haiku"`, `"sonnet"`, `"opus"`

## Fallback

No fallback needed — Claude Code supports all markers natively.
