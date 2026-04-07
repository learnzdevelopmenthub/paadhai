# Paadhai — Gemini CLI

Read `references/gemini-tools.md` for capability marker → tool mappings.

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

## Subagent Support

Gemini CLI has partial subagent support via extensions.
- `[FAST-MODEL]` → `gemini-flash`
- `[SMART-MODEL]` → `gemini-pro`
- `[PARALLEL]` → sequential if extensions unavailable
- `[DELEGATE]` → inline if no extension support
