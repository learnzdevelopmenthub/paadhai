# Cursor — Capability Marker Mapping

This file maps Devflow capability markers to Cursor native tools.
Loaded at session start via `AGENTS.md` and `.cursor/rules/`.

| Marker | Cursor Tool | Notes |
|--------|------------|-------|
| `[READ]` | Built-in file read | Cursor reads files natively |
| `[SHELL]` | Terminal command execution | Run commands in integrated terminal |
| `[SEARCH]` | Codebase search | Cursor's built-in search |
| `[WRITE]` | File edit/create | Cursor's edit capabilities |
| `[PARALLEL]` | **Sequential fallback** | Execute one at a time |
| `[DELEGATE]` | **Inline execution** | No subagent — execute in current context |
| `[FAST-MODEL]` | Current session model | No model selection |
| `[SMART-MODEL]` | Current session model | No model selection |

## Subagent Support

Cursor does NOT support subagent dispatch. All `[PARALLEL]` and `[DELEGATE]` tasks execute sequentially in the current context.

## Fallback Behavior

- `[PARALLEL]` → execute tasks one at a time in listed order
- `[DELEGATE]` → execute inline in current session
- `[FAST-MODEL]` / `[SMART-MODEL]` → use whatever model the session is running
