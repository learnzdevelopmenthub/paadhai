# Paadhai (பாதை)

> **AI-native SDLC pipeline** — 21 skills covering every stage of software development, from project setup through production release.

Paadhai (Tamil for *path*) is a structured collection of AI agent skills that guide you through the entire software development lifecycle. Each skill is a self-contained workflow that knows where it fits in the pipeline, what to do, and what comes next — so your AI agent never improvises where consistency matters.

Works with **Claude Code**, **Cursor**, **Codex CLI**, **OpenCode**, and **Gemini CLI**.

---

## How it works

Every project starts with a single config file (`.paadhai.json`) that captures your repo, stack, and branching strategy. Every skill reads from this file — no hardcoded values, no repeated setup.

The skills are organized into four pipelines:

```
SETUP (once per project)
  /project-init → /project-plan → /release-plan

DEV LOOP (once per issue/feature)
  /dev-start → /dev-plan → /dev-test → /dev-implement → /dev-pr → /dev-audit → /dev-ship

RELEASE (once per version)
  /dev-release

EMERGENCY (for production incidents)
  /dev-hotfix → /dev-pr → /dev-audit → /dev-ship → /dev-release
```

Support skills (`/dev-debug`, `/dev-unblock`, `/dev-deps`, `/dev-docs`, `/dev-adr`, `/dev-status`, `/dev-rollback`, `/dev-parallel`) run independently at any point.

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| `git` | 2.x+ | Version control |
| `gh` | 2.x+ | GitHub CLI — run `gh auth login` before first use |
| AI agent | — | Claude Code, Cursor, Codex CLI, OpenCode, or Gemini CLI |

---

## Installation

### Claude Code
```bash
/plugin install paadhai
```

Or manually:
```bash
git clone https://github.com/paadhai/paadhai.git
cp -r paadhai/.claude/skills/* ~/.claude/skills/
```

### Cursor
Search "Paadhai" in the Cursor plugin marketplace, or:
```bash
git clone https://github.com/paadhai/paadhai.git
cp -r paadhai/.cursor-plugins/paadhai/ ~/.cursor-plugins/
```

### Codex CLI / OpenCode
```bash
git clone https://github.com/paadhai/paadhai.git
cp -r paadhai/.codex-plugin/ your-project/
cp paadhai/AGENTS.md your-project/
```

### Gemini CLI
```bash
gemini extensions install paadhai
```

---

## Quick Start

```bash
# 1. Set up your project (once)
/project-init     # creates .paadhai.json, optionally sets branch protection
/project-plan     # generates docs/srs.md from your product idea
/release-plan     # creates GitHub milestones + issues

# 2. Start a feature (per issue)
/dev-start #1     # creates branch feature/1-my-feature
/dev-plan         # security analysis, design review, implementation plan
/dev-test         # test plan + stubs from acceptance criteria
/dev-implement    # execute the plan step by step
/dev-pr           # push branch, open PR (auto-labeled), poll CI
/dev-audit        # architecture + security + compatibility review
/dev-ship         # merge PR, update board, clean up branch

# 3. Release
/dev-release      # tag version, publish release, close milestone, health check
```

---

## Skills Reference

### Setup Pipeline

Run these once when starting a new project.

| Command | What it does | Output |
|---------|-------------|--------|
| `/project-init` | Initialize `.paadhai.json`, connect GitHub repo, optionally enable branch protection | `.paadhai.json` |
| `/project-plan` | Generate a Software Requirements Specification from your product description | `docs/srs.md` |
| `/release-plan` | Create GitHub milestones and issues from your SRS | GitHub milestones + issues |

---

### Dev Loop

Run this sequence for every issue or feature. Each skill hands off to the next.

| Command | What it does | Output |
|---------|-------------|--------|
| `/dev-start` | Pick a GitHub issue, create a feature branch | Git branch |
| `/dev-plan` | Brainstorm approach, security threat assessment, design review, implementation plan | `docs/plans/issue-<n>/plan.md` + `implementation.md` |
| `/dev-test` | Generate test plan from acceptance criteria + write test stubs | `docs/plans/issue-<n>/test-plan.md` + test files |
| `/dev-implement` | Execute the implementation plan step by step | Code changes |
| `/dev-pr` | Push branch, open PR (inherits issue labels), poll CI | GitHub PR |
| `/dev-audit` | 3-dimension review: architecture, security, compatibility | Audit report |
| `/dev-ship` | Merge PR after audit approval, close issue, clean up branch | Merged PR |

**The pipeline in detail:**

```
/dev-start
    ↓  creates branch
/dev-plan
    ↓  plan.md + implementation.md
    ↓  security threat model injected automatically
    ↓  prompts for ADR if architectural decision detected
/dev-test
    ↓  test-plan.md + test stubs (compile-verified)
/dev-implement
    ↓  code changes
/dev-pr
    ↓  PR opened with issue labels copied automatically
/dev-audit
    ↓  review pass
/dev-ship
    ↓  merged + board updated
```

---

### Release

| Command | What it does | Output |
|---------|-------------|--------|
| `/dev-release` | Tag version, generate changelog, publish GitHub Release, close milestone, run post-release health check | GitHub Release + closed milestone |

The health check after release inspects CI status and new issues. If anything looks wrong, it surfaces a `/dev-rollback` signal before you move on.

---

### Emergency Pipeline

For urgent production issues that can't wait for the normal dev loop.

| Command | What it does | Output |
|---------|-------------|--------|
| `/dev-hotfix` | Branch from main, implement minimal fix, open PR directly to main | Hotfix PR to main |
| `/dev-rollback` | Recover from a bad release — revert tags, redeploy previous version | Rollback + incident notes |

**Hotfix flow:**
```
/dev-hotfix → /dev-pr → /dev-audit → /dev-ship → /dev-release
                                                      ↓
                                          back-merge main → develop
```

---

### Support Skills

Run any of these at any point in the pipeline, standalone.

| Command | When to use |
|---------|------------|
| `/dev-debug` | Something is broken and you don't know why — 4-phase systematic debug |
| `/dev-unblock` | CI is failing or there's a merge conflict blocking your PR |
| `/dev-parallel` | You have multiple independent issues to work — dispatches parallel subagents |
| `/dev-deps` | Audit dependencies for CVEs, license issues, and outdated packages |
| `/dev-docs` | Generate API reference, user guide, or architecture overview from the codebase |
| `/dev-adr` | Record an Architecture Decision Record for a significant design choice |
| `/dev-status` | Read-only dashboard — see open issues, PRs, CI status, milestone progress |

---

### Meta

| Command | What it does |
|---------|-------------|
| `/paadhai-skill` | Scaffold a new Paadhai skill with correct structure and register it |

---

## Configuration (`.paadhai.json`)

Created automatically by `/project-init`. Every skill reads from this file.

| Key | Description |
|-----|-------------|
| `version` | Paadhai config schema version |
| `repo.owner` | GitHub username or org |
| `repo.name` | Repository name |
| `repo.main_branch` | Production branch (e.g. `main`) |
| `repo.develop_branch` | Integration branch (e.g. `develop`) |
| `branches.feature` | Feature branch prefix (e.g. `feature/`) |
| `branches.fix` | Fix branch prefix (e.g. `fix/`) |
| `stack.language` | Primary language (e.g. `typescript`, `python`) |
| `stack.build_cmd` | Build command (e.g. `npm run build`) |
| `stack.lint_cmd` | Lint command (e.g. `npm run lint`) |
| `stack.test_cmd` | Test command (e.g. `npm test`) |

---

## Decision Guide

**Not sure which skill to use?**

| Situation | Skill |
|-----------|-------|
| Starting a brand-new project | `/project-init` → `/project-plan` → `/release-plan` |
| Starting work on an issue | `/dev-start` |
| Need a plan before writing code | `/dev-plan` |
| Ready to write tests | `/dev-test` |
| Ready to write code | `/dev-implement` |
| Ready to open a PR | `/dev-pr` |
| PR needs a code review | `/dev-audit` |
| PR is approved, ready to merge | `/dev-ship` |
| Ready to tag a release | `/dev-release` |
| Production is broken right now | `/dev-hotfix` |
| A release introduced a regression | `/dev-rollback` |
| Something is broken, unknown cause | `/dev-debug` |
| CI is failing or there's a conflict | `/dev-unblock` |
| Need to check project health | `/dev-status` |
| Dependencies have CVEs or are outdated | `/dev-deps` |
| Need to write or update docs | `/dev-docs` |
| Making a significant architectural decision | `/dev-adr` |
| Multiple independent tasks in parallel | `/dev-parallel` |

---

## Platform Support

| Feature | Claude Code | Cursor | Codex CLI | OpenCode | Gemini CLI |
|---------|:-----------:|:------:|:---------:|:--------:|:----------:|
| All 21 skills | ✓ | ✓ | ✓ | ✓ | ✓ |
| Subagent dispatch | ✓ | Partial | ✗ | ✗ | Partial |
| Parallel execution | ✓ | Sequential | Sequential | Sequential | Partial |
| Model selection | ✓ | ✗ | ✗ | ✗ | ✓ |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT — see [LICENSE](LICENSE).
