# Keymaps

Leader is `<Space>`. Local leader is `<Space>`.

This page is organized like a small distribution cheat sheet: start with the
leader groups, then use the later sections when you need native Vim habits,
LSP-only mappings, or plugin-window defaults.

Inspired by LazyVim's which-key style grouping and AstroNvim's action-first
mapping tables.

Press `<leader>` and pause to open which-key for the current prefix. Press
`<leader>?` to inspect buffer-local mappings.

## At A Glance

| Prefix | Group | Use For |
| --- | --- | --- |
| `<leader>?` | Help | Buffer-local keymaps |
| `<leader>f` | Find | Files, grep, buffers |
| `<leader>b` | Buffers | Close, isolate, pin |
| `<leader>c` | Code | Format, actions, outline |
| `<leader>g` | Git | Diff review and agent handoff |
| `<leader>h` | Hunks | Git hunk actions |
| `<leader>x` | Diagnostics | Trouble lists |
| `<leader>a` | AI | Sidekick prompts and `ws` agent handoff |
| `<leader>d` | Debug | DAP breakpoints and UI |
| `<leader>t` | Tests | Neotest |
| `<leader>w` | Work | Write file and Overseer tasks |
| `<leader>q` | Quit | Quit current window |
| `<leader>u` | UI | Local display toggles |
| `<leader>m` | Markdown | Browser preview |

## Leader Keymaps

### Find

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>ff` | Find files | normal | fzf-lua |
| `<leader>fg` | Live grep | normal | fzf-lua |
| `<leader>fb` | Find buffers | normal | fzf-lua + local wrapper |
| `<leader>fe` | File explorer | normal | Oil |
| `<leader>sr` | Search and replace | normal | GrugFar |

### Buffers

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>bd` | Close current buffer | normal | barbar wrapper |
| `<leader>bo` | Close other buffers | normal | barbar wrapper |
| `<leader>bp` | Pin buffer | normal | barbar wrapper |

Useful built-ins nearby:

| Key | Action | Mode |
| --- | --- | --- |
| `[b` | Previous buffer | normal |
| `]b` | Next buffer | normal |
| `[B` | First buffer | normal |
| `]B` | Last buffer | normal |

### Code

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>cf` | Format buffer | normal | conform.nvim |
| `<leader>co` | Toggle outline | normal | Aerial |
| `<leader>ca` | Code action | normal | LSP, after attach |
| `<leader>cr` | Rename symbol | normal | LSP, after attach |

### Git

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>gg` | Open Diffview | normal | diffview |
| `<leader>gq` | Close Diffview | normal | diffview |
| `<leader>gr` | Send Git review context to agent | normal | ws |
| `]h` | Next git hunk | normal | gitsigns |
| `[h` | Previous git hunk | normal | gitsigns |
| `<leader>hp` | Preview hunk | normal | gitsigns |
| `<leader>hr` | Reset hunk | normal | gitsigns |

### Diagnostics

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>xx` | Toggle diagnostics list | normal | Trouble |
| `<leader>xq` | Toggle quickfix list | normal | Trouble |
| `[d` | Previous diagnostic | normal | Neovim default |
| `]d` | Next diagnostic | normal | Neovim default |
| `[D` | First diagnostic | normal | Neovim default |
| `]D` | Last diagnostic | normal | Neovim default |
| `<C-W>d` | Show diagnostic under cursor | normal | Neovim default |

### AI

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>ar` | Send `review_pack` | normal | Sidekick |
| `<leader>ad` | Send `debug_pack` | normal | Sidekick |
| `<leader>aa` | Send selected text | visual | Sidekick |
| `<leader>as` | Send selection to agent | visual | ws |
| `<leader>ax` | Send diagnostics to agent | normal | ws |
| `<leader>aq` | Send quickfix to agent | normal | ws |

`review_pack` includes changed files, git diff, diagnostics, quickfix, and the
current file outline. `debug_pack` includes diagnostics, quickfix, DAP state,
recent task output, and recent test output.

### Debug

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<F5>` | Continue/start debugger | normal | nvim-dap |
| `<F10>` | Step over | normal | nvim-dap |
| `<F11>` | Step into | normal | nvim-dap |
| `<F12>` | Step out | normal | nvim-dap |
| `<leader>db` | Toggle persistent breakpoint | normal | persistent-breakpoints |
| `<leader>du` | Toggle DAP UI | normal | dap-ui |

### Tests And Tasks

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>tt` | Run nearest test | normal | neotest |
| `<leader>tf` | Run file tests | normal | neotest |
| `<leader>ts` | Toggle test summary | normal | neotest |
| `<leader>ww` | Write file | normal | Neovim |
| `<leader>wr` | Run task | normal | Overseer |
| `<leader>wt` | Toggle task list | normal | Overseer |

### Quit

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>qq` | Quit current window | normal | Neovim |

### UI

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>uf` | Toggle autoformat | normal | Buffer variable |
| `<leader>ud` | Toggle diagnostics | normal | Neovim diagnostics |
| `<leader>ul` | Toggle list chars | normal | Neovim local option |
| `<leader>ur` | Toggle relative number | normal | Neovim local option |
| `<leader>uw` | Toggle wrap | normal | Neovim local option |

### Navigation

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `s` | Flash jump | normal, visual, operator | flash.nvim |

Note: `s` intentionally replaces Vim's native substitute-character command in
normal/visual/operator contexts. Use `cl` or `xi` if you need the original
single-character substitute habit.

### Markdown

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<leader>mp` | Toggle browser preview | normal | live-preview.nvim |

## LSP Keymaps

These appear only after an LSP server attaches to the current buffer.

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `gd` | Go to definition | normal | local LSP attach |
| `gr` | References | normal | local LSP attach |
| `K` | Hover | normal | local LSP attach |
| `<leader>ca` | Code action | normal | local LSP attach |
| `<leader>cr` | Rename | normal | local LSP attach |
| `<leader>rn` | Rename | normal | local LSP attach |

Modern Neovim also provides these LSP defaults:

| Key | Action | Mode |
| --- | --- | --- |
| `grn` | Rename | normal |
| `gra` | Code action | normal, visual |
| `grr` | References | normal |
| `gri` | Implementation | normal |
| `grt` | Type definition | normal |
| `gO` | Document symbols | normal |

## Core Editing

These are Vim/Neovim defaults worth keeping in muscle memory. They are not
custom mappings unless noted.

### Movement

| Key | Action | Mode |
| --- | --- | --- |
| `h` `j` `k` `l` | Left/down/up/right | normal, visual, operator |
| `w` / `b` / `e` | Next/start previous/end of word | normal, visual, operator |
| `0` / `^` / `$` | Start/first non-blank/end of line | normal, visual, operator |
| `gg` / `G` | First/last line | normal, visual, operator |
| `{` / `}` | Previous/next paragraph or block | normal, visual, operator |
| `%` | Matching pair or language item | normal, visual, operator |
| `<C-O>` / `<C-I>` | Jump backward/forward | normal |

### Operators

| Key | Action | Mode |
| --- | --- | --- |
| `d{motion}` / `dd` | Delete by motion / line | normal |
| `c{motion}` / `cc` | Change by motion / line | normal |
| `y{motion}` / `yy` | Yank by motion / line | normal |
| `p` / `P` | Paste after / before cursor | normal |
| `u` / `<C-R>` | Undo / redo | normal |
| `.` | Repeat last change | normal |

### Text Objects

| Key | Action | Mode |
| --- | --- | --- |
| `iw` / `aw` | Inner / around word | visual, operator |
| `i"` / `a"` | Inside / around double quotes | visual, operator |
| `i'` / `a'` | Inside / around single quotes | visual, operator |
| `` i` `` / `` a` `` | Inside / around backticks | visual, operator |
| `i(` / `a(` | Inside / around parentheses | visual, operator |
| `i[` / `a[` | Inside / around brackets | visual, operator |
| `i{` / `a{` | Inside / around braces | visual, operator |
| `ip` / `ap` | Inner / around paragraph | visual, operator |

Examples:

```text
ci"   change inside quotes
da(   delete around parentheses
vi{   visually select inside braces
yap   yank a paragraph
```

### Search And Lists

| Key | Action | Mode |
| --- | --- | --- |
| `<Esc>` | Clear search highlight | normal |
| `/` / `?` | Search forward / backward | normal |
| `n` / `N` | Next / previous search match | normal |
| `*` / `#` | Search word under cursor forward / backward | normal |
| `[q` / `]q` | Previous / next quickfix item | normal |
| `[l` / `]l` | Previous / next location item | normal |

## Insert And Completion

| Key | Action | Mode | Source |
| --- | --- | --- | --- |
| `<C-Space>` | Show completion | insert | blink.cmp default preset |
| `<C-E>` | Hide completion | insert | blink.cmp default preset |
| `<CR>` | Accept selected completion when menu is active | insert | blink.cmp default preset |
| `<Tab>` | Select, accept, or jump by state | insert, select | blink.cmp / Neovim |
| `<S-Tab>` | Previous item or snippet jump by state | insert, select | blink.cmp / Neovim |

If completion behavior changes after an update:

```vim
:h blink-cmp-config-keymap
```

## Plugin Windows

Use `?` or `g?` inside many plugin windows for local help.

### lazy.nvim

Open with `:Lazy`.

| Key | Action |
| --- | --- |
| `?` | Help |
| `q` | Close |
| `u` | Update plugins |
| `s` | Sync plugins |
| `x` | Clean unused plugins |
| `c` | Check for updates |
| `l` | Open log |

### Mason

Open with `:Mason`.

| Key | Action |
| --- | --- |
| `?` | Help |
| `q` | Close |
| `i` | Install package |
| `u` | Update package |
| `U` | Update all packages |
| `X` | Uninstall package |
| `/` | Filter/search |

### fzf-lua

Opened by `<leader>ff`, `<leader>fg`, and `<leader>fb`.

| Key | Action | Mode |
| --- | --- | --- |
| `<C-J>` / `<C-K>` | Move selection down / up | insert |
| `<CR>` | Open selected item | insert |
| `<C-X>` | Open in horizontal split | insert |
| `<C-V>` | Open in vertical split | insert |
| `<C-T>` | Open in tab | insert |
| `<Esc>` | Close picker | insert |

### Oil

Open with `<leader>fe`.

| Key | Action |
| --- | --- |
| `<CR>` | Open file or directory |
| `-` | Go to parent directory |
| `_` | Open current working directory |
| `g?` | Help |
| `q` | Close |

### Diffview

Open with `<leader>gg`; close with `<leader>gq`.

| Key | Action |
| --- | --- |
| `g?` | Help |
| `<CR>` | Open focused file |
| `q` | Close focused panel |
| `]c` / `[c` | Next / previous conflict |
| `<leader>co` | Choose ours in merge view |
| `<leader>ct` | Choose theirs in merge view |

### Trouble

Open with `<leader>xx` or `<leader>xq`.

| Key | Action |
| --- | --- |
| `<CR>` / `o` | Open item |
| `q` | Close |
| `r` | Refresh |
| `?` | Help |

### Aerial

Open with `<leader>co`.

| Key | Action |
| --- | --- |
| `<CR>` / `o` | Jump to symbol |
| `q` | Close |
| `{` / `}` | Previous / next symbol |
| `?` | Help |

### DAP UI

Open with `<leader>du` after DAP loads.

| Key | Action |
| --- | --- |
| `<CR>` | Expand/collapse item or jump |
| `o` | Open/expand item |
| `q` | Close focused DAP UI window |

### Neotest

Open the summary with `<leader>ts`.

| Key | Action |
| --- | --- |
| `<CR>` | Jump/run focused test depending on node |
| `o` | Expand/collapse node |
| `q` | Close summary |

### Overseer

Open the task list with `<leader>wt`.

| Key | Action |
| --- | --- |
| `<CR>` | Open task action/details |
| `q` | Close |
| `?` | Help |

### Sidekick

Use `<leader>ar`, `<leader>ad`, and visual `<leader>aa` for configured prompts.

| Key | Action | Mode |
| --- | --- | --- |
| `<C-B>` | Insert/open buffers context picker | normal, terminal |
| `<C-F>` | Insert/open files context picker | normal, terminal |
| `<C-P>` | Insert prompt/context | terminal |
| `<C-Q>` | Enter terminal normal mode | terminal |
| `<C-.>` | Hide terminal window | normal, terminal |
| `<C-Z>` | Blur terminal and return to previous window | normal, terminal |
| `q` | Hide terminal window | normal |
| `<CR>` | Send Enter to terminal | normal |
| `<C-H/J/K/L>` | Navigate Neovim windows when possible | terminal |

## Commands

These are intentionally command-driven.

| Command | Purpose |
| --- | --- |
| `:Lazy` | Plugin manager |
| `:Mason` | External Neovim tools |
| `:checkhealth cccvno1` | Local config health |
| `:Copilot auth` | Authenticate Copilot |
| `:TSManager` | Tree-sitter manager |
| `:GrugFar` | Search and replace |
| `:OverseerRun` | Run task |
| `:OverseerToggle` | Toggle task list |
| `:DapContinue` | Start/continue debug session |
| `:LivePreviewToggle` | Toggle browser preview |

## Discover More

Use these when a mapping is unclear:

```vim
:map <leader>
:verbose nmap <leader>ff
:verbose nmap gd
:verbose imap <Tab>
:help index
:help default-mappings
:help lsp-defaults
```

From the shell:

```sh
nvim --headless '+redir => g:maps | silent map | redir END | lua print(vim.g.maps)' +qa
```
