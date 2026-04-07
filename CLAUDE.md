# Paadhai — Claude Code

Read `references/claude-tools.md` for capability marker → tool mappings.

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
| `/dev-parallel` | Execute independent tasks via parallel subagents |
| `/dev-debug` | Systematic 4-phase debugging with escalation |
| `/dev-unblock` | Fix CI failures and merge conflicts |
| `/dev-release` | Tag, changelog, release, back-merge |
| `/dev-rollback` | Recover from bad releases |
| `/dev-status` | Read-only project progress dashboard |
| `/paadhai-skill` | Scaffold and register new skills |

## Config

All skills read from `.paadhai.json` at project root. Run `/project-init` to create it.
