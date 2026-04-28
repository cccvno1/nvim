# Onboarding Docs And Dependencies Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add practical onboarding documentation and a repeatable dependency installation script for the AI Neovim workbench.

**Architecture:** Documentation is split by reading mode: `README.md` for quick start, `docs/WORKFLOWS.md` for task-oriented usage, and `docs/KEYMAPS.md` for lookup. `scripts/install-deps.sh` owns system dependency detection, package manager installation, AI CLI installation, and Mason bootstrap.

**Tech Stack:** Markdown, POSIX-friendly Bash, lazy.nvim, Mason, pacman, apt, dnf, Homebrew, npm.

---

## Tasks

- [x] Create `README.md` as the first-run and repository overview.
- [x] Create `docs/WORKFLOWS.md` for AI review, debug, Git, search, outline, Markdown, and bigfile workflows.
- [x] Create `docs/KEYMAPS.md` as a keymap index.
- [x] Create `scripts/install-deps.sh` with multi-package-manager support and optional runtime installation.
- [ ] Verify shell syntax, Lua syntax, startup, health, and git state.
