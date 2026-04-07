# Devflow — Gemini CLI

Read `references/gemini-tools.md` for capability marker → tool mappings.

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

## Subagent Support

Gemini CLI has partial subagent support via extensions.
- `[FAST-MODEL]` → `gemini-flash`
- `[SMART-MODEL]` → `gemini-pro`
- `[PARALLEL]` → sequential if extensions unavailable
- `[DELEGATE]` → inline if no extension support
