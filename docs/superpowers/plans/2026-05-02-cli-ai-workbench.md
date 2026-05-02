# CLI AI Workbench Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the portable CLI-first AI workbench described in `docs/superpowers/specs/2026-05-02-cli-ai-workbench-design.md`.

**Architecture:** `chezmoi` becomes the migration control plane, `tmux` becomes the recoverable workspace runtime, and a single `ws` command creates/switches workspaces and bridges context into Codex/OpenCode agents. Git finishing stays human-confirmed: lazygit triggers AI planning/review/message generation, but staging remains manual and commits require explicit confirmation.

**Tech Stack:** chezmoi, Ghostty, Oh My Tmux/tmux, Python 3 standard library for `ws`, fzf, gum, lazygit, Neovim Lua, Codex CLI, OpenCode CLI.

---

## Scope and Safety

This plan spans dotfiles, tmux, a personal `ws` tool, lazygit, and the Neovim config. Implement it in three batches and verify each batch before continuing.

The current Neovim repository may contain unrelated user changes. Do not revert, restage, or rewrite those changes. When touching Neovim files, stage only the exact files changed for this plan.

`ws` is allowed to modify only:

```text
~/.config/ws/
~/.local/state/ws/
~/.local/share/ws/
ws-managed tmux sessions/options
explicitly requested git worktree creation
```

`ws` must not delete project directories, branches, or worktrees, and must not run `git switch` automatically.

## File Structure

Create or modify these files.

Chezmoi source tree:

```text
~/.local/share/chezmoi/.chezmoiroot
~/.local/share/chezmoi/home/.chezmoiexternal.toml
~/.local/share/chezmoi/home/dot_config/ghostty/config
~/.local/share/chezmoi/home/symlink_dot_tmux.conf
~/.local/share/chezmoi/home/dot_tmux.conf.local
~/.local/share/chezmoi/home/dot_config/ws/config.toml
~/.local/share/chezmoi/home/dot_config/lazygit/config.yml
~/.local/share/chezmoi/home/dot_local/bin/executable_ws
~/.local/share/chezmoi/home/dot_local/share/ws/prompts/git-plan.md
~/.local/share/chezmoi/home/dot_local/share/ws/prompts/git-review.md
~/.local/share/chezmoi/home/dot_local/share/ws/prompts/git-message.md
~/.local/share/chezmoi/home/dot_local/share/ws/tests/test_ws.py
```

Machine-local files created at runtime:

```text
~/.config/ws/local.toml
~/.local/state/ws/recent.json
~/.local/state/ws/context/
~/.local/state/ws/commit-msg/
```

Neovim repository:

```text
lua/cccvno1/integrations/ws.lua
lua/cccvno1/keymaps.lua
lua/cccvno1/plugins/git.lua
lua/cccvno1/core/health.lua
docs/KEYMAPS.md
docs/WORKFLOWS.md
README.md
```

## Batch 1: Migration and Terminal Base

### Task 1: Install Required CLI Packages

**Files:**
- Modify system packages only.

- [ ] **Step 1: Check current command availability**

Run:

```bash
for c in chezmoi tmux fzf gum lazygit git nvim rg fd bat eza zoxide codex opencode; do
  printf '%-10s ' "$c"
  command -v "$c" || printf 'missing\n'
done
```

Expected before installation on the current machine: `fzf`, `git`, `nvim`, `rg`, `fd`, `bat`, `eza`, `zoxide`, `codex`, and `opencode` are present; `chezmoi`, `tmux`, `gum`, and `lazygit` may be missing.

- [ ] **Step 2: Install missing Arch packages**

Run:

```bash
yay -S --needed chezmoi tmux gum lazygit
```

Expected: all four packages install or are reported as already installed.

- [ ] **Step 3: Verify installed tools**

Run:

```bash
command -v chezmoi tmux gum lazygit
chezmoi --version
tmux -V
gum --version
lazygit --version
```

Expected: each command prints a path or version without error.

- [ ] **Step 4: Commit package-list documentation if package docs are added**

If this task adds package documentation to a repository, commit only those docs:

```bash
git add <package-doc-file>
git commit -m "docs: record CLI workbench packages"
```

Expected: no commit is made if no repository file changed.

### Task 2: Initialize Chezmoi Source Layout

**Files:**
- Create: `~/.local/share/chezmoi/.chezmoiroot`
- Create: `~/.local/share/chezmoi/home/.chezmoiexternal.toml`

- [ ] **Step 1: Initialize chezmoi if needed**

Run:

```bash
if [ ! -d "$HOME/.local/share/chezmoi/.git" ]; then
  chezmoi init
fi
mkdir -p "$HOME/.local/share/chezmoi/home"
printf 'home\n' > "$HOME/.local/share/chezmoi/.chezmoiroot"
```

Expected: `~/.local/share/chezmoi` exists and `.chezmoiroot` contains `home`.

- [ ] **Step 2: Add external repositories**

Create `~/.local/share/chezmoi/home/.chezmoiexternal.toml` with:

```toml
[".config/nvim"]
type = "git-repo"
url = "https://github.com/cccvno1/nvim.git"
refreshPeriod = "168h"

[".tmux"]
type = "git-repo"
url = "https://github.com/gpakosz/.tmux.git"
refreshPeriod = "168h"
```

Expected: the source file defines Neovim and Oh My Tmux as externals.

- [ ] **Step 3: Validate chezmoi source state**

Run:

```bash
chezmoi status
chezmoi diff --include files,symlinks,scripts
```

Expected: chezmoi reports pending source entries but does not overwrite existing `~/.config/nvim` or `~/.tmux`.

- [ ] **Step 4: Commit chezmoi source initialization**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add .chezmoiroot home/.chezmoiexternal.toml
git commit -m "feat: initialize portable dotfiles source"
```

Expected: a commit is created in the chezmoi source repository.

### Task 3: Capture Ghostty Config in Chezmoi

**Files:**
- Create: `~/.local/share/chezmoi/home/dot_config/ghostty/config`

- [ ] **Step 1: Copy the existing Ghostty config into chezmoi source**

Run:

```bash
mkdir -p "$HOME/.local/share/chezmoi/home/dot_config/ghostty"
cp "$HOME/.config/ghostty/config" "$HOME/.local/share/chezmoi/home/dot_config/ghostty/config"
```

Expected: the chezmoi source contains the current Tokyo Night Ghostty config.

- [ ] **Step 2: Add tmux compatibility comments without changing behavior**

Ensure `~/.local/share/chezmoi/home/dot_config/ghostty/config` contains these lines in the environment section:

```text
# tmux owns sessions, splits, and workspace layout.
# Keep Ghostty focused on window feel, font, theme, and clipboard.
```

Expected: no keybindings or visual settings are changed in this task.

- [ ] **Step 3: Verify chezmoi diff**

Run:

```bash
chezmoi diff ~/.config/ghostty/config
```

Expected: the diff shows the source-managed Ghostty config and only the added comments if the target file is already identical.

- [ ] **Step 4: Commit Ghostty source**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/dot_config/ghostty/config
git commit -m "feat: manage Ghostty config"
```

Expected: a chezmoi commit records the Ghostty config.

### Task 4: Add Oh My Tmux Local Configuration

**Files:**
- Create: `~/.local/share/chezmoi/home/symlink_dot_tmux.conf`
- Create: `~/.local/share/chezmoi/home/dot_tmux.conf.local`

- [ ] **Step 1: Add `.tmux.conf` symlink source**

Create `~/.local/share/chezmoi/home/symlink_dot_tmux.conf` with:

```text
.tmux/.tmux.conf
```

Expected: chezmoi will create `~/.tmux.conf -> .tmux/.tmux.conf`.

- [ ] **Step 2: Add restrained local tmux config**

Create `~/.local/share/chezmoi/home/dot_tmux.conf.local` with:

```tmux
# Personal overrides for Oh My Tmux.

set -g prefix C-a
set -g prefix2 C-b
unbind C-b
bind C-a send-prefix
bind C-b send-prefix -2

set -g default-terminal "tmux-256color"
set -as terminal-features ",xterm-256color:RGB"
set -g allow-passthrough on
set -g mouse on
set -g escape-time 10
set -g focus-events on

set -g status-interval 5
set -g status-position bottom
set -g status-style "bg=#16161e,fg=#a9b1d6"
set -g status-left-length 60
set -g status-right-length 120
set -g status-left "#[fg=#7dcfff,bold] #S #[fg=#414868] "
set -g status-right "#[fg=#414868]#{pane_current_path} #[fg=#e0af68]#(git -C '#{pane_current_path}' branch --show-current 2>/dev/null) #[fg=#7dcfff]%H:%M "

set -g window-status-format " #I:#W "
set -g window-status-current-format "#[fg=#16161e,bg=#7dcfff,bold] #I:#W #[default]"

bind r source-file ~/.tmux.conf \; display-message "tmux config reloaded"
bind s display-popup -E -w 85% -h 80% "ws"
bind c new-window -c "#{pane_current_path}"
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

bind p display-popup -E -w 70% -h 70% -d "#{pane_current_path}" "$SHELL"
bind P display-popup -E -w 85% -h 80% -d "#{pane_current_path}" "ws panel context"

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'

set -g @resurrect-strategy-nvim 'session'
set -g @resurrect-capture-pane-contents 'on'
```

Expected: tmux has `C-a`, `C-a s`, popup support, Tokyo Night-style status, and core plugins configured.

- [ ] **Step 3: Apply and verify tmux files**

Run:

```bash
chezmoi apply ~/.tmux.conf ~/.tmux.conf.local
test -L "$HOME/.tmux.conf"
test -f "$HOME/.tmux.conf.local"
```

Expected: the symlink and local config exist. Do not start tmux until `tmux` is installed.

- [ ] **Step 4: Start tmux and install plugins**

Run:

```bash
tmux new-session -d -s ws-smoke 'sleep 2'
tmux source-file ~/.tmux.conf
tmux kill-session -t ws-smoke
```

Then inside an interactive tmux session, press `C-a I` to install TPM plugins if `~/.tmux/plugins/tpm` has not installed them yet.

Expected: tmux starts without configuration errors.

- [ ] **Step 5: Commit tmux source**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/symlink_dot_tmux.conf home/dot_tmux.conf.local
git commit -m "feat: add tmux workbench base"
```

Expected: a chezmoi commit records tmux base config.

## Batch 2: `ws` Workspace System

### Task 5: Add `ws` Config, Prompts, and Test Skeleton

**Files:**
- Create: `~/.local/share/chezmoi/home/dot_config/ws/config.toml`
- Create: `~/.local/share/chezmoi/home/dot_local/share/ws/prompts/git-plan.md`
- Create: `~/.local/share/chezmoi/home/dot_local/share/ws/prompts/git-review.md`
- Create: `~/.local/share/chezmoi/home/dot_local/share/ws/prompts/git-message.md`
- Create: `~/.local/share/chezmoi/home/dot_local/share/ws/tests/test_ws.py`

- [ ] **Step 1: Add default ws config**

Create `~/.local/share/chezmoi/home/dot_config/ws/config.toml` with:

```toml
[ui]
picker = "fzf"
confirm = "gum"

[workspaces]
pinned = [
  "~/.config/nvim",
]
hidden = []
recent_limit = 30

[ai]
interactive_default = "codex"
git_agent_default = "codex"
headless_default = "codex"

[ai.commands]
codex = "codex"
opencode = "opencode"

[ai.headless]
codex = "codex exec --sandbox read-only --ephemeral --output-last-message {output} -C {cwd} -"
opencode = "opencode run"
```

Expected: defaults prefer Codex but remain role-configurable.

- [ ] **Step 2: Add Git prompt files**

Create `git-plan.md`:

```markdown
You are a Git finishing assistant.

Analyze the context file the user provides. Return a commit plan only.

Rules:
- Do not run git commands.
- Do not modify files.
- Do not stage or commit.
- Group changes into atomic commits.
- For each group include title, body, files/hunks, risk notes, and verification suggestion.
- If a file contains mixed concerns, say that hunk-level staging may be needed.
```

Create `git-review.md`:

```markdown
You are a Git review assistant.

Analyze the provided staged or working-tree diff.

Return:
- correctness risks
- missing tests
- suspicious unrelated changes
- conflict or migration risks
- a concise recommendation: commit, revise, or split

Rules:
- Do not run git commands.
- Do not modify files.
- Do not stage or commit.
```

Create `git-message.md`:

```markdown
Write a high-quality Git commit message for the staged diff.

Output only the commit message.

Format:
<type>: <short imperative summary>

<body explaining why this changed and any important behavior>

Rules:
- Use conventional type when obvious: feat, fix, docs, refactor, test, chore.
- Keep the title under 72 characters.
- Do not mention AI.
- Do not wrap the body awkwardly.
- If the diff is empty, output: chore: no staged changes
```

Expected: prompts are personal `ws` prompts and do not modify Superpowers.

- [ ] **Step 3: Add test skeleton**

Create `~/.local/share/chezmoi/home/dot_local/share/ws/tests/test_ws.py` with:

```python
import importlib.util
import importlib.machinery
import pathlib
import tempfile
import unittest


SOURCE = pathlib.Path.home() / ".local/share/chezmoi/home/dot_local/bin/executable_ws"


def load_ws():
    loader = importlib.machinery.SourceFileLoader("ws_tool", str(SOURCE))
    spec = importlib.util.spec_from_loader("ws_tool", loader)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class WsUnitTests(unittest.TestCase):
    def test_session_name_sanitizes_path(self):
        ws = load_ws()
        self.assertEqual(ws.sanitize_session_name("repo feature/x"), "repo-feature-x")

    def test_kind_for_path_detects_config(self):
        ws = load_ws()
        self.assertEqual(ws.kind_for_path(pathlib.Path.home() / ".config/nvim"), "config")

    def test_state_round_trip(self):
        ws = load_ws()
        with tempfile.TemporaryDirectory() as tmp:
            state_path = pathlib.Path(tmp) / "recent.json"
            ws.write_json(state_path, {"recent": [{"path": "/tmp/demo"}]})
            self.assertEqual(ws.read_json(state_path, {"recent": []})["recent"][0]["path"], "/tmp/demo")


if __name__ == "__main__":
    unittest.main()
```

Expected: tests fail until `executable_ws` exists.

- [ ] **Step 4: Commit config and prompt skeleton**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/dot_config/ws/config.toml home/dot_local/share/ws/prompts home/dot_local/share/ws/tests/test_ws.py
git commit -m "feat: add ws config and prompts"
```

Expected: chezmoi records ws configuration before script implementation.

### Task 6: Implement the `ws` Command Core

**Files:**
- Create: `~/.local/share/chezmoi/home/dot_local/bin/executable_ws`

- [ ] **Step 1: Create executable Python entrypoint**

Create `~/.local/share/chezmoi/home/dot_local/bin/executable_ws` with this header and imports:

```python
#!/usr/bin/env python3
from __future__ import annotations

import argparse
import datetime as dt
import json
import os
import pathlib
import re
import shlex
import subprocess
import sys
import tempfile
import textwrap
import tomllib
from dataclasses import dataclass
from typing import Iterable


HOME = pathlib.Path.home()
CONFIG_PATH = HOME / ".config/ws/config.toml"
LOCAL_CONFIG_PATH = HOME / ".config/ws/local.toml"
STATE_DIR = HOME / ".local/state/ws"
RECENT_PATH = STATE_DIR / "recent.json"
CONTEXT_DIR = STATE_DIR / "context"
COMMIT_MSG_DIR = STATE_DIR / "commit-msg"
PROMPT_DIR = HOME / ".local/share/ws/prompts"
```

Expected: file starts as a Python executable and uses only the standard library.

- [ ] **Step 2: Add utility functions**

Append these functions:

```python
def run(args: list[str], cwd: pathlib.Path | None = None, input_text: str | None = None, check: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=cwd, input=input_text, text=True, capture_output=True, check=check)


def command_exists(command: str) -> bool:
    return run(["sh", "-lc", f"command -v {shlex.quote(command)}"]).returncode == 0


def expand(path: str) -> pathlib.Path:
    return pathlib.Path(os.path.expandvars(os.path.expanduser(path))).resolve()


def read_json(path: pathlib.Path, default):
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError:
        return default


def write_json(path: pathlib.Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    tmp.replace(path)


def read_toml(path: pathlib.Path) -> dict:
    if not path.exists():
        return {}
    with path.open("rb") as fh:
        return tomllib.load(fh)


def merged_config() -> dict:
    base = read_toml(CONFIG_PATH)
    local = read_toml(LOCAL_CONFIG_PATH)
    return deep_merge(base, local)


def deep_merge(a: dict, b: dict) -> dict:
    out = dict(a)
    for key, value in b.items():
        if isinstance(value, dict) and isinstance(out.get(key), dict):
            out[key] = deep_merge(out[key], value)
        else:
            out[key] = value
    return out


def sanitize_session_name(name: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_.@-]+", "-", name.strip())
    cleaned = cleaned.strip("-")
    return cleaned or "workspace"


def kind_for_path(path: pathlib.Path) -> str:
    if path == HOME / ".config/nvim":
        return "config"
    git_dir = run(["git", "-C", str(path), "rev-parse", "--git-dir"]).stdout.strip()
    if ".worktrees" in str(path) or "worktrees" in str(path):
        return "worktree"
    if git_dir:
        return "repo"
    return "path"
```

Expected: unit tests can import these functions.

- [ ] **Step 3: Add workspace candidate model**

Append:

```python
@dataclass(frozen=True)
class Candidate:
    label: str
    path: pathlib.Path
    kind: str
    source: str

    def line(self) -> str:
        return f"{self.source:<8} {self.label:<32} {self.path}"


def git_branch(path: pathlib.Path) -> str:
    cp = run(["git", "-C", str(path), "branch", "--show-current"])
    return cp.stdout.strip()


def repo_name(path: pathlib.Path) -> str:
    root = run(["git", "-C", str(path), "rev-parse", "--show-toplevel"]).stdout.strip()
    return pathlib.Path(root).name if root else path.name


def worktree_label(path: pathlib.Path) -> str:
    branch = git_branch(path)
    name = repo_name(path)
    return f"{name}@{branch}" if branch else f"{name}@{path.name}"


def session_name_for_path(path: pathlib.Path) -> str:
    kind = kind_for_path(path)
    label = worktree_label(path) if kind == "worktree" else path.name
    if path == HOME / ".config/nvim":
        label = "nvim-config"
    return sanitize_session_name(label)
```

Expected: candidates can render stable labels and session names.

- [ ] **Step 4: Add recent/pinned/session discovery**

Append:

```python
def active_sessions() -> list[Candidate]:
    cp = run(["tmux", "list-sessions", "-F", "#{session_name}\t#{@ws_root}\t#{@ws_kind}"])
    if cp.returncode != 0:
        return []
    out = []
    for line in cp.stdout.splitlines():
        name, root, kind = (line.split("\t") + ["", ""])[:3]
        if root:
            out.append(Candidate(name, expand(root), kind or "session", "active"))
    return out


def pinned_projects(config: dict) -> list[Candidate]:
    pinned = config.get("workspaces", {}).get("pinned", [])
    result = []
    for item in pinned:
        path = expand(item)
        if path.exists():
            result.append(Candidate(session_name_for_path(path), path, kind_for_path(path), "pinned"))
    return result


def recent_projects() -> list[Candidate]:
    state = read_json(RECENT_PATH, {"recent": []})
    result = []
    for item in state.get("recent", []):
        path = expand(item["path"])
        if path.exists():
            result.append(Candidate(item.get("label") or session_name_for_path(path), path, item.get("kind", kind_for_path(path)), "recent"))
    return result


def git_worktrees_for(path: pathlib.Path) -> list[Candidate]:
    cp = run(["git", "-C", str(path), "worktree", "list", "--porcelain"])
    if cp.returncode != 0:
        return []
    result = []
    current: dict[str, str] = {}
    for line in cp.stdout.splitlines() + [""]:
        if not line:
            if "worktree" in current:
                wt_path = pathlib.Path(current["worktree"]).resolve()
                label = worktree_label(wt_path)
                result.append(Candidate(label, wt_path, "worktree", "worktree"))
            current = {}
            continue
        key, _, value = line.partition(" ")
        current[key] = value
    return result


def all_candidates(config: dict) -> list[Candidate]:
    base = active_sessions() + recent_projects() + pinned_projects(config)
    expanded: list[Candidate] = []
    for candidate in base:
        expanded.extend(git_worktrees_for(candidate.path))
    seen = set()
    ordered = []
    for candidate in base + expanded:
        key = (candidate.path, candidate.source)
        if key not in seen:
            seen.add(key)
            ordered.append(candidate)
    return ordered
```

Expected: `ws --list` can show active/recent/pinned plus worktrees from Git metadata.

- [ ] **Step 5: Add tmux open/create behavior**

Append:

```python
def inside_tmux() -> bool:
    return bool(os.environ.get("TMUX"))


def tmux_has_session(name: str) -> bool:
    return run(["tmux", "has-session", "-t", name]).returncode == 0


def remember(candidate: Candidate, config: dict) -> None:
    limit = int(config.get("workspaces", {}).get("recent_limit", 30))
    state = read_json(RECENT_PATH, {"recent": []})
    entry = {
        "path": str(candidate.path),
        "label": candidate.label,
        "kind": candidate.kind,
        "last_opened": dt.datetime.now(dt.UTC).isoformat(),
    }
    recent = [item for item in state.get("recent", []) if item.get("path") != str(candidate.path)]
    state["recent"] = [entry] + recent[: max(0, limit - 1)]
    write_json(RECENT_PATH, state)


def create_session(candidate: Candidate, config: dict) -> None:
    name = session_name_for_path(candidate.path)
    shell = os.environ.get("SHELL", "/bin/sh")
    ai_name = os.environ.get("WS_AI") or config.get("ai", {}).get("interactive_default", "codex")
    agent_command = config.get("ai", {}).get("commands", {}).get(ai_name, ai_name)
    if tmux_has_session(name):
        return
    run(["tmux", "new-session", "-d", "-s", name, "-n", "code", "-c", str(candidate.path), f"nvim .; exec {shell}"], check=True)
    run(["tmux", "new-window", "-t", name, "-n", "agent", "-c", str(candidate.path), agent_command], check=True)
    run(["tmux", "new-window", "-t", name, "-n", "git", "-c", str(candidate.path), f"lazygit || exec {shell}"], check=True)
    run(["tmux", "new-window", "-t", name, "-n", "run", "-c", str(candidate.path), shell], check=True)
    run(["tmux", "set-option", "-t", name, "@ws_managed", "1"], check=True)
    run(["tmux", "set-option", "-t", name, "@ws_root", str(candidate.path)], check=True)
    run(["tmux", "set-option", "-t", name, "@ws_kind", candidate.kind], check=True)
    agent_pane = run(["tmux", "display-message", "-p", "-t", f"{name}:agent", "#{pane_id}"], check=True).stdout.strip()
    run(["tmux", "set-option", "-t", name, "@ws_agent_target", agent_pane], check=True)
    run(["tmux", "select-window", "-t", f"{name}:code"], check=True)


def open_candidate(candidate: Candidate, config: dict) -> None:
    remember(candidate, config)
    name = session_name_for_path(candidate.path)
    create_session(candidate, config)
    if inside_tmux():
        run(["tmux", "switch-client", "-t", name], check=True)
    else:
        os.execvp("tmux", ["tmux", "attach-session", "-t", name])
```

Expected: opening a candidate creates a four-window tmux session, starts the configured interactive agent in `agent`, records `@ws_agent_target`, and switches/attaches.

- [ ] **Step 6: Add CLI parser and picker**

Append:

```python
def pick_candidate(candidates: list[Candidate]) -> Candidate | None:
    if not candidates:
        return None
    lines = "\n".join(c.line() for c in candidates)
    cp = run(["fzf", "--ansi", "--prompt=ws> ", "--height=80%", "--reverse"], input_text=lines)
    if cp.returncode != 0 or not cp.stdout.strip():
        return None
    selected = cp.stdout.strip()
    for candidate in candidates:
        if selected == candidate.line():
            return candidate
    return None


def cmd_list(config: dict) -> int:
    for candidate in all_candidates(config):
        print(candidate.line())
    return 0


def cmd_open(path_arg: str, config: dict) -> int:
    path = expand(path_arg)
    if not path.exists():
        print(f"ws: path does not exist: {path}", file=sys.stderr)
        return 1
    open_candidate(Candidate(session_name_for_path(path), path, kind_for_path(path), "path"), config)
    return 0


def cmd_picker(config: dict) -> int:
    picked = pick_candidate(all_candidates(config))
    if picked is None:
        return 0
    open_candidate(picked, config)
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="ws")
    parser.add_argument("args", nargs="*")
    parser.add_argument("--list", action="store_true")
    ns = parser.parse_args(argv)
    config = merged_config()
    if ns.list:
        return cmd_list(config)
    if ns.args and (ns.args[0] == "." or pathlib.Path(ns.args[0]).exists()):
        return cmd_open(ns.args[0], config)
    return cmd_picker(config)


if __name__ == "__main__":
    raise SystemExit(main())
```

Expected: `ws --list` and `ws .` work before advanced commands are added.

- [ ] **Step 7: Run unit and syntax tests**

Run:

```bash
python -m py_compile "$HOME/.local/share/chezmoi/home/dot_local/bin/executable_ws"
python "$HOME/.local/share/chezmoi/home/dot_local/share/ws/tests/test_ws.py"
```

Expected: tests pass after the functions above exist.

- [ ] **Step 8: Apply `ws` executable**

Run:

```bash
chezmoi apply ~/.local/bin/ws ~/.config/ws/config.toml ~/.local/share/ws
command -v ws
ws --list
```

Expected: `ws` is executable from `~/.local/bin`, and `ws --list` prints pinned/recent candidates.

- [ ] **Step 9: Commit `ws` core**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/dot_local/bin/executable_ws home/dot_config/ws/config.toml home/dot_local/share/ws/tests/test_ws.py
git commit -m "feat: add ws workspace picker"
```

Expected: chezmoi records the first working `ws` implementation.

### Task 7: Add `ws` Maintenance and Agent Bridge Commands

**Files:**
- Modify: `~/.local/share/chezmoi/home/dot_local/bin/executable_ws`

- [ ] **Step 1: Add doctor and pin helpers**

Add these functions before `main()`:

```python
def git_root(path: pathlib.Path) -> pathlib.Path:
    cp = run(["git", "-C", str(path), "rev-parse", "--show-toplevel"])
    return pathlib.Path(cp.stdout.strip()).resolve() if cp.returncode == 0 and cp.stdout.strip() else path.resolve()


def cmd_pin(config: dict) -> int:
    root = git_root(pathlib.Path.cwd())
    CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)
    pinned = config.setdefault("workspaces", {}).setdefault("pinned", [])
    root_s = str(root)
    if root_s not in pinned:
        pinned.append(root_s)
    lines = ["[ui]", 'picker = "fzf"', 'confirm = "gum"', "", "[workspaces]", "pinned = ["]
    lines.extend(f'  "{item}",' for item in pinned)
    lines.extend(["]", "hidden = []", "recent_limit = 30", ""])
    lines.extend(["[ai]", 'interactive_default = "codex"', 'git_agent_default = "codex"', 'headless_default = "codex"', ""])
    lines.extend(["[ai.commands]", 'codex = "codex"', 'opencode = "opencode"', ""])
    lines.extend(["[ai.headless]", 'codex = "codex exec --sandbox read-only --ephemeral --output-last-message {output} -C {cwd} -"', 'opencode = "opencode run"', ""])
    CONFIG_PATH.write_text("\n".join(lines))
    print(f"pinned {root}")
    return 0


def cmd_doctor(config: dict) -> int:
    state = read_json(RECENT_PATH, {"recent": []})
    alive = []
    removed = []
    for item in state.get("recent", []):
        path = expand(item["path"])
        if path.exists():
            alive.append(item)
        else:
            removed.append(item)
    state["recent"] = alive
    write_json(RECENT_PATH, state)
    for item in removed:
        print(f"removed stale recent: {item.get('path')}")
    for session in active_sessions():
        if not session.path.exists() and session.kind:
            run(["tmux", "kill-session", "-t", session.label])
            print(f"killed stale ws session: {session.label}")
    return 0
```

Expected: `ws pin` adds the current Git root to pinned config, and `ws doctor` removes stale recent entries.

- [ ] **Step 2: Add agent window and send helpers**

Append:

```python
def current_session() -> str:
    cp = run(["tmux", "display-message", "-p", "#{session_name}"])
    return cp.stdout.strip()


def ensure_agent_window(config: dict, name: str = "agent-git") -> str:
    session = current_session()
    if name == "agent":
        target = run(["tmux", "show-option", "-t", session, "-v", "@ws_agent_target"]).stdout.strip()
        if target:
            return target
    pane_cp = run(["tmux", "list-panes", "-a", "-F", "#{session_name}:#{window_name}:#{pane_id}"])
    for line in pane_cp.stdout.splitlines():
        sess, window, pane = line.split(":", 2)
        if sess == session and window == name:
            if name == "agent":
                run(["tmux", "set-option", "-t", session, "@ws_agent_target", pane])
            return pane
    root_cp = run(["tmux", "show-option", "-t", session, "-v", "@ws_root"])
    root = root_cp.stdout.strip() or str(pathlib.Path.cwd())
    ai_name = os.environ.get("WS_AI") or config.get("ai", {}).get("git_agent_default", "codex")
    command = config.get("ai", {}).get("commands", {}).get(ai_name, ai_name)
    run(["tmux", "new-window", "-t", session, "-n", name, "-c", root, command], check=True)
    pane_cp = run(["tmux", "display-message", "-p", "-t", f"{session}:{name}", "#{pane_id}"], check=True)
    pane = pane_cp.stdout.strip()
    if name == "agent":
        run(["tmux", "set-option", "-t", session, "@ws_agent_target", pane])
    return pane


def send_to_pane(pane_id: str, text: str) -> None:
    run(["tmux", "send-keys", "-t", pane_id, "-l", text], check=True)
    run(["tmux", "send-keys", "-t", pane_id, "C-m"], check=True)
```

Expected: `ws` can find or create `agent-git` and send literal text safely.

- [ ] **Step 3: Wire subcommands into `main()`**

Replace the first branch in `main()` after config load with:

```python
    if ns.args == ["pin"]:
        return cmd_pin(config)
    if ns.args == ["doctor"]:
        return cmd_doctor(config)
```

Expected: `ws pin` and `ws doctor` are recognized.

- [ ] **Step 4: Test maintenance commands**

Run:

```bash
python -m py_compile "$HOME/.local/share/chezmoi/home/dot_local/bin/executable_ws"
chezmoi apply ~/.local/bin/ws
ws doctor
```

Expected: syntax passes and `ws doctor` exits successfully.

- [ ] **Step 5: Commit maintenance and bridge helpers**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/dot_local/bin/executable_ws
git commit -m "feat: add ws maintenance and agent bridge"
```

Expected: chezmoi records the maintenance and agent bridge additions.

### Task 8: Add Worktree Creation, New Agent Windows, and Context Panels

**Files:**
- Modify: `~/.local/share/chezmoi/home/dot_local/bin/executable_ws`

- [ ] **Step 1: Add branch/worktree helpers**

Add these functions before `main()`:

```python
def existing_worktrees_by_branch(repo: pathlib.Path) -> dict[str, pathlib.Path]:
    cp = run(["git", "-C", str(repo), "worktree", "list", "--porcelain"])
    result: dict[str, pathlib.Path] = {}
    current: dict[str, str] = {}
    for line in cp.stdout.splitlines() + [""]:
        if not line:
            branch = current.get("branch", "")
            path = current.get("worktree", "")
            if branch.startswith("refs/heads/") and path:
                result[branch.removeprefix("refs/heads/")] = pathlib.Path(path).resolve()
            current = {}
            continue
        key, _, value = line.partition(" ")
        current[key] = value
    return result


def worktree_base(repo: pathlib.Path) -> pathlib.Path:
    for name in (".worktrees", "worktrees"):
        candidate = repo / name
        if candidate.exists() and run(["git", "-C", str(repo), "check-ignore", "-q", name]).returncode == 0:
            return candidate
    return HOME / ".config/superpowers/worktrees" / repo.name


def branch_choices(repo: pathlib.Path) -> list[tuple[str, str, str]]:
    existing = existing_worktrees_by_branch(repo)
    choices: list[tuple[str, str, str]] = []
    local_cp = run(["git", "-C", str(repo), "branch", "--format=%(refname:short)"])
    for branch in local_cp.stdout.splitlines():
        if branch in existing:
            choices.append(("worktree", branch, str(existing[branch])))
        else:
            choices.append(("local", branch, ""))
    remote_cp = run(["git", "-C", str(repo), "branch", "-r", "--format=%(refname:short)"])
    for branch in remote_cp.stdout.splitlines():
        if branch.endswith("/HEAD"):
            continue
        local_name = branch.split("/", 1)[1] if "/" in branch else branch
        if local_name not in existing:
            choices.append(("remote", branch, ""))
    return choices


def cmd_worktree(config: dict) -> int:
    repo = git_root(pathlib.Path.cwd())
    if run(["git", "-C", str(repo), "rev-parse", "--is-inside-work-tree"]).returncode != 0:
        print("ws: run worktree creation from inside a git repository", file=sys.stderr)
        return 1
    choices = branch_choices(repo)
    lines = [f"{kind:<9} {branch:<40} {path or '-'}" for kind, branch, path in choices]
    cp = run(["fzf", "--prompt=branch> ", "--height=80%", "--reverse"], input_text="\n".join(lines))
    if cp.returncode != 0 or not cp.stdout.strip():
        return 0
    selected = cp.stdout.strip()
    kind, branch, path = selected.split(None, 2)
    if kind == "worktree":
        return cmd_open(path.strip(), config)
    safe_branch = sanitize_session_name(branch.split("/", 1)[1] if kind == "remote" and "/" in branch else branch)
    target = worktree_base(repo) / safe_branch
    if command_exists("gum"):
        confirm = run(["gum", "confirm", f"Create worktree at {target}?"])
        if confirm.returncode != 0:
            return 1
    target.parent.mkdir(parents=True, exist_ok=True)
    if kind == "remote":
        local_name = branch.split("/", 1)[1] if "/" in branch else branch
        add = run(["git", "-C", str(repo), "worktree", "add", "--track", "-b", local_name, str(target), branch])
    else:
        add = run(["git", "-C", str(repo), "worktree", "add", str(target), branch])
    if add.returncode != 0:
        print(add.stderr, file=sys.stderr)
        return add.returncode
    return cmd_open(str(target), config)
```

Expected: `ws worktree` can open an existing worktree or explicitly create one from a selected branch.

- [ ] **Step 2: Add new-agent helper**

Add:

```python
def cmd_new_agent(args: list[str], config: dict) -> int:
    session = current_session()
    name = args[0] if args else "agent-extra"
    root_cp = run(["tmux", "show-option", "-t", session, "-v", "@ws_root"])
    root = root_cp.stdout.strip() or str(pathlib.Path.cwd())
    ai_name = os.environ.get("WS_AI") or config.get("ai", {}).get("interactive_default", "codex")
    command = config.get("ai", {}).get("commands", {}).get(ai_name, ai_name)
    run(["tmux", "new-window", "-t", session, "-n", name, "-c", root, command], check=True)
    print(f"created {name} with {ai_name}")
    return 0
```

Expected: `ws new-agent agent-plan` creates a dedicated agent window using the configured interactive default.

- [ ] **Step 3: Add context panel helper**

Add:

```python
def cmd_panel(args: list[str], config: dict) -> int:
    topic = args[0] if args else "context"
    session = current_session() if inside_tmux() else "shell"
    context_dir = CONTEXT_DIR / sanitize_session_name(session)
    context_dir.mkdir(parents=True, exist_ok=True)
    if topic == "context":
        files = sorted(context_dir.glob("*.md"), key=lambda p: p.stat().st_mtime, reverse=True)
        if not files:
            print("no context files")
            return 0
        lines = "\n".join(str(p) for p in files)
        cp = run(["fzf", "--prompt=context> ", "--preview", "bat --style=plain --color=always {}"], input_text=lines)
        if cp.returncode == 0 and cp.stdout.strip():
            viewer = "bat --style=plain --paging=always " + shlex.quote(cp.stdout.strip())
            os.execvp("sh", ["sh", "-lc", viewer])
    return 0
```

Expected: `ws panel context` lists recent context files and previews them with `bat`.

- [ ] **Step 4: Add picker action candidate**

Modify `cmd_picker()` so it appends one synthetic line after workspace candidates:

```python
def cmd_picker(config: dict) -> int:
    candidates = all_candidates(config)
    action_line = "action   + create/open worktree from branch"
    lines = "\n".join(c.line() for c in candidates) + "\n" + action_line
    cp = run(["fzf", "--ansi", "--prompt=ws> ", "--height=80%", "--reverse"], input_text=lines)
    if cp.returncode != 0 or not cp.stdout.strip():
        return 0
    selected = cp.stdout.strip()
    if selected == action_line:
        return cmd_worktree(config)
    for candidate in candidates:
        if selected == candidate.line():
            open_candidate(candidate, config)
            return 0
    return 0
```

Expected: daily `ws` includes branch-to-worktree creation as an action, not as a separate mental mode.

- [ ] **Step 5: Wire new commands into `main()`**

Add:

```python
    if ns.args[:1] == ["worktree"]:
        return cmd_worktree(config)
    if ns.args[:1] == ["new-agent"]:
        return cmd_new_agent(ns.args[1:], config)
    if ns.args[:1] == ["panel"]:
        return cmd_panel(ns.args[1:], config)
```

Expected: `ws worktree`, `ws new-agent`, and `ws panel context` are available.

- [ ] **Step 6: Test syntax and safe worktree behavior**

Run:

```bash
python -m py_compile "$HOME/.local/share/chezmoi/home/dot_local/bin/executable_ws"
```

Then run inside a disposable repository:

```bash
tmp=$(mktemp -d)
git -C "$tmp" init
git -C "$tmp" config user.email test@example.com
git -C "$tmp" config user.name Test
printf 'one\n' > "$tmp/file.txt"
git -C "$tmp" add file.txt
git -C "$tmp" commit -m "chore: initial"
git -C "$tmp" branch feature/demo
(cd "$tmp" && printf 'local     feature/demo                              \n' | true)
```

Expected: syntax passes. Do not run `ws worktree` in a real project during this step.

- [ ] **Step 7: Commit worktree/agent/panel actions**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/dot_local/bin/executable_ws
git commit -m "feat: add ws worktree and panel actions"
```

Expected: chezmoi records the remaining workspace actions.

## Batch 3: Git/AI Finishing and Editor Bridge

### Task 9: Add Git Context, AI Message, and Commit Commands

**Files:**
- Modify: `~/.local/share/chezmoi/home/dot_local/bin/executable_ws`

- [ ] **Step 1: Add Git context generation**

Append before `main()`:

```python
def repo_slug(path: pathlib.Path) -> str:
    root = git_root(path)
    return sanitize_session_name(root.name)


def write_context(name: str, content: str) -> pathlib.Path:
    session = current_session() if inside_tmux() else "shell"
    target_dir = CONTEXT_DIR / sanitize_session_name(session)
    target_dir.mkdir(parents=True, exist_ok=True)
    path = target_dir / name
    path.write_text(content)
    return path


def git_context(mode: str, cwd: pathlib.Path, selected_file: str | None = None) -> pathlib.Path:
    args_suffix = ["--", selected_file] if selected_file else []
    parts = [
        f"# Git context: {mode}",
        "",
        f"Repository: {git_root(cwd)}",
        f"Branch: {git_branch(cwd) or '(detached)'}",
        "",
        "## Status",
        run(["git", "-C", str(cwd), "status", "--short"]).stdout or "clean\n",
        "## Recent commits",
        run(["git", "-C", str(cwd), "log", "--oneline", "-n", "10"]).stdout,
        "## Staged diff stat",
        run(["git", "-C", str(cwd), "diff", "--cached", "--stat", *args_suffix]).stdout or "no staged diff\n",
        "## Staged diff",
        run(["git", "-C", str(cwd), "diff", "--cached", *args_suffix]).stdout or "no staged diff\n",
    ]
    if mode in {"plan", "review-all"}:
        parts.extend([
            "## Unstaged diff stat",
            run(["git", "-C", str(cwd), "diff", "--stat", *args_suffix]).stdout or "no unstaged diff\n",
            "## Unstaged diff",
            run(["git", "-C", str(cwd), "diff", *args_suffix]).stdout or "no unstaged diff\n",
        ])
    return write_context(f"git-{mode}.md", "\n".join(parts))


def read_prompt(name: str) -> str:
    return (PROMPT_DIR / name).read_text()
```

Expected: `git_context()` writes context outside the project tree.

- [ ] **Step 2: Add git plan/review send commands**

Append:

```python
def cmd_git_send(mode: str, config: dict) -> int:
    cwd = pathlib.Path.cwd()
    context_path = git_context(mode, cwd)
    prompt_name = "git-plan.md" if mode == "plan" else "git-review.md"
    prompt = read_prompt(prompt_name)
    pane = ensure_agent_window(config, "agent-git")
    send_to_pane(pane, f"{prompt}\n\nRead this context file and respond in the agent window:\n{context_path}")
    print(f"sent {mode} context to agent-git: {context_path}")
    return 0
```

Expected: plan/review requests go to an isolated `agent-git` window.

- [ ] **Step 3: Add headless commit message generation**

Append:

```python
def shell_split(command: str) -> list[str]:
    return shlex.split(command)


def cmd_git_message(config: dict) -> int:
    cwd = pathlib.Path.cwd()
    staged = run(["git", "-C", str(cwd), "diff", "--cached"]).stdout
    COMMIT_MSG_DIR.mkdir(parents=True, exist_ok=True)
    output = COMMIT_MSG_DIR / f"{repo_slug(cwd)}.txt"
    if not staged.strip():
        output.write_text("chore: no staged changes\n")
        print(output)
        return 0
    prompt = read_prompt("git-message.md") + "\n\n```diff\n" + staged + "\n```\n"
    ai_name = os.environ.get("WS_AI") or config.get("ai", {}).get("headless_default", "codex")
    template = config.get("ai", {}).get("headless", {}).get(ai_name)
    if not template:
        print(f"ws: no headless command configured for {ai_name}", file=sys.stderr)
        return 1
    if ai_name == "codex":
        command = template.format(output=str(output), cwd=str(cwd))
        cp = run(shell_split(command), cwd=cwd, input_text=prompt)
    elif ai_name == "opencode":
        cp = run(shell_split(template) + [prompt], cwd=cwd)
        output.write_text(cp.stdout)
    else:
        cp = run(shell_split(template), cwd=cwd, input_text=prompt)
        output.write_text(cp.stdout)
    if cp.returncode != 0:
        print(cp.stderr, file=sys.stderr)
        return cp.returncode
    print(output)
    return 0


def cmd_git_commit_ai(config: dict) -> int:
    cwd = pathlib.Path.cwd()
    msg = COMMIT_MSG_DIR / f"{repo_slug(cwd)}.txt"
    if not msg.exists():
        rc = cmd_git_message(config)
        if rc != 0:
            return rc
    preview = msg.read_text()
    print(preview)
    if command_exists("gum"):
        confirm = run(["gum", "confirm", "Commit staged changes with this AI message?"])
        if confirm.returncode != 0:
            print("commit cancelled")
            return 1
    else:
        answer = input("Commit staged changes with this AI message? [y/N] ")
        if answer.lower() != "y":
            print("commit cancelled")
            return 1
    cp = run(["git", "-C", str(cwd), "commit", "-F", str(msg)])
    sys.stdout.write(cp.stdout)
    sys.stderr.write(cp.stderr)
    return cp.returncode
```

Expected: staged diff can produce a commit message file and commit only after confirmation.

- [ ] **Step 4: Add `ws git` dispatch**

Update `main()` after config load:

```python
    if ns.args[:2] == ["git", "plan"]:
        return cmd_git_send("plan", config)
    if ns.args[:2] == ["git", "review"]:
        return cmd_git_send("review-all", config)
    if ns.args[:2] == ["git", "message"]:
        return cmd_git_message(config)
    if ns.args[:2] == ["git", "commit-ai"]:
        return cmd_git_commit_ai(config)
```

Expected: lazygit can call `ws git plan`, `ws git review`, `ws git message`, and `ws git commit-ai`.

- [ ] **Step 5: Test Git commands in a temporary repository**

Run:

```bash
tmp=$(mktemp -d)
git -C "$tmp" init
git -C "$tmp" config user.email test@example.com
git -C "$tmp" config user.name Test
printf 'one\n' > "$tmp/file.txt"
git -C "$tmp" add file.txt
git -C "$tmp" commit -m "chore: initial"
printf 'two\n' >> "$tmp/file.txt"
git -C "$tmp" add file.txt
(cd "$tmp" && ws git message)
test -s "$HOME/.local/state/ws/commit-msg/$(basename "$tmp").txt"
```

Expected: `ws git message` writes a non-empty commit message file. If the configured AI backend is unavailable, the command should fail without changing Git state.

- [ ] **Step 6: Commit Git lane in chezmoi**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/dot_local/bin/executable_ws home/dot_local/share/ws/prompts
git commit -m "feat: add AI Git finishing lane"
```

Expected: chezmoi records Git AI lane logic and prompts.

### Task 10: Configure Lazygit

**Files:**
- Create: `~/.local/share/chezmoi/home/dot_config/lazygit/config.yml`

- [ ] **Step 1: Add lazygit config**

Create `~/.local/share/chezmoi/home/dot_config/lazygit/config.yml` with:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json

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
  theme:
    activeBorderColor:
      - "#7dcfff"
      - bold
    inactiveBorderColor:
      - "#414868"
    searchingActiveBorderColor:
      - "#e0af68"
      - bold
    selectedLineBgColor:
      - "#283457"
    optionsTextColor:
      - "#7aa2f7"

customCommands:
  - key: "<c-g>"
    context: "global"
    description: "AI Git assistant"
    command: "ws git {{.Form.Action}}"
    output: terminal
    prompts:
      - type: "menu"
        title: "AI Git action"
        key: "Action"
        options:
          - name: "Plan commits"
            value: "plan"
          - name: "Review working tree"
            value: "review"
          - name: "Write message for staged diff"
            value: "message"
          - name: "Commit staged diff with AI message"
            value: "commit-ai"
```

Expected: lazygit has one AI entrypoint on `Ctrl-g`, keeping keybindings simple.

- [ ] **Step 2: Apply and validate lazygit config**

Run:

```bash
chezmoi apply ~/.config/lazygit/config.yml
lazygit --version
```

Expected: lazygit starts without config parse errors.

- [ ] **Step 3: Smoke test lazygit in this repository**

Run:

```bash
lazygit --path /home/chenchi/.config/nvim
```

Expected: lazygit opens. Press `q` to exit. Do not stage or commit unrelated changes.

- [ ] **Step 4: Commit lazygit source**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/dot_config/lazygit/config.yml
git commit -m "feat: configure lazygit workbench integration"
```

Expected: chezmoi records lazygit configuration.

### Task 11: Add Neovim `ws` Bridge and Git Plugin Cleanup

**Files:**
- Create: `lua/cccvno1/integrations/ws.lua`
- Modify: `lua/cccvno1/keymaps.lua`
- Modify: `lua/cccvno1/plugins/git.lua`
- Modify: `lua/cccvno1/core/health.lua`

- [ ] **Step 1: Add Neovim ws integration module**

Create `lua/cccvno1/integrations/ws.lua` with:

```lua
local M = {}

local function notify_result(label, result)
  if result.code == 0 then
    vim.notify(label .. " sent", vim.log.levels.INFO)
  else
    vim.notify(label .. " failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
  end
end

local function send_text(label, text)
  vim.system({ "ws", "agent-send", "--stdin", "--label", label }, { text = true, stdin = text }, function(result)
    vim.schedule(function()
      notify_result(label, result)
    end)
  end)
end

function M.selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getregion(start_pos, end_pos, { type = vim.fn.mode() })
  send_text("selection", table.concat(lines, "\n"))
end

function M.diagnostics()
  local diagnostics = vim.diagnostic.get(0)
  if vim.tbl_isempty(diagnostics) then
    vim.notify("No diagnostics in current buffer", vim.log.levels.INFO)
    return
  end
  local items = {}
  local name = vim.api.nvim_buf_get_name(0)
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(items, string.format("%s:%d:%d: %s", name, diagnostic.lnum + 1, diagnostic.col + 1, diagnostic.message))
  end
  send_text("diagnostics", table.concat(items, "\n"))
end

function M.quickfix()
  local items = vim.fn.getqflist()
  if vim.tbl_isempty(items) then
    vim.notify("Quickfix list is empty", vim.log.levels.INFO)
    return
  end
  local rendered = {}
  for _, item in ipairs(items) do
    local file = item.bufnr > 0 and vim.api.nvim_buf_get_name(item.bufnr) or ""
    table.insert(rendered, string.format("%s:%d:%d: %s", file, item.lnum, item.col, item.text))
  end
  send_text("quickfix", table.concat(rendered, "\n"))
end

function M.git_review()
  vim.system({ "ws", "git", "review" }, { text = true }, function(result)
    vim.schedule(function()
      notify_result("git review", result)
    end)
  end)
end

return M
```

Expected: Neovim can send selection, diagnostics, quickfix, and git review context through `ws`.

- [ ] **Step 2: Update keymaps**

Modify `lua/cccvno1/keymaps.lua`:

Replace:

```lua
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
map("n", "<leader>gd", "<cmd>CodeDiff<cr>", { desc = "Code diff" })
```

With:

```lua
map("n", "<leader>gg", "<cmd>DiffviewOpen<cr>", { desc = "Diffview" })
map("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
map("n", "<leader>gr", function() require("cccvno1.integrations.ws").git_review() end, { desc = "AI git review" })
```

Add near existing AI keymaps:

```lua
map("v", "<leader>as", function() require("cccvno1.integrations.ws").selection() end, { desc = "Send selection to agent" })
map("n", "<leader>ax", function() require("cccvno1.integrations.ws").diagnostics() end, { desc = "Send diagnostics to agent" })
map("n", "<leader>aq", function() require("cccvno1.integrations.ws").quickfix() end, { desc = "Send quickfix to agent" })
```

Expected: Neovim Git keymaps no longer depend on Neogit/codediff, and AI context has explicit `ws` bridge bindings.

- [ ] **Step 3: Simplify Git plugins**

Modify `lua/cccvno1/plugins/git.lua`:

Remove the `NeogitOrg/neogit` spec and `esmuellert/codediff.nvim` spec.

Add this standalone Diffview spec after gitsigns:

```lua
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
        },
      },
    },
  },
```

Expected: Neovim keeps gitsigns and Diffview, while lazygit owns broad Git UI.

- [ ] **Step 4: Update health dependencies**

Modify `lua/cccvno1/core/health.lua`:

Change:

```lua
local required = { "git", "rg", "fd", "fzf" }
local optional = { "node", "unzip", "codex", "opencode", "tree-sitter" }
```

To:

```lua
local required = { "git", "rg", "fd", "fzf" }
local optional = { "node", "unzip", "codex", "opencode", "tree-sitter", "tmux", "gum", "lazygit", "ws" }
```

Expected: Neovim health can report workbench tooling without making Neovim unusable if tmux/lazygit are missing.

- [ ] **Step 5: Run Neovim syntax checks**

Run:

```bash
nvim --headless "+lua require('cccvno1.integrations.ws')" +qa
nvim --headless "+Lazy! sync" +qa
```

Expected: the module loads and lazy.nvim resolves plugins. If the current repo has unrelated plugin-lock changes, do not revert them.

- [ ] **Step 6: Commit Neovim bridge changes**

Run:

```bash
git -C /home/chenchi/.config/nvim add lua/cccvno1/integrations/ws.lua lua/cccvno1/keymaps.lua lua/cccvno1/plugins/git.lua lua/cccvno1/core/health.lua
git -C /home/chenchi/.config/nvim commit -m "feat: add ws context bridge"
```

Expected: commit includes only Neovim bridge and Git plugin cleanup files. If these files already contain unrelated user changes, inspect hunks and stage only plan-related changes.

### Task 12: Add `ws agent-send --stdin`

**Files:**
- Modify: `~/.local/share/chezmoi/home/dot_local/bin/executable_ws`

- [ ] **Step 1: Add stdin agent-send implementation**

Append before `main()`:

```python
def cmd_agent_send(args: list[str], config: dict) -> int:
    label = "context"
    if "--label" in args:
        idx = args.index("--label")
        if idx + 1 < len(args):
            label = args[idx + 1]
    if "--stdin" in args:
        content = sys.stdin.read()
    else:
        content = " ".join(arg for arg in args if arg not in {"--stdin", "--label", label})
    if not content.strip():
        print("ws: no context to send", file=sys.stderr)
        return 1
    path = write_context(f"{sanitize_session_name(label)}.md", content)
    pane = ensure_agent_window(config, "agent")
    send_to_pane(pane, f"Please read this {label} context and help me use it:\n{path}")
    print(f"sent {label} context to agent: {path}")
    return 0
```

Expected: Neovim can pipe content to `ws agent-send --stdin`.

- [ ] **Step 2: Wire `agent-send` into `main()`**

Add:

```python
    if ns.args[:1] == ["agent-send"]:
        return cmd_agent_send(ns.args[1:], config)
```

Expected: `ws agent-send --stdin --label diagnostics` dispatches context to an agent window.

- [ ] **Step 3: Test with a tmux smoke session**

Run inside tmux:

```bash
printf 'example diagnostic\n' | ws agent-send --stdin --label smoke
```

Expected: `ws` creates or reuses an `agent` window and sends a prompt containing the context file path.

- [ ] **Step 4: Commit agent-send**

Run:

```bash
cd "$HOME/.local/share/chezmoi"
git add home/dot_local/bin/executable_ws
git commit -m "feat: add ws agent-send bridge"
```

Expected: chezmoi records the shared context-to-agent bridge.

### Task 13: Update Documentation

**Files:**
- Modify: `README.md`
- Modify: `docs/KEYMAPS.md`
- Modify: `docs/WORKFLOWS.md`

- [ ] **Step 1: Update README tool model**

In `README.md`, update the workflow section so it states:

```markdown
Neovim is the review and manual-edit surface. Codex/OpenCode run as terminal agents inside tmux. `ws` owns workspace entry, tmux session creation, and context delivery. Lazygit owns repo-level Git operations, while Diffview and gitsigns handle serious review and conflicts.
```

Expected: README no longer presents Neogit as the default Git cockpit.

- [ ] **Step 2: Update keymap docs**

In `docs/KEYMAPS.md`, replace Neogit/CodeDiff rows with:

```markdown
| `<leader>gg` | Open Diffview | normal | diffview |
| `<leader>gq` | Close Diffview | normal | diffview |
| `<leader>gr` | Send Git review context to agent | normal | ws |
| `<leader>as` | Send selection to agent | visual | ws |
| `<leader>ax` | Send diagnostics to agent | normal | ws |
| `<leader>aq` | Send quickfix to agent | normal | ws |
```

Expected: docs match new bridge keymaps.

- [ ] **Step 3: Update workflow docs**

In `docs/WORKFLOWS.md`, add this Git finishing flow:

```markdown
### AI-assisted Git finishing

1. Review agent changes in Neovim.
2. Open lazygit in the `git` tmux window.
3. Press the AI Git action key and choose `Plan commits`.
4. Review the plan in `agent-git`.
5. Stage the first logical group manually in lazygit.
6. Run `AI message staged`.
7. Run `Commit staged diff with AI message` and confirm.
8. Repeat until the working tree is clean.
```

Expected: docs show the human-confirmed AI Git lane.

- [ ] **Step 4: Verify docs**

Run:

```bash
rg -n "Neogit|CodeDiff" README.md docs/KEYMAPS.md docs/WORKFLOWS.md
```

Expected: no stale references remain, except in historical sections explicitly marked as legacy.

- [ ] **Step 5: Commit docs**

Run:

```bash
git -C /home/chenchi/.config/nvim add README.md docs/KEYMAPS.md docs/WORKFLOWS.md
git -C /home/chenchi/.config/nvim commit -m "docs: document CLI AI workbench workflow"
```

Expected: commit includes only workflow documentation changes. Stage hunks carefully if files contain unrelated user edits.

## Final Verification

### Task 14: End-to-End Smoke Test

**Files:**
- No planned file changes.

- [ ] **Step 1: Verify command availability**

Run:

```bash
for c in chezmoi tmux fzf gum lazygit git nvim rg fd bat eza zoxide codex opencode ws; do
  command -v "$c" >/dev/null || { echo "missing $c"; exit 1; }
done
```

Expected: exits with status 0.

- [ ] **Step 2: Verify chezmoi consistency**

Run:

```bash
chezmoi diff
```

Expected: no unexpected drift. Machine-local `~/.config/ws/local.toml` is not managed.

- [ ] **Step 3: Verify `ws` session creation**

Run:

```bash
ws /home/chenchi/.config/nvim
```

Expected: tmux opens or switches to `nvim-config` with windows `code`, `agent`, `git`, and `run`.

- [ ] **Step 4: Verify lazygit AI action menu**

Inside the `git` window:

```bash
lazygit
```

Press the configured AI Git key.

Expected: menu offers plan, review, message, and commit-ai. Exit without committing unless staged changes are intentional.

- [ ] **Step 5: Verify Neovim bridge**

Inside the `code` window:

```bash
nvim .
```

Run:

```vim
:lua require("cccvno1.integrations.ws").diagnostics()
```

Expected: if diagnostics exist, a context file is written and sent to the agent window; if none exist, Neovim shows "No diagnostics in current buffer".

- [ ] **Step 6: Verify no unintended project mutations**

Run:

```bash
git -C /home/chenchi/.config/nvim status --short
git -C "$HOME/.local/share/chezmoi" status --short
```

Expected: only intentional commits or uncommitted plan-related files appear. No project files are deleted by `ws`.

## Execution Notes

Use separate commits for chezmoi and Neovim repositories. Do not combine dotfiles source commits with Neovim config commits.

Recommended commit order:

```text
chezmoi: initialize portable dotfiles source
chezmoi: manage Ghostty config
chezmoi: add tmux workbench base
chezmoi: add ws config and prompts
chezmoi: add ws workspace picker
chezmoi: add ws maintenance and agent bridge
chezmoi: add AI Git finishing lane
chezmoi: configure lazygit workbench integration
nvim: add ws context bridge
nvim: document CLI AI workbench workflow
```

Stop and ask before any command that would delete a branch, remove a worktree, overwrite an existing config directory, or modify secrets.
