# Devflow — AI Agent Instructions

This file provides Devflow context to AI coding agents. It is read automatically by Cursor, Codex CLI, and OpenCode.

## Platform Detection

Detect your platform and load the correct reference file:
- If you are **Cursor** → read `references/cursor-tools.md`
- If you are **Codex CLI** → read `references/codex-tools.md`
- If you cannot determine platform → read `references/cursor-tools.md` (safe default: sequential fallback)

## Available Skills

| Command | Purpose |
|---------|---------|
| `/project-init` | Set up new or existing project |
| `/project-plan` | Generate SRS from product idea |
| `/release-plan` | Create milestones + issues on GitHub |
| `/dev-start` | Pick issue, create branch |
| `/dev-plan` | Brainstorm + plan + impl doc |
| `/dev-implement` | Execute implementation step by step |
| `/dev-pr` | Push branch, open PR, poll CI |
| `/dev-audit` | Architecture + security + compatibility review |
| `/dev-ship` | Merge PR, update board, clean up |
| `/dev-release` | Tag, release, back-merge |

## Config

All skills read from `.devflow.json` at project root. Run `/project-init` to create it.

## Fallback Behavior

If your platform does not support subagents:
- `[PARALLEL]` → execute tasks sequentially in listed order
- `[DELEGATE]` → execute inline in current context
- `[FAST-MODEL]` / `[SMART-MODEL]` → use current session model
