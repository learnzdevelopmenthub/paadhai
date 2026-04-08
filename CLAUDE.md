# Paadhai — Claude Code

Read `references/claude-tools.md` for capability marker → tool mappings.

## Available Skills

| Command | Purpose |
|---------|---------|
| `/paadhai:project-init` | Set up new or existing project |
| `/paadhai:project-plan` | Generate SRS from product idea |
| `/paadhai:release-plan` | Create milestones + issues on GitHub |
| `/paadhai:dev-start` | Pick issue, create branch |
| `/paadhai:dev-plan` | Brainstorm + plan + impl doc |
| `/paadhai:dev-test` | Generate test plan + stubs from ACs |
| `/paadhai:dev-implement` | Execute implementation step by step |
| `/paadhai:dev-pr` | Push branch, open PR, poll CI |
| `/paadhai:dev-audit` | Architecture + security + compatibility review |
| `/paadhai:dev-ship` | Merge PR, update board, clean up |
| `/paadhai:dev-parallel` | Execute independent tasks via parallel subagents |
| `/paadhai:dev-debug` | Systematic 4-phase debugging with escalation |
| `/paadhai:dev-unblock` | Fix CI failures and merge conflicts |
| `/paadhai:dev-release` | Tag, changelog, release, back-merge |
| `/paadhai:dev-rollback` | Recover from bad releases |
| `/paadhai:dev-hotfix` | Fast-path for urgent production fixes |
| `/paadhai:dev-status` | Read-only project progress dashboard |
| `/paadhai:dev-deps` | Dependency audit: CVEs, licenses, outdated |
| `/paadhai:dev-docs` | Generate API, user, architecture docs |
| `/paadhai:dev-adr` | Record Architecture Decision Records |
| `/paadhai:paadhai-skill` | Scaffold and register new skills |

## Config

All skills read from `.paadhai.json` at project root. Run `/paadhai:project-init` to create it.
