# Contributing to Paadhai

Thank you for contributing to Paadhai — an open-source AI-native SDLC pipeline.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/<your-username>/paadhai.git`
3. Install prerequisites: `git` (2.x+), `gh` (GitHub CLI 2.x+)
4. Set up Paadhai itself: run `/project-init` in your fork

## Development Workflow

Paadhai eats its own dog food. Use Paadhai to contribute to Paadhai:

```
/dev-start #<issue>      → create feature branch
/dev-plan                → plan the implementation
/dev-implement           → implement step-by-step
/dev-pr                  → open pull request
/dev-audit               → review the changes
/dev-ship                → merge when approved
```

## Skill File Format

Each Paadhai skill is a Markdown file with YAML frontmatter:

```yaml
---
name: skill-name
description: Use when <condition> — <what it does>
---
```

**Rules for skill files:**
- All repo-specific values must come from `.paadhai.json` via `{config.*}` references
- Zero hardcoded values (no repo names, no project IDs, no stack commands)
- Every action must have a capability marker: `[READ]`, `[SHELL]`, `[WRITE]`, `[DELEGATE]`, `[PARALLEL]`, `[FAST-MODEL]`, `[SMART-MODEL]`, `[SEARCH]`
- Human gates must be labeled G-01 through G-10 with exact wording
- Every skill must have a Handoff step telling the user what to run next

## Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

| Type | When |
|------|------|
| `feat` | New functionality |
| `fix` | Bug fix |
| `test` | Tests only |
| `chore` | Dependencies, config |
| `refactor` | Restructure, no behavior change |
| `docs` | Documentation |
| `perf` | Performance improvement |

Format: `<type>(<scope>): <subject>`
- Subject: max 72 chars, imperative mood ("add X" not "added X")
- Scope: skill name, platform, or component (e.g., `dev-start`, `references`, `platform`)

## Pull Request Process

1. Branch from `develop` (not `main`)
2. PR target: `develop`
3. CI must pass
4. Run `/dev-audit` before requesting review
5. Include test evidence in PR description

## Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/) Code of Conduct. Be respectful and constructive.
