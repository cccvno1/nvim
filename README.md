# AD Neovim

AI-first Neovim workbench for reviewing generated code, inspecting diffs, debugging failures, and sending useful context to external agents.

This config is intentionally inspectable. It is not a distribution layer and does not use a large utility bundle. Core policy lives in `lua/ad/core`, AI context glue lives in `lua/ad/ai`, and plugin specs live in `lua/ad/plugins`.

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
:checkhealth ad
```

If Copilot is not authenticated yet:

```vim
:Copilot auth
```

## Mental Model

Neovim is the state organizer. It owns buffers, diagnostics, quickfix, git diff, outline, tests, tasks, and debug state. Large agents such as Codex and OpenCode remain external tools. Sidekick is the bridge inside Neovim for sending compact context to those tools.

Common loop:

1. Let an AI tool generate or change code.
2. Review changed files and hunks in Neovim.
3. Check diagnostics, outline, tests, and debug/task output.
4. Send `review_pack` or `debug_pack` to the AI agent.
5. Apply fixes, rerun checks, commit.

## Important Entrypoints

- `:checkhealth ad`: local health checks for system tools, Mason packages, Copilot, Sidekick, and DAP.
- `<leader>ar`: send AI review context.
- `<leader>ad`: send AI debug context.
- visual `<leader>aa`: send selected text to Sidekick.
- `<leader>gg`: open Neogit.
- `<leader>gd`: open codediff.nvim.
- `<leader>xx`: diagnostics list.
- `<leader>o`: outline.
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

The install script supports `pacman`, `apt`, `dnf`, and `brew`. It also installs Codex with `npm install -g @openai/codex`, which is the official OpenAI documented command, and OpenCode with `npm install -g opencode-ai`, which is one of the official OpenCode install methods.

References:

- OpenAI Codex CLI: <https://help.openai.com/en/articles/11096431-openai-codex-ci-getting-started>
- OpenCode install docs: <https://opencode.ai/docs/>

## Repository Layout

```text
init.lua
lua/ad/
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
nvim --headless "+lua require('ad.core.bigfile'); require('ad.core.health'); require('ad.ai.contexts.review').render(); print('modules ok')" +qa
nvim --headless "+checkhealth ad" +qa
```

Bigfile check:

```sh
perl -e 'print "x" x (2 * 1024 * 1024)' > /tmp/ad-bigfile.txt
nvim --headless /tmp/ad-bigfile.txt "+lua assert(vim.b.bigfile == true, 'bigfile not detected'); print('bigfile ok')" +qa
rm -f /tmp/ad-bigfile.txt
```

## Notes

- `.superpowers/` is local brainstorming/session material and is intentionally not part of this config.
- `lazy-lock.json` is committed so plugin versions are reproducible.
- Big files disable expensive editor features per buffer, including completion-heavy AI behavior and test entrypoints.
