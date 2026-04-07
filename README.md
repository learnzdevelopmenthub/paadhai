# Paadhai (பாதை)

**AI-Native SDLC Pipeline**

## What is Paadhai?

Paadhai is an AI-native software development lifecycle (SDLC) pipeline consisting of 10 integrated skills that guide you from project initialization through shipping and releasing. It works with Claude Code, Cursor, Codex CLI, OpenCode, and Gemini CLI, providing a consistent, config-driven workflow powered by AI agents.

The pipeline is built around a core configuration file (`.paadhai.json`) that captures your project structure, tech stack, and GitHub settings. Each skill is a self-contained agent that builds on the work of previous skills, orchestrating the entire development workflow from planning through release.

## Pipeline Overview

```
/project-init → /project-plan → /release-plan
                                      ↓
/dev-release ← /dev-ship ← /dev-audit ← /dev-pr ← /dev-implement ← /dev-plan ← /dev-start
```

## Prerequisites

- **git** (2.x+) — version control
- **gh** (GitHub CLI, 2.x+) — authenticated with `gh auth login`
- **Any supported AI agent** — Claude Code, Cursor, Codex CLI, OpenCode, or Gemini CLI

## Installation

### Claude Code

```bash
/plugin install paadhai
```

Or manually clone the repository and copy skills:

```bash
git clone https://github.com/paadhai/paadhai.git
cp -r paadhai/.claude/skills/* ~/.claude/skills/
```

### Cursor

Search for "Paadhai" in the Cursor plugin marketplace, or manually install by cloning the repository and copying into `.cursor-plugins/`:

```bash
git clone https://github.com/paadhai/paadhai.git
cp -r paadhai/.cursor-plugins/paadhai/ ~/.cursor-plugins/
```

### Codex CLI

Clone the repository and copy the agent configuration:

```bash
git clone https://github.com/paadhai/paadhai.git
cp -r paadhai/.codex-plugin/ your-project/
cp paadhai/AGENTS.md your-project/
```

### OpenCode

Clone the repository and copy the agent configuration:

```bash
git clone https://github.com/paadhai/paadhai.git
cp -r paadhai/.opencode/ your-project/
cp paadhai/AGENTS.md your-project/
```

### Gemini CLI

```bash
gemini extensions install paadhai
```

Or manually copy:

```bash
git clone https://github.com/paadhai/paadhai.git
cp -r paadhai/.gemini/extensions/paadhai/ ~/.gemini/extensions/
```

## Quick Start

Follow these steps to get started with a new or existing project:

```bash
/project-init    → set up your GitHub repo + write .paadhai.json
/project-plan    → define requirements (generates docs/srs.md)
/release-plan    → create milestones + issues on GitHub
/dev-start #1    → create feature branch for issue #1
/dev-plan        → brainstorm + generate implementation doc
/dev-implement   → execute the plan step by step
/dev-pr          → push branch + open PR + poll CI
/dev-audit       → three-dimension code review
/dev-ship        → merge PR + update board
/dev-release     → tag + publish GitHub Release
```

## Skills Reference

| Skill | Command | Description |
|-------|---------|-------------|
| Project Init | `/project-init` | Set up new or existing project with GitHub configuration |
| Project Plan | `/project-plan` | Generate Software Requirements Specification from product idea |
| Release Plan | `/release-plan` | Create GitHub milestones and issues for release |
| Dev Start | `/dev-start` | Pick an issue and create a feature branch |
| Dev Plan | `/dev-plan` | Brainstorm, plan, and generate implementation documentation |
| Dev Implement | `/dev-implement` | Execute implementation step by step |
| Dev PR | `/dev-pr` | Push branch, open pull request, and poll CI status |
| Dev Audit | `/dev-audit` | Perform architecture, security, and compatibility review |
| Dev Ship | `/dev-ship` | Merge PR, update GitHub board, and clean up |
| Dev Release | `/dev-release` | Tag version, publish GitHub Release, and back-merge |

## Configuration (`.paadhai.json`)

The `.paadhai.json` file is automatically created by `/project-init` and contains the core configuration for your project:

| Key | Description |
|-----|-------------|
| `version` | Paadhai configuration schema version |
| `repo` | Repository name, owner, and local path |
| `github` | GitHub API settings and authentication |
| `stack` | Tech stack, languages, and framework information |
| `branches` | Main, develop, and staging branch names |

The `/project-init` skill will guide you through creating this file with sensible defaults for your project.

## Platform Support

| Feature | Claude Code | Cursor | Codex CLI | OpenCode | Gemini CLI |
|---------|------------|--------|-----------|----------|------------|
| All 10 skills | ✓ | ✓ | ✓ | ✓ | ✓ |
| Subagent dispatch | ✓ | Partial | ✗ | ✗ | Partial |
| Parallel execution | ✓ | Sequential | Sequential | Sequential | Partial |
| Model selection | ✓ | ✗ | ✗ | ✗ | ✓ |

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to Paadhai.

## License

Paadhai is released under the MIT License. See [LICENSE](LICENSE) for details.
