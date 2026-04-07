# Gemini CLI — Capability Marker Mapping

This file maps Devflow capability markers to Gemini CLI native tools.
Loaded at session start via `GEMINI.md`.

| Marker | Gemini Tool | Notes |
|--------|------------|-------|
| `[READ]` | `read_file` | Read file contents |
| `[SHELL]` | `run_shell` | Execute shell commands |
| `[SEARCH]` | `search_files` | Search codebase |
| `[WRITE]` | `edit_file` / `create_file` | Create or modify files |
| `[PARALLEL]` | **Partial support** | Some parallel execution via extensions |
| `[DELEGATE]` | **Inline execution** | Limited subagent support |
| `[FAST-MODEL]` | `gemini-flash` | Use fastest Gemini model |
| `[SMART-MODEL]` | `gemini-pro` | Use most capable Gemini model |

## Subagent Support

Gemini CLI has partial subagent support via extensions. When available, `[DELEGATE]` uses extension dispatch. When not available, falls back to inline execution.

## Fallback Behavior

- `[PARALLEL]` → sequential if extensions unavailable
- `[DELEGATE]` → inline if no extension support
- `[FAST-MODEL]` → `gemini-flash` (or current model if unavailable)
- `[SMART-MODEL]` → `gemini-pro` (or current model if unavailable)
