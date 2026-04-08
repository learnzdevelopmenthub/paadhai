# Privacy Policy

**Paadhai** (the "Plugin")
**Effective date:** April 8, 2026

## What Paadhai does

Paadhai is a collection of AI agent skills that run locally in your terminal or IDE. It helps you manage your software development lifecycle by orchestrating commands, reading project configuration, and interacting with GitHub via the `gh` CLI.

## Data collection

Paadhai does **not** collect, store, transmit, or share any personal data or telemetry. It has no backend server, no analytics, and no tracking of any kind.

## What Paadhai accesses locally

When you invoke a skill, Paadhai may read or write the following on your local machine:

- **Project files** in your working directory (source code, configuration, documentation)
- **`.paadhai.json`** for project-level settings (repo name, branch strategy, stack details)
- **Git metadata** via local `git` commands (branches, commits, status)
- **GitHub data** via the `gh` CLI (issues, pull requests, milestones, project boards)

All of this stays on your machine or flows directly between your machine and GitHub through the `gh` CLI, which you authenticate independently.

## Third-party services

Paadhai itself does not communicate with any third-party service. The AI agent host (Claude Code, Cursor, Codex CLI, OpenCode, or Gemini CLI) handles all communication with its respective AI provider. Refer to your AI agent host's privacy policy for details on how your prompts and code are processed.

## Data storage

Paadhai stores no data outside your local filesystem. There is no remote database, no cloud storage, and no user accounts.

## Children's privacy

Paadhai does not knowingly collect information from anyone, including children under 13.

## Changes to this policy

Updates to this policy will be reflected in this file in the repository. The effective date at the top will be updated accordingly.

## Contact

If you have questions about this policy, open an issue at [github.com/learnzdevelopmenthub/paadhai](https://github.com/learnzdevelopmenthub/paadhai/issues).
