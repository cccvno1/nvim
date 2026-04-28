# Workflows

This file is the practical operating manual for the config. It focuses on what to do during AI-heavy development, not on every plugin option.

## First Run

```sh
./scripts/install-deps.sh
nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonToolsInstall" +qa
nvim --headless "+checkhealth ad" +qa
```

Then open Neovim and authenticate tools as needed:

```vim
:Copilot auth
:checkhealth ad
```

For OpenCode and Codex, authenticate in the terminal according to their own CLI flow.

## AI Review Loop

Use this after an external AI agent edits code.

1. Open changed files with `<leader>fg`, `<leader>ff`, or `<leader>fb`.
2. Inspect git state with `<leader>gg`, `]h`, `[h`, and `<leader>hp`.
3. Open a code diff with `<leader>gd` when you want review-focused diff navigation.
4. Check diagnostics with `<leader>xx`.
5. Check structure with `<leader>o`.
6. Send review context with `<leader>ar`.

The review context includes changed files, git diff, diagnostics, quickfix, and outline. It is meant for prompts such as:

```text
Review the current AI-generated changes for bugs, syntax errors, unnecessary edits, missing tests, and risky behavior.
```

## AI Debug Loop

Use this when tests, tasks, or debug sessions fail.

1. Run tests with `<leader>tt` or `<leader>tf`.
2. Open the test summary with `<leader>ts`.
3. Run project tasks with `<leader>wr`.
4. Open task output with `<leader>wt`.
5. Debug with `<F5>`, `<F10>`, `<F11>`, `<F12>`, `<leader>db`, and `<leader>du`.
6. Send debug context with `<leader>ad`.

The debug context includes diagnostics, quickfix, DAP state, recent test output, and recent Overseer task output.

## Selection Q&A

For small questions about code:

1. Select a region in visual mode.
2. Press `<leader>aa`.
3. Ask the agent to explain, rewrite, review, or generate a focused patch.

For broader questions, prefer `review_pack` or `debug_pack` over sending huge buffers manually.

## Git Review

Use Git in three layers:

- Fast hunk navigation: `]h`, `[h`, `<leader>hp`, `<leader>hr`.
- Status, staging, commit, branch operations: `<leader>gg`.
- Focused code diff review: `<leader>gd`.

The intended practice is to review AI-generated changes before committing:

```sh
git status --short
git diff --stat
```

Then use Neovim hunk and diff tools to inspect content.

## Search And Replace

- `<leader>fg`: live grep.
- `<leader>sr`: project search and replace.
- `<leader>ff`: find files.
- `<leader>fb`: find buffers.

For AI-generated code, prefer searching before accepting broad refactors. It catches duplicated names, stale call sites, and generated dead code quickly.

## Outline And Navigation

- `s`: Flash jump.
- `gd`: goto definition after LSP attaches.
- `gr`: references after LSP attaches.
- `K`: hover after LSP attaches.
- `<leader>o`: outline.

Outline is useful for reviewing generated files because it gives a fast shape check: exported API, method order, duplicated functions, and suspiciously large functions.

## Markdown And Generated Docs

- Markdown buffers render inline through `render-markdown.nvim`.
- `<leader>mp` toggles browser preview through `live-preview.nvim`.

Use browser preview for generated Markdown, HTML, SVG, and Mermaid-like docs where visual structure matters.

## Big Files

Bigfile mode is automatic. It triggers when a buffer exceeds one of these thresholds:

- size greater than `1.5MB`
- line count greater than `100000`
- average line length greater than `1000`

When enabled, it sets `vim.b.bigfile = true`, disables or downgrades expensive features, and prevents heavy AI/test helpers from attaching.

You can check the active buffer:

```vim
:lua print(vim.b.bigfile and "bigfile" or "normal")
```

## Health And Maintenance

Run after plugin updates or script changes:

```sh
nvim --headless "+Lazy! sync" +qa
nvim --headless "+MasonToolsInstall" +qa
nvim --headless "+checkhealth ad" +qa
find lua -name '*.lua' -print0 | xargs -0 luac -p
```

Run inside Neovim when something feels off:

```vim
:checkhealth ad
:Lazy
:Mason
```

## External Agent Pattern

Use Neovim and the terminal together:

- Neovim: inspect state, review code, collect context.
- Codex/OpenCode: generate changes, explain code, run larger edits.
- Git: keep every meaningful checkpoint recoverable.

Avoid sending the whole repository by default. Send the smallest context that explains the current decision: selection, file, outline, diff, diagnostics, review pack, or debug pack.
