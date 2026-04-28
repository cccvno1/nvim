# Keymaps

Leader is `<Space>`.

This document is split into three layers:

- AD custom mappings: defined by this config.
- Neovim default mappings: built into Neovim/Vim and worth using directly.
- Plugin-local mappings: active inside a plugin UI after opening that plugin.

For the exact live state in your current session:

```vim
:map
:nmap
:verbose map <key>
```
The most useful portable built-in command is:

```vim
:map
```

## AD Custom Mappings

These are the mappings intentionally added by this config.

### Core

| Key | Mode | Action |
| --- | --- | --- |
| `<Esc>` | normal | Clear search highlight |
| `<Space>` | normal, visual | Disabled as a standalone key |
| `[q` | normal | Previous quickfix item |
| `]q` | normal | Next quickfix item |
| `[l` | normal | Previous location item |
| `]l` | normal | Next location item |

### Files, Buffers, Search

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ff` | normal | Find files |
| `<leader>fg` | normal | Live grep |
| `<leader>fb` | normal | Find buffers |
| `<leader>e` | normal | Open Oil file manager |
| `<leader>sr` | normal | Search and replace |
| `<leader>bd` | normal | Close current buffer |
| `<leader>bo` | normal | Close other buffers |
| `<leader>bp` | normal | Pin buffer |

### Navigation

| Key | Mode | Action |
| --- | --- | --- |
| `s` | normal, visual, operator | Flash jump |
| `<leader>o` | normal | Toggle outline |
| `gd` | normal | Goto definition, after LSP attaches |
| `gr` | normal | References, after LSP attaches |
| `K` | normal | Hover, after LSP attaches |
| `<leader>ca` | normal | Code action, after LSP attaches |
| `<leader>rn` | normal | Rename, after LSP attaches |

### Git And Review

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>gg` | normal | Open Neogit |
| `<leader>gd` | normal | Open codediff.nvim |
| `]h` | normal | Next git hunk |
| `[h` | normal | Previous git hunk |
| `<leader>hp` | normal | Preview hunk |
| `<leader>hr` | normal | Reset hunk |

### Diagnostics And Lists

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>xx` | normal | Toggle diagnostics in Trouble |
| `<leader>xq` | normal | Toggle quickfix in Trouble |

### AI

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ar` | normal | Send AI review pack |
| `<leader>ad` | normal | Send AI debug pack |
| `<leader>aa` | visual | Send selected text |

### Debug

| Key | Mode | Action |
| --- | --- | --- |
| `<F5>` | normal | DAP continue |
| `<F10>` | normal | DAP step over |
| `<F11>` | normal | DAP step into |
| `<F12>` | normal | DAP step out |
| `<leader>db` | normal | Toggle persistent breakpoint |
| `<leader>du` | normal | Toggle DAP UI |

### Tests And Tasks

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>tt` | normal | Run nearest test |
| `<leader>tf` | normal | Run file tests |
| `<leader>ts` | normal | Toggle test summary |
| `<leader>wr` | normal | Run task |
| `<leader>wt` | normal | Toggle tasks |

### Markdown

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>mp` | normal | Toggle Markdown/browser preview |

## Neovim Defaults Added By Modern Neovim

These appear in `:map` even without this config because Neovim ships them as defaults.

### Diagnostics

| Key | Mode | Action |
| --- | --- | --- |
| `[d` | normal | Previous diagnostic |
| `]d` | normal | Next diagnostic |
| `[D` | normal | First diagnostic in current buffer |
| `]D` | normal | Last diagnostic in current buffer |
| `<C-W>d` | normal | Show diagnostic under cursor |
| `<C-W><C-D>` | normal | Same as `<C-W>d` |

### LSP Defaults

These are Neovim defaults. This config also adds `gd`, `gr`, `K`, `<leader>ca`, and `<leader>rn` on LSP attach for familiar VSCode-like usage.

| Key | Mode | Action |
| --- | --- | --- |
| `grn` | normal | Rename |
| `gra` | normal, visual | Code action |
| `grr` | normal | References |
| `gri` | normal | Implementation |
| `grt` | normal | Type definition |
| `grx` | normal | Run code lens |
| `gO` | normal | Document symbols |
| `<C-S>` | select | Signature help |

### Comments

| Key | Mode | Action |
| --- | --- | --- |
| `gcc` | normal | Toggle current line comment |
| `gc` | normal, visual, operator | Toggle comment |
| `gc` | operator | Comment text object/operator |

### Tree-sitter Selection

| Key | Mode | Action |
| --- | --- | --- |
| `an` | visual, operator | Select parent/outer node |
| `in` | visual, operator | Select child/inner node |
| `[n` | visual | Select previous node |
| `]n` | visual | Select next node |

### Buffer, Quickfix, Location, Args, Tags

| Key | Mode | Action |
| --- | --- | --- |
| `[b` | normal | Previous buffer |
| `]b` | normal | Next buffer |
| `[B` | normal | First buffer |
| `]B` | normal | Last buffer |
| `[q` | normal | Previous quickfix item, overridden by this config |
| `]q` | normal | Next quickfix item, overridden by this config |
| `[Q` | normal | First quickfix item |
| `]Q` | normal | Last quickfix item |
| `[<C-Q>` | normal | Previous quickfix file |
| `]<C-Q>` | normal | Next quickfix file |
| `[l` | normal | Previous location item, overridden by this config |
| `]l` | normal | Next location item, overridden by this config |
| `[L` | normal | First location item |
| `]L` | normal | Last location item |
| `[<C-L>` | normal | Previous location file |
| `]<C-L>` | normal | Next location file |
| `[a` | normal | Previous arglist item |
| `]a` | normal | Next arglist item |
| `[A` | normal | First arglist item |
| `]A` | normal | Last arglist item |
| `[t` | normal | Previous tag |
| `]t` | normal | Next tag |
| `[T` | normal | First tag |
| `]T` | normal | Last tag |
| `[<C-T>` | normal | Previous preview tag |
| `]<C-T>` | normal | Next preview tag |

### Small Editing Defaults

| Key | Mode | Action |
| --- | --- | --- |
| `[<Space>` | normal | Add empty line above cursor |
| `]<Space>` | normal | Add empty line below cursor |
| `Y` | normal | Yank to end of line |
| `&` | normal | Repeat last substitute with flags |
| `gx` | normal, visual | Open filepath or URL under cursor |
| `<C-L>` | normal | Clear search highlight, diff update, redraw |
| `<Tab>` | select | Jump to next snippet placeholder if active |
| `<S-Tab>` | select | Jump to previous snippet placeholder if active |

## Vim Defaults Worth Learning

This is the core language of Neovim. These are not custom mappings.

### Mode Switching

| Key | Mode | Action |
| --- | --- | --- |
| `i` | normal | Insert before cursor |
| `I` | normal | Insert at first non-blank character |
| `a` | normal | Insert after cursor |
| `A` | normal | Insert at end of line |
| `o` | normal | Open line below |
| `O` | normal | Open line above |
| `v` | normal | Visual character mode |
| `V` | normal | Visual line mode |
| `<C-V>` | normal | Visual block mode |
| `<Esc>` | insert, visual | Return to normal mode |

### Movement

| Key | Mode | Action |
| --- | --- | --- |
| `h` `j` `k` `l` | normal, visual, operator | Left, down, up, right |
| `w` | normal, visual, operator | Next word |
| `W` | normal, visual, operator | Next WORD |
| `b` | normal, visual, operator | Previous word |
| `B` | normal, visual, operator | Previous WORD |
| `e` | normal, visual, operator | End of word |
| `E` | normal, visual, operator | End of WORD |
| `0` | normal, visual, operator | Start of line |
| `^` | normal, visual, operator | First non-blank character |
| `$` | normal, visual, operator | End of line |
| `gg` | normal, visual, operator | First line |
| `G` | normal, visual, operator | Last line |
| `{` | normal, visual, operator | Previous paragraph/block |
| `}` | normal, visual, operator | Next paragraph/block |
| `%` | normal, visual, operator | Matching bracket, paren, brace, or language item |
| `f<char>` | normal, visual, operator | Find char forward on line |
| `F<char>` | normal, visual, operator | Find char backward on line |
| `t<char>` | normal, visual, operator | Till char forward on line |
| `T<char>` | normal, visual, operator | Till char backward on line |
| `;` | normal, visual, operator | Repeat last `f/F/t/T` |
| `,` | normal, visual, operator | Repeat last `f/F/t/T` backward |

### Editing Operators

| Key | Mode | Action |
| --- | --- | --- |
| `d{motion}` | normal | Delete by motion |
| `dd` | normal | Delete line |
| `c{motion}` | normal | Change by motion |
| `cc` | normal | Change line |
| `y{motion}` | normal | Yank by motion |
| `yy` | normal | Yank line |
| `p` | normal | Paste after cursor |
| `P` | normal | Paste before cursor |
| `x` | normal | Delete character |
| `r<char>` | normal | Replace one character |
| `u` | normal | Undo |
| `<C-R>` | normal | Redo |
| `.` | normal | Repeat last change |

### Text Objects

| Key | Mode | Action |
| --- | --- | --- |
| `iw` | operator, visual | Inner word |
| `aw` | operator, visual | Around word |
| `i"` `a"` | operator, visual | Inside/around double quotes |
| `i'` `a'` | operator, visual | Inside/around single quotes |
| `` i` `` `` a` `` | operator, visual | Inside/around backticks |
| `i(` `a(` | operator, visual | Inside/around parentheses |
| `i[` `a[` | operator, visual | Inside/around brackets |
| `i{` `a{` | operator, visual | Inside/around braces |
| `ip` `ap` | operator, visual | Inner/around paragraph |

Examples:

```text
ci"   change inside quotes
da(   delete around parentheses
vi{   visually select inside braces
yap   yank a paragraph
```

### Search

| Key | Mode | Action |
| --- | --- | --- |
| `/` | normal | Search forward |
| `?` | normal | Search backward |
| `n` | normal | Next search match |
| `N` | normal | Previous search match |
| `*` | normal | Search word under cursor forward |
| `#` | normal | Search word under cursor backward |
| `:%s/old/new/g` | command | Replace in whole file |
| `:'<,'>s/old/new/g` | command | Replace in visual selection |

### Windows And Tabs

| Key | Mode | Action |
| --- | --- | --- |
| `<C-W>s` | normal | Horizontal split |
| `<C-W>v` | normal | Vertical split |
| `<C-W>h` | normal | Focus left window |
| `<C-W>j` | normal | Focus lower window |
| `<C-W>k` | normal | Focus upper window |
| `<C-W>l` | normal | Focus right window |
| `<C-W>q` | normal | Close window |
| `<C-W>=` | normal | Equalize window sizes |
| `gt` | normal | Next tab |
| `gT` | normal | Previous tab |

### Marks And Jumps

| Key | Mode | Action |
| --- | --- | --- |
| `m<char>` | normal | Set mark |
| `` `<char> `` | normal | Jump to mark exact position |
| `'<char>` | normal | Jump to mark line |
| `<C-O>` | normal | Jump backward |
| `<C-I>` | normal | Jump forward |
| `''` | normal | Jump to previous line position |
| ``` `` ``` | normal | Jump to previous exact position |

### Registers And Macros

| Key | Mode | Action |
| --- | --- | --- |
| `"` | normal, visual | Register prefix |
| `"+y` | normal, visual | Yank to system clipboard |
| `"+p` | normal | Paste from system clipboard |
| `q<char>` | normal | Start recording macro |
| `q` | normal | Stop recording macro |
| `@<char>` | normal | Run macro |
| `@@` | normal | Repeat last macro |

## Plugin-Local Defaults

These mappings are active after opening the corresponding plugin UI. Use `?` inside many plugin windows to see their local help.

### lazy.nvim

Open with:

```vim
:Lazy
```

Useful defaults:

| Key | Mode | Action |
| --- | --- | --- |
| `?` | normal | Help |
| `q` | normal | Close |
| `u` | normal | Update plugins |
| `s` | normal | Sync plugins |
| `x` | normal | Clean unused plugins |
| `c` | normal | Check for updates |
| `l` | normal | Open log |

### Mason

Open with:

```vim
:Mason
```

Useful defaults:

| Key | Mode | Action |
| --- | --- | --- |
| `?` | normal | Help |
| `q` | normal | Close |
| `i` | normal | Install package |
| `u` | normal | Update package |
| `U` | normal | Update all packages |
| `X` | normal | Uninstall package |
| `/` | normal | Filter/search |

### fzf-lua

Opened through `<leader>ff`, `<leader>fg`, and `<leader>fb`.

Common defaults:

| Key | Mode | Action |
| --- | --- | --- |
| `<C-J>` / `<C-K>` | insert | Move selection down/up |
| `<CR>` | insert | Open selected item |
| `<C-X>` | insert | Open in horizontal split |
| `<C-V>` | insert | Open in vertical split |
| `<C-T>` | insert | Open in tab |
| `<Esc>` | insert | Close picker |

### Oil

Open with `<leader>e`.

Common defaults:

| Key | Mode | Action |
| --- | --- | --- |
| `<CR>` | normal | Open file or directory |
| `-` | normal | Go to parent directory |
| `_` | normal | Open current working directory |
| `g?` | normal | Help |
| `q` | normal | Close |

### Neogit

Open with `<leader>gg`.

Common defaults:

| Key | Mode | Action |
| --- | --- | --- |
| `?` | normal | Help |
| `q` | normal | Close popup/status window |
| `s` | normal | Stage item |
| `u` | normal | Unstage item |
| `S` | normal | Stage all |
| `U` | normal | Unstage all |
| `c` | normal | Commit popup |
| `P` | normal | Push popup |
| `p` | normal | Pull popup |
| `b` | normal | Branch popup |
| `r` | normal | Rebase popup |

### Trouble

Open diagnostics with `<leader>xx` or quickfix with `<leader>xq`.

Common defaults:

| Key | Mode | Action |
| --- | --- | --- |
| `<CR>` | normal | Open item |
| `o` | normal | Open item |
| `q` | normal | Close |
| `r` | normal | Refresh |
| `?` | normal | Help |

### Aerial

Open with `<leader>o`.

Common defaults:

| Key | Mode | Action |
| --- | --- | --- |
| `<CR>` | normal | Jump to symbol |
| `o` | normal | Jump to symbol |
| `q` | normal | Close |
| `{` | normal | Previous symbol |
| `}` | normal | Next symbol |
| `?` | normal | Help |

### DAP UI

Open with `<leader>du` after loading DAP.

Common defaults vary by window, but these are reliable habits:

| Key | Mode | Action |
| --- | --- | --- |
| `<CR>` | normal | Expand/collapse item or jump |
| `o` | normal | Open/expand item |
| `q` | normal | Close focused DAP UI window |

Core debug controls are AD custom mappings: `<F5>`, `<F10>`, `<F11>`, `<F12>`, `<leader>db`, and `<leader>du`.

### Neotest

Use AD custom mappings:

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>tt` | normal | Run nearest test |
| `<leader>tf` | normal | Run file tests |
| `<leader>ts` | normal | Toggle summary |

Inside the summary window:

| Key | Mode | Action |
| --- | --- | --- |
| `<CR>` | normal | Jump/run focused test depending on node |
| `o` | normal | Expand/collapse node |
| `q` | normal | Close summary |

### Overseer

Use AD custom mappings:

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>wr` | normal | Run task |
| `<leader>wt` | normal | Toggle task list |

Inside the task list:

| Key | Mode | Action |
| --- | --- | --- |
| `<CR>` | normal | Open task action/details |
| `q` | normal | Close |
| `?` | normal | Help |

### Sidekick

Use AD custom mappings:

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ar` | normal | Send `review_pack` |
| `<leader>ad` | normal | Send `debug_pack` |
| `<leader>aa` | visual | Send selection |

Sidekick terminal window defaults from the plugin config:

| Key | Mode | Action |
| --- | --- | --- |
| `<C-B>` | normal, terminal | Insert/open buffers context picker |
| `<C-F>` | normal, terminal | Insert/open files context picker |
| `<C-P>` | terminal | Insert prompt/context |
| `<C-Q>` | terminal | Enter terminal normal mode |
| `<C-.>` | normal, terminal | Hide terminal window |
| `<C-Z>` | normal, terminal | Blur terminal and return to previous window |
| `q` | normal | Hide terminal window |
| `<CR>` | normal | Send Enter to terminal and stay usable |
| `<C-H>` `<C-J>` `<C-K>` `<C-L>` | terminal | Navigate Neovim windows when possible |

### blink.cmp

This config uses blink.cmp's `default` preset. Important insert-mode habits:

| Key | Mode | Action |
| --- | --- | --- |
| `<C-Space>` | insert | Show completion |
| `<C-E>` | insert | Hide completion |
| `<CR>` | insert | Accept selected completion when menu is active |
| `<Tab>` | insert | Select/accept/jump depending on preset state |
| `<S-Tab>` | insert | Previous item or snippet jump depending on preset state |

If behavior changes after a plugin update, check:

```vim
:h blink-cmp-config-keymap
```

## Commands Without Keymaps

These are useful and intentionally left command-driven.

| Command | Purpose |
| --- | --- |
| `:Lazy` | Plugin manager |
| `:Mason` | External Neovim tools |
| `:checkhealth ad` | Local config health |
| `:Copilot auth` | Authenticate Copilot |
| `:TSManager` | Tree-sitter manager |
| `:GrugFar` | Search and replace |
| `:OverseerRun` | Run task |
| `:OverseerToggle` | Toggle task list |
| `:DapContinue` | Start/continue debug session |
| `:LivePreviewToggle` | Toggle browser preview |

## How To Discover More

Use these commands when something is unclear:

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
