# Codex CLI — Capability Marker Mapping

This file maps Devflow capability markers to Codex CLI native tools.
Loaded at session start via `AGENTS.md`.

| Marker | Codex Tool | Notes |
|--------|-----------|-------|
| `[READ]` | File read | Codex reads files in sandbox |
| `[SHELL]` | Shell execution | Commands run in sandbox |
| `[SEARCH]` | `grep` / `find` | Standard CLI search tools |
| `[WRITE]` | File write | Write within sandbox |
| `[PARALLEL]` | **Sequential fallback** | No parallel execution |
| `[DELEGATE]` | **Inline execution** | No subagent support |
| `[FAST-MODEL]` | Current model | No model selection |
| `[SMART-MODEL]` | Current model | No model selection |

## Subagent Support

Codex CLI does NOT support subagent dispatch.

## Fallback Behavior

- `[PARALLEL]` → sequential execution
- `[DELEGATE]` → inline execution
- `[FAST-MODEL]` / `[SMART-MODEL]` → current session model
