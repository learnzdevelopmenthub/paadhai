# Paadhai — AI Agent Instructions

This file provides Paadhai context to AI coding agents. It is read automatically by Cursor, Codex CLI, and OpenCode.

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
| `/dev-test` | Generate test plan + stubs from ACs |
| `/dev-implement` | Execute implementation step by step |
| `/dev-pr` | Push branch, open PR, poll CI |
| `/dev-audit` | Architecture + security + compatibility review |
| `/dev-ship` | Merge PR, update board, clean up |
| `/dev-parallel` | Execute independent tasks via parallel subagents |
| `/dev-debug` | Systematic 4-phase debugging with escalation |
| `/dev-unblock` | Fix CI failures and merge conflicts |
| `/dev-release` | Tag, changelog, release, back-merge |
| `/dev-rollback` | Recover from bad releases |
| `/dev-hotfix` | Fast-path for urgent production fixes |
| `/dev-status` | Read-only project progress dashboard |
| `/dev-deps` | Dependency audit: CVEs, licenses, outdated |
| `/dev-docs` | Generate API, user, architecture docs |
| `/dev-adr` | Record Architecture Decision Records |
| `/paadhai-skill` | Scaffold and register new skills |

## Config

All skills read from `.paadhai.json` at project root. Run `/project-init` to create it.

## Fallback Behavior

If your platform does not support subagents:
- `[PARALLEL]` → execute tasks sequentially in listed order
- `[DELEGATE]` → execute inline in current context
- `[FAST-MODEL]` / `[SMART-MODEL]` → use current session model
