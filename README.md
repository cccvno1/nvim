# CCCVNO1 Neovim

CLI-first AI workbench for reviewing generated code, inspecting diffs, debugging failures, and sending useful context to terminal agents.

This config is intentionally inspectable. It is not a distribution layer and does not use a large utility bundle. Core policy lives in `lua/cccvno1/core`, terminal-agent context glue lives in `lua/cccvno1/integrations`, and plugin specs live in `lua/cccvno1/plugins`.

## Quick Start

Install external tools:

```sh
./scripts/install-deps.sh
```

Sync plugins and Mason tools:

```sh
nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonToolsInstall" +qa
```

Open Neovim:

```sh
nvim
```

Run the local health check:

```vim
:checkhealth cccvno1
```

If Copilot is not authenticated yet:

```vim
:Copilot auth
```

## Mental Model

Neovim is the review and manual-edit surface. Codex/OpenCode run as terminal agents inside tmux. `ws` owns workspace entry, tmux session creation, and context delivery. Lazygit owns repo-level Git operations, while Diffview and gitsigns handle serious review and conflicts.

Common loop:

1. Let an AI tool generate or change code.
2. Review changed files and hunks in Neovim.
3. Check diagnostics, outline, tests, and debug/task output.
4. Send selection, diagnostics, quickfix, or Git review context to the terminal agent.
5. Apply fixes, rerun checks, commit.

## Important Entrypoints

- `:checkhealth cccvno1`: local health checks for system tools, Mason packages, Copilot, Sidekick, and DAP.
- `<leader>`: pause after the leader key to open which-key.
- `<leader>?`: show buffer-local keymaps in which-key.
- `<leader>ar`: send Sidekick review context.
- `<leader>ad`: send Sidekick debug context.
- visual `<leader>aa`: send selected text to Sidekick.
- visual `<leader>as`: send selected text to the terminal agent via `ws`.
- `<leader>ax`: send diagnostics to the terminal agent via `ws`.
- `<leader>aq`: send quickfix to the terminal agent via `ws`.
- `<leader>fe`: open Oil file explorer.
- `<leader>cf`: format current buffer.
- `<leader>uf`: toggle format-on-save for the current buffer.
- `<leader>gg`: open Diffview.
- `<leader>gq`: close Diffview.
- `<leader>gr`: send Git review context to the terminal agent via `ws`.
- `<leader>xx`: diagnostics list.
- `<leader>co`: outline.
- `<leader>mp`: Markdown/browser preview.

See [docs/WORKFLOWS.md](docs/WORKFLOWS.md) for task-oriented usage and [docs/KEYMAPS.md](docs/KEYMAPS.md) for the keymap index.

## External Dependencies

Baseline command-line tools:

- `git`
- `rg`
- `fd`
- `fzf`
- `node`
- `npm`
- `unzip`
- `tree-sitter`
- `stylua`
- `shellcheck`
- `shfmt`
- `clang-format`

AI CLIs:

- `codex`
- `opencode`

CLI workbench tools:

- `tmux`
- `lazygit`
- `gum`
- `ws`

The install script supports `pacman`, `apt`, `dnf`, and `brew`. It also installs Codex with `npm install -g @openai/codex`, which is the official OpenAI documented command, and OpenCode with `npm install -g opencode-ai`, which is one of the official OpenCode install methods.

References:

- OpenAI Codex CLI: <https://help.openai.com/en/articles/11096431-openai-codex-ci-getting-started>
- OpenCode install docs: <https://opencode.ai/docs/>

## Repository Layout

```text
init.lua
lua/cccvno1/
  bootstrap.lua
  options.lua
  autocmds.lua
  keymaps.lua
  core/
  ai/
  plugins/
docs/
scripts/
```

## Verification

Useful checks after changing config:

```sh
find lua -name '*.lua' -print0 | xargs -0 luac -p
nvim --headless "+lua print('startup ok')" +qa
nvim --headless "+lua require('cccvno1.core.bigfile'); require('cccvno1.core.health'); require('cccvno1.ai.contexts.review').render(); print('modules ok')" +qa
nvim --headless "+checkhealth cccvno1" +qa
```

Bigfile check:

```sh
perl -e 'print "x" x (2 * 1024 * 1024)' > /tmp/cccvno1-bigfile.txt
nvim --headless /tmp/cccvno1-bigfile.txt "+lua assert(vim.b.bigfile == true, 'bigfile not detected'); print('bigfile ok')" +qa
rm -f /tmp/cccvno1-bigfile.txt
```

## Notes

- `.superpowers/` is local brainstorming/session material and is intentionally not part of this config.
- `lazy-lock.json` is committed so plugin versions are reproducible.
- Big files disable expensive editor features per buffer, including completion-heavy AI behavior and test entrypoints.
