# CLI AI Workbench Design

Date: 2026-05-02

## Goal

Build a portable, CLI-first development workbench for Codex/OpenCode, Superpowers, tmux, lazygit, and Neovim.

The system should feel like a quiet production cockpit: fast to enter, easy to recover, good-looking without being flashy, and safe around real project files.

## Core Model

The workflow is organized around workspaces, not editor windows.

```text
task intent -> branch -> worktree -> tmux session -> windows/panels -> tools
```

Responsibilities:

```text
Superpowers     spec, plan, process, worktree guidance
Codex/OpenCode  interactive and headless agents
ws              personal workspace index and tmux bridge
tmux            recoverable terminal workspace
Neovim          review, manual edits, diagnostics, conflicts
lazygit         Git cockpit for staging, commits, branches, rebase
git             source of truth
chezmoi         migration and dotfile management
```

The system must not replace Superpowers, invent a new spec system, or hide Git state from the user.

## Migration Baseline

Use `chezmoi` as the single migration entrypoint.

Managed directly by chezmoi:

```text
Ghostty config
tmux local config
lazygit config
ws scripts/config/prompts
shell entrypoints, later
OpenCode/Codex user config, where appropriate
```

Managed as chezmoi externals:

```text
~/.config/nvim    existing independent Neovim repo
~/.tmux           Oh My Tmux external repo
```

Neovim remains a normal Git repository for daily development. Chezmoi is responsible for installing it on new machines, not for absorbing its history into the dotfiles repo.

## Tool Set

Core tools:

```text
chezmoi
ghostty
tmux
fzf
gum
git
lazygit
nvim
rg
fd
bat
eza
zoxide
codex
opencode
```

Integrated but not core requirements:

```text
delta
btop
duf
dust
docker
node/npm/pnpm
go/python/uv
```

Deferred:

```text
mise
direnv
just
starship
jq/yq
```

Excluded from the core design:

```text
sesh
tmuxp
tmuxinator
zellij
gh/glab
```

The guiding rule is to avoid overlapping tools unless each one has a clear layer.

## Terminal Layer

Ghostty owns window feel only:

```text
font
theme
opacity
padding
clipboard keys
terminal compatibility
```

Ghostty does not own splits, sessions, workspace switching, or agent layout.

tmux owns:

```text
sessions
windows
panels/panes
popups
status bar
copy mode
workspace recovery
Neovim/tmux navigation
```

Oh My Tmux is the tmux base. The local override should make it quiet, not flashy.

Visual direction:

```text
Tokyo Night family
low-saturation accents
clear active window/session
minimal icons
no rainbow status line
no dashboard-like clutter
```

Status bar must show enough context to avoid wrong-worktree mistakes:

```text
session
window
path basename
git branch
dirty marker
time
```

Prefix/key model:

```text
C-a       primary prefix
C-b       compatibility prefix
C-a s     ws picker
C-a r     reload config
C-a z     zoom pane
C-a c     new window in current directory
C-a |     split right
C-a -     split down
C-h/j/k/l Neovim/tmux movement
```

## Workspace Entry

The only daily entry command is:

```text
ws
```

It can run from the shell or from tmux via `C-a s`.

Daily mental model:

```text
I want to enter a work scene -> ws
```

Primary sources:

```text
active tmux sessions
recent workspaces
pinned projects
```

`ws` must not default-scan every directory under `~/workspace`. Temporary clones and experiments should not pollute the first screen.

Git metadata expansion:

```text
For pinned/recent/current Git repositories:
  git worktree list
  git branch
  git branch -r
```

Branches are not direct workspace targets. They are clues for finding or creating worktrees.

Allowed actions:

```text
open active/recent/pinned workspace
pin current project
forget recent entry
hide an entry from display
doctor stale ws state
create/open worktree from branch, only after explicit selection
```

Safety boundary:

```text
ws never edits project files
ws never deletes project directories
ws never deletes branches
ws never deletes worktrees
ws never runs git switch automatically
ws only manages its own state and ws-managed tmux sessions
```

The explicit "create/open worktree from branch" action is the one allowed exception: it may create a new worktree directory and Git metadata after user confirmation. It must not modify existing project files.

If a directory behind a ws-managed session disappears:

```text
remove stale recent entry
kill stale ws-managed tmux session
do not touch project files
```

State and config:

```text
~/.config/ws/config.toml
~/.config/ws/local.toml
~/.local/state/ws/recent.json
~/.local/state/ws/context/
~/.local/share/ws/prompts/
```

`config.toml` is chezmoi-managed. `local.toml` is machine-local.

## Branch and Worktree Policy

Default production flow uses worktrees.

```text
branch   = task clue
worktree = code workspace
session  = terminal workspace
```

If a selected branch already has a worktree, `ws` opens that worktree.

If a selected branch has no worktree, `ws` may offer to create one. This is explicit because it creates files/Git metadata.

`ws` does not perform checkout-in-place. Plain `git switch` or lazygit branch checkout remains a manual Git operation.

## tmux Workspace Template

Default session windows:

```text
1 code     full-screen Neovim
2 agent    primary interactive agent shell
3 git      full-screen lazygit
4 run      background services, test watchers, logs
```

Windows are long-lived rooms. Panes/panels are short-lived drawers.

Use panels for:

```text
scratch shell
context preview
diagnostic preview
temporary tests
temporary logs
```

Do not keep code or agent permanently squeezed by default split panes.

Multiple agents use multiple windows:

```text
agent-main
agent-plan
agent-exec
agent-review
agent-git
```

Long-running servers belong in `run`, not in a temporary panel.

## AI Defaults

Codex is the current default, but defaults must be configurable per role:

```toml
[ai]
interactive_default = "codex"
git_agent_default = "codex"
headless_default = "codex"

[ai.commands]
codex = "codex"
opencode = "opencode"

[ai.headless]
codex = "codex run --print"
opencode = "opencode run --print"
```

Temporary overrides should be possible:

```text
WS_AI=opencode ws git message
WS_AI=codex ws new-agent
```

Superpowers remains unchanged. Personal workflow prompts/protocols belong to `ws`, not to Superpowers.

## Context-to-Agent Bridge

`ws` provides a shared bridge for Neovim, lazygit, and shell:

```text
collect context
write context file outside the project
send short prompt + context path to selected tmux agent target
```

The bridge should avoid stuffing large diffs into tmux input.

Context files live under:

```text
~/.local/state/ws/context/<session>/
```

Prompts live under:

```text
~/.local/share/ws/prompts/
```

This bridge is used for:

```text
Neovim diagnostics/quickfix/selection -> agent
lazygit Git context -> agent-git
shell command output -> selected agent
```

## Git and Review Workflow

lazygit owns repo-level Git operations:

```text
status
stage/unstage
commit/amend
stash
branch
rebase
merge
push/pull
```

Neovim owns careful review and conflict work:

```text
Diffview
gitsigns
manual edits
diagnostics
conflict resolution
```

delta may remain a command-line pager, but it is not the core merge/review surface.

No platform-specific CLI is required for GitHub/Gitee in the core flow.

## AI-Assisted Git Finishing Lane

The Git finishing lane is separate from the main implementation agent.

```text
agent-main / agent-exec -> implementation
agent-git               -> Git finishing advice
headless ai-git          -> machine-readable commit message generation
```

lazygit custom actions:

```text
AI plan commits
AI review staged/all
AI message staged
commit with AI message
```

Behavior:

```text
AI plan commits
  collect unstaged/staged context
  send to agent-git
  agent-git suggests commit groups, messages, risks

AI review staged/all
  collect selected diff
  send to agent-git
  agent-git reports risks and review notes

AI message staged
  collect staged diff
  run headless AI
  write commit message file

commit with AI message
  preview message with gum
  on explicit confirmation, run git commit -F <message-file>
```

Safety boundary:

```text
AI never automatically stages files
AI never splits hunks
AI never automatically commits without explicit user confirmation
AI never rebases or deletes anything
```

The human chooses staged content. AI helps understand and name it.

## lazygit Configuration

Keep lazygit config thin.

Needed settings:

```yaml
os:
  editPreset: nvim

gui:
  nerdFontsVersion: "3"
  sidePanelWidth: 0.28
  expandFocusedSidePanel: true
  mainPanelSplitMode: flexible
  skipDiscardChangeWarning: false
  skipStashWarning: false
  skipAmendWarning: false
```

Add only workflow-specific custom commands for the AI Git lane.

Avoid turning lazygit into a full AI/Git IDE.

## Neovim Configuration Direction

Neovim is not the primary AI host.

Keep:

```text
gitsigns
Diffview
diagnostics/quickfix
Sidekick as lightweight context/review helper if useful
```

Reduce overlap:

```text
avoid duplicate Git UI plugins that conflict with lazygit/Diffview
avoid turning Neovim into the primary agent cockpit
```

Neovim should provide actions to send diagnostics, selected text, quickfix entries, or file context to the selected agent target through `ws`.

## Implementation Batches

Batch 1: migration and terminal base

```text
chezmoi source setup
nvim external
Oh My Tmux external
Ghostty compatibility polish
tmux local override
tmux-resurrect/yank/navigator if selected
```

Batch 2: workspace system

```text
ws config/state layout
active/recent/pinned picker
fzf/gum UI
tmux session creation
default windows
panel actions
agent target tracking
doctor command
```

Batch 3: Git/AI finishing and editor bridge

```text
lazygit config
lazygit custom commands
ws git context generation
agent-git window
headless AI commit message
gum confirm commit
Neovim context-to-agent actions
```

## Open Questions

These should be decided during implementation planning:

```text
exact tmux plugin list and install method
exact ws implementation language: shell first unless complexity forces another choice
exact lazygit AI keybindings
exact Codex/OpenCode headless command forms
whether Neovim context bridge is implemented as Lua calls to ws or simple shell commands
```

## Non-Goals

```text
Do not implement a Superpowers replacement.
Do not modify Superpowers skills for personal Git finishing.
Do not make ws a Git manager.
Do not make lazygit a platform-specific PR tool.
Do not introduce mise/direnv/just/starship in the first implementation.
Do not auto-delete project files, branches, or worktrees.
Do not auto-stage or auto-split hunks.
```
