# AI Neovim Workbench Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the approved AI-first Neovim workbench from `docs/superpowers/specs/2026-04-29-ai-neovim-workbench-design.md`.

**Architecture:** The config is split into small `lua/ad/core/*`, `lua/ad/ai/*`, and `lua/ad/plugins/*` modules. Mature plugins provide editor features; local modules provide bigfile policy, health checks, buffer wrappers, root helpers, and Sidekick context extensions.

**Tech Stack:** Neovim 0.12, Lua, lazy.nvim, Mason, native LSP, blink.cmp, Copilot, Sidekick, fzf-lua, Oil, Aerial, barbar.nvim, gitsigns, neogit, codediff.nvim, nvim-dap, neotest, Overseer, render-markdown, live-preview, Kanagawa.

---

## Scope Check

This is one cohesive configuration project. It touches multiple subsystems, but each subsystem contributes to a single testable outcome: a complete AI coding workbench. The implementation should be done in small commits and verified after each layer.

## File Map

- Create `init.lua`: entrypoint, leader setup, module loading, lazy setup.
- Create `lua/ad/bootstrap.lua`: lazy.nvim bootstrap.
- Create `lua/ad/options.lua`: editor options.
- Create `lua/ad/autocmds.lua`: general autocmds.
- Create `lua/ad/keymaps.lua`: global keymaps only.
- Create `lua/ad/plugins/init.lua`: imports all plugin spec modules.
- Create `lua/ad/plugins/*.lua`: focused plugin specs by feature area.
- Create `lua/ad/core/bigfile.lua`: large-file detection and downgrade event.
- Create `lua/ad/core/buffers.lua`: wrappers around barbar/fzf buffer actions.
- Create `lua/ad/core/health.lua`: local health checks.
- Create `lua/ad/core/root.lua`: project root detection helpers.
- Create `lua/ad/core/ui.lua`: shared icons and small UI helpers.
- Create `lua/ad/ai/sidekick.lua`: Sidekick custom context setup.
- Create `lua/ad/ai/contexts/*.lua`: git, review, debug, test, task, and outline context renderers.

## Common Commands

Run these from `/home/chenchi/.config/nvim`.

- Format Lua: `stylua init.lua lua || true`
- Startup smoke test: `nvim --headless "+lua print('ok')" +qa`
- Plugin sync: `nvim --headless "+Lazy! sync" +qa`
- Health: `nvim --headless "+checkhealth" +qa`
- Lua load test: `nvim --headless "+lua require('ad.core.bigfile')" +qa`
- Git status: `git status --short`

If `stylua` is missing, skip formatting and record that in the task notes. Do not install system packages from this plan.

---

### Task 1: Bootstrap Skeleton

**Files:**
- Create: `init.lua`
- Create: `lua/ad/bootstrap.lua`
- Create: `lua/ad/options.lua`
- Create: `lua/ad/autocmds.lua`
- Create: `lua/ad/keymaps.lua`
- Create: `lua/ad/plugins/init.lua`

- [ ] **Step 1: Create the entrypoint**

Create `init.lua`:

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("ad.bootstrap")
require("ad.options")
require("ad.autocmds")
require("ad.keymaps")

require("lazy").setup({
  { import = "ad.plugins" },
}, {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  install = { colorscheme = { "kanagawa" } },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

- [ ] **Step 2: Create lazy.nvim bootstrap**

Create `lua/ad/bootstrap.lua`:

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    repo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. out)
  end
end

vim.opt.rtp:prepend(lazypath)
```

- [ ] **Step 3: Create editor options**

Create `lua/ad/options.lua`:

```lua
local opt = vim.opt

opt.autowrite = true
opt.breakindent = true
opt.clipboard = "unnamedplus"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.foldlevel = 99
opt.foldmethod = "indent"
opt.ignorecase = true
opt.inccommand = "split"
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.mouse = "a"
opt.number = true
opt.pumblend = 0
opt.relativenumber = true
opt.scrolloff = 4
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.swapfile = false
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 400
opt.undofile = true
opt.updatetime = 200
opt.virtualedit = "block"
opt.winminwidth = 5
opt.wrap = false

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
```

- [ ] **Step 4: Create general autocmds**

Create `lua/ad/autocmds.lua`:

```lua
local augroup = vim.api.nvim_create_augroup("ad_core", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "help", "man", "qf", "query", "checkhealth" },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
```

- [ ] **Step 5: Create global keymap shell**

Create `lua/ad/keymaps.lua`:

```lua
local map = vim.keymap.set

map({ "n", "x" }, "<Space>", "<Nop>", { silent = true })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix item" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "[l", "<cmd>lprevious<cr>", { desc = "Previous location item" })
map("n", "]l", "<cmd>lnext<cr>", { desc = "Next location item" })
```

- [ ] **Step 6: Create plugin import list**

Create `lua/ad/plugins/init.lua`:

```lua
return {
  { import = "ad.plugins.ui" },
  { import = "ad.plugins.picker" },
  { import = "ad.plugins.buffer" },
  { import = "ad.plugins.editor" },
  { import = "ad.plugins.treesitter" },
  { import = "ad.plugins.lsp" },
  { import = "ad.plugins.cmp" },
  { import = "ad.plugins.git" },
  { import = "ad.plugins.ai" },
  { import = "ad.plugins.dap" },
  { import = "ad.plugins.test" },
  { import = "ad.plugins.markdown" },
}
```

- [ ] **Step 7: Verify skeleton load**

Run: `nvim --headless "+lua print('ad skeleton ok')" +qa`

Expected: command exits 0 and prints `ad skeleton ok`.

- [ ] **Step 8: Commit skeleton**

```bash
git add init.lua lua/ad/bootstrap.lua lua/ad/options.lua lua/ad/autocmds.lua lua/ad/keymaps.lua lua/ad/plugins/init.lua
git commit -m "feat: bootstrap neovim workbench skeleton"
```

---

### Task 2: Core Modules

**Files:**
- Create: `lua/ad/core/root.lua`
- Create: `lua/ad/core/bigfile.lua`
- Create: `lua/ad/core/buffers.lua`
- Create: `lua/ad/core/health.lua`
- Create: `lua/ad/core/ui.lua`
- Modify: `lua/ad/autocmds.lua`

- [ ] **Step 1: Create root helper**

Create `lua/ad/core/root.lua`:

```lua
local M = {}

M.markers = { ".git", "lua", "package.json", "pyproject.toml", "go.mod", "Cargo.toml", "Makefile" }

function M.get(bufnr)
  bufnr = bufnr or 0
  local name = vim.api.nvim_buf_get_name(bufnr)
  local start = name ~= "" and vim.fs.dirname(name) or vim.uv.cwd()
  local found = vim.fs.find(M.markers, { upward = true, path = start })[1]
  return found and vim.fs.dirname(found) or vim.uv.cwd()
end

function M.chdir(bufnr)
  local root = M.get(bufnr)
  if root and root ~= "" then
    vim.cmd.tcd(vim.fn.fnameescape(root))
  end
  return root
end

return M
```

- [ ] **Step 2: Create bigfile module**

Create `lua/ad/core/bigfile.lua`:

```lua
local M = {}

M.defaults = {
  size = 1.5 * 1024 * 1024,
  lines = 100000,
  line_length = 1000,
}

local cache = {}

local function file_size(path)
  local stat = path and vim.uv.fs_stat(path)
  return stat and stat.size or 0
end

function M.is_big(bufnr)
  bufnr = bufnr or 0
  if cache[bufnr] ~= nil then
    return cache[bufnr]
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local size = file_size(path)
  local lines = math.max(vim.api.nvim_buf_line_count(bufnr), 1)
  local average = size > 0 and ((size - lines) / lines) or 0

  local big = size > M.defaults.size or lines > M.defaults.lines or average > M.defaults.line_length
  cache[bufnr] = big
  return big
end

function M.apply(bufnr)
  bufnr = bufnr or 0
  if not M.is_big(bufnr) then
    return false
  end

  vim.b[bufnr].bigfile = true
  vim.b[bufnr].completion = false
  vim.b[bufnr].autoformat = false

  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.list = false
    vim.opt_local.spell = false
    vim.opt_local.swapfile = false
    vim.opt_local.undolevels = -1
    vim.opt_local.statuscolumn = ""
    vim.opt_local.conceallevel = 0
  end)

  pcall(vim.treesitter.stop, bufnr)
  vim.diagnostic.enable(false, { bufnr = bufnr })

  vim.api.nvim_exec_autocmds("User", {
    pattern = "BigFile",
    data = { buf = bufnr },
  })

  vim.notify("Big file mode enabled", vim.log.levels.WARN, { title = "Neovim" })
  return true
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ad_bigfile", { clear = true })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(event)
      M.apply(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(event)
      cache[event.buf] = nil
    end,
  })
end

return M
```

- [ ] **Step 3: Create buffer wrappers**

Create `lua/ad/core/buffers.lua`:

```lua
local M = {}

local function cmd(name)
  return function()
    vim.cmd(name)
  end
end

M.close = cmd("BufferClose")
M.close_force = cmd("BufferClose!")
M.close_others = cmd("BufferCloseAllButCurrentOrPinned")
M.close_left = cmd("BufferCloseBuffersLeft")
M.close_right = cmd("BufferCloseBuffersRight")
M.pick = cmd("BufferPick")
M.pin = cmd("BufferPin")

function M.find()
  require("fzf-lua").buffers({ sort_mru = true, sort_lastused = true })
end

return M
```

- [ ] **Step 4: Create UI helper**

Create `lua/ad/core/ui.lua`:

```lua
local M = {}

M.icons = {
  diagnostics = {
    Error = "E",
    Warn = "W",
    Hint = "H",
    Info = "I",
  },
  git = {
    added = "+",
    changed = "~",
    deleted = "-",
  },
}

function M.bigfile_status()
  return vim.b.bigfile and "BIG" or ""
end

return M
```

- [ ] **Step 5: Create health checks**

Create `lua/ad/core/health.lua`:

```lua
local M = {}

local required = { "git", "rg", "fd", "fzf" }
local optional = { "node", "codex", "opencode", "tree-sitter" }

local function has(cmd)
  return vim.fn.executable(cmd) == 1
end

local function check_cmd(cmd, required_cmd)
  if has(cmd) then
    vim.health.ok(cmd .. " found")
  elseif required_cmd then
    vim.health.error(cmd .. " missing")
  else
    vim.health.warn(cmd .. " missing")
  end
end

function M.check()
  vim.health.start("ad.nvim")
  vim.health.info("Neovim " .. tostring(vim.version()))
  for _, cmd in ipairs(required) do
    check_cmd(cmd, true)
  end
  for _, cmd in ipairs(optional) do
    check_cmd(cmd, false)
  end

  local lazy_ok = pcall(require, "lazy")
  if lazy_ok then
    vim.health.ok("lazy.nvim loaded")
  else
    vim.health.error("lazy.nvim is not loaded")
  end
end

return M
```

- [ ] **Step 6: Register core modules**

Append this line to the end of `lua/ad/autocmds.lua`:

```lua
require("ad.core.bigfile").setup()
```

Create `lua/ad/health.lua`:

```lua
return require("ad.core.health")
```

- [ ] **Step 7: Verify core modules**

Run:

```bash
nvim --headless "+lua require('ad.core.bigfile'); require('ad.core.root'); require('ad.core.buffers'); require('ad.core.health'); print('core ok')" +qa
```

Expected: exits 0 and prints `core ok`.

- [ ] **Step 8: Commit core modules**

```bash
git add lua/ad/core lua/ad/autocmds.lua lua/ad/health.lua
git commit -m "feat: add core workbench modules"
```

---

### Task 3: UI, Picker, Files, Buffer, and Editing Plugins

**Files:**
- Create: `lua/ad/plugins/ui.lua`
- Create: `lua/ad/plugins/picker.lua`
- Create: `lua/ad/plugins/buffer.lua`
- Create: `lua/ad/plugins/editor.lua`
- Modify: `lua/ad/keymaps.lua`

- [ ] **Step 1: Create UI plugin spec**

Create `lua/ad/plugins/ui.lua`:

```lua
return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      compile = false,
      dimInactive = false,
      terminalColors = true,
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  {
    "echasnovski/mini.icons",
    version = false,
    lazy = false,
    config = function()
      local icons = require("mini.icons")
      icons.setup()
      icons.mock_nvim_web_devicons()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local ui = require("ad.core.ui")
      return {
        options = {
          theme = "kanagawa",
          globalstatus = true,
          component_separators = "",
          section_separators = "",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { ui.bigfile_status, "diagnostics", "encoding", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
}
```

- [ ] **Step 2: Create picker and file plugin spec**

Create `lua/ad/plugins/picker.lua`:

```lua
return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      winopts = { border = "rounded", preview = { border = "rounded" } },
      fzf_opts = { ["--layout"] = "reverse" },
    },
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      view_options = { show_hidden = true },
      float = { border = "rounded" },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = {},
  },
}
```

- [ ] **Step 3: Create buffer plugin spec**

Create `lua/ad/plugins/buffer.lua`:

```lua
return {
  {
    "romgrk/barbar.nvim",
    event = "VeryLazy",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "echasnovski/mini.icons",
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = false,
      clickable = true,
      focus_on_close = "left",
      icons = {
        button = "x",
        modified = { button = "*" },
        pinned = { button = "P", filename = true },
        diagnostics = {
          { enabled = true, icon = "E" },
          { enabled = true, icon = "W" },
        },
        gitsigns = {
          added = { enabled = true, icon = "+" },
          changed = { enabled = true, icon = "~" },
          deleted = { enabled = true, icon = "-" },
        },
      },
      sidebar_filetypes = {
        oil = { text = "Oil", align = "center" },
      },
    },
    config = function(_, opts)
      require("barbar").setup(opts)
    end,
  },
}
```

- [ ] **Step 4: Create editing plugin spec**

Create `lua/ad/plugins/editor.lua`:

```lua
return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
  },
  { "echasnovski/mini.ai", version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.surround", version = false, event = "VeryLazy", opts = {} },
  { "echasnovski/mini.pairs", version = false, event = "InsertEnter", opts = {} },
  {
    "numToStr/Comment.nvim",
    keys = { "gc", "gcc", "gbc" },
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
```

- [ ] **Step 5: Add global navigation keymaps**

Append to `lua/ad/keymaps.lua`:

```lua
map("n", "<leader>ff", function() require("fzf-lua").files() end, { desc = "Find files" })
map("n", "<leader>fg", function() require("fzf-lua").live_grep() end, { desc = "Live grep" })
map("n", "<leader>fb", function() require("ad.core.buffers").find() end, { desc = "Find buffers" })
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "Open Oil" })
map("n", "<leader>sr", "<cmd>GrugFar<cr>", { desc = "Search and replace" })
map("n", "<leader>bd", function() require("ad.core.buffers").close() end, { desc = "Close buffer" })
map("n", "<leader>bo", function() require("ad.core.buffers").close_others() end, { desc = "Close other buffers" })
map("n", "<leader>bp", function() require("ad.core.buffers").pin() end, { desc = "Pin buffer" })
map({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
```

- [ ] **Step 6: Sync and verify layer**

Run: `nvim --headless "+Lazy! sync" +qa`

Expected: exits 0 and installs UI, picker, buffer, and editing plugins.

Run: `nvim --headless "+lua require('fzf-lua'); require('oil'); require('barbar'); print('ui layer ok')" +qa`

Expected: exits 0 and prints `ui layer ok`.

- [ ] **Step 7: Commit UI and navigation layer**

```bash
git add lua/ad/plugins/ui.lua lua/ad/plugins/picker.lua lua/ad/plugins/buffer.lua lua/ad/plugins/editor.lua lua/ad/keymaps.lua lazy-lock.json
git commit -m "feat: add ui navigation and buffer plugins"
```

---

### Task 4: Treesitter, LSP, Completion, Format, and Lint

**Files:**
- Create: `lua/ad/plugins/treesitter.lua`
- Create: `lua/ad/plugins/lsp.lua`
- Create: `lua/ad/plugins/cmp.lua`

- [ ] **Step 1: Verify current plugin APIs before writing config**

Run:

```bash
mkdir -p /tmp/ad-nvim-api-check
git clone --depth 1 https://github.com/romus204/tree-sitter-manager.nvim.git /tmp/ad-nvim-api-check/tree-sitter-manager.nvim
git clone --depth 1 https://github.com/saghen/blink.cmp.git /tmp/ad-nvim-api-check/blink.cmp
git clone --depth 1 https://github.com/fang2hou/blink-copilot.git /tmp/ad-nvim-api-check/blink-copilot
rg -n "setup|vim.lsp.config|providers|module = \"blink-copilot\"|tree-sitter-manager" /tmp/ad-nvim-api-check
```

Expected: output includes setup examples for `tree-sitter-manager.nvim`, `blink.cmp`, and `blink-copilot`. If any repo no longer exposes those names, stop this task and revise the plugin spec before editing files.

- [ ] **Step 2: Create Treesitter spec**

Create `lua/ad/plugins/treesitter.lua`:

```lua
return {
  {
    "romus204/tree-sitter-manager.nvim",
    cmd = { "TSM", "TSMInstall", "TSMUpdate", "TSMUninstall" },
    opts = {},
  },
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {
      opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
    },
  },
}
```

- [ ] **Step 3: Create LSP, Mason, format, and lint spec**

Create `lua/ad/plugins/lsp.lua`:

```lua
local servers = {
  lua_ls = {},
  pyright = {},
  gopls = {},
  ts_ls = {},
  clangd = {},
  jsonls = {},
  yamlls = {},
  bashls = {},
  marksman = {},
}

local tools = {
  "stylua",
  "black",
  "isort",
  "gofumpt",
  "goimports",
  "prettier",
  "eslint_d",
  "shellcheck",
  "shfmt",
  "clang-format",
}

return {
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = vim.tbl_keys(servers),
      automatic_enable = false,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = { ensure_installed = tools, run_on_start = false },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ad_lsp_attach", { clear = true }),
        callback = function(event)
          if vim.b[event.buf].bigfile then
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client then
              client.server_capabilities.semanticTokensProvider = nil
            end
          end
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
        end,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      format_on_save = function(bufnr)
        if vim.b[bufnr].bigfile or vim.b[bufnr].autoformat == false then
          return nil
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        go = { "goimports", "gofumpt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        sh = { "shfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        sh = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("ad_lint", { clear = true }),
        callback = function(event)
          if not vim.b[event.buf].bigfile then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
```

- [ ] **Step 4: Create completion and Copilot spec**

Create `lua/ad/plugins/cmp.lua`:

```lua
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        bigfile = false,
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = "*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "zbirenbaum/copilot.lua",
      "fang2hou/blink-copilot",
    },
    opts = {
      keymap = { preset = "default" },
      completion = { documentation = { auto_show = true, auto_show_delay_ms = 300 } },
      sources = {
        default = function()
          if vim.b.bigfile or vim.b.completion == false then
            return { "buffer", "path" }
          end
          return { "lsp", "path", "buffer", "copilot" }
        end,
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
}
```

- [ ] **Step 5: Sync and verify language layer**

Run: `nvim --headless "+Lazy! sync" +qa`

Expected: exits 0 and installs language plugins.

Run:

```bash
nvim --headless "+lua require('mason'); require('blink.cmp'); require('conform'); require('lint'); print('language layer ok')" +qa
```

Expected: exits 0 and prints `language layer ok`.

- [ ] **Step 6: Commit language layer**

```bash
git add lua/ad/plugins/treesitter.lua lua/ad/plugins/lsp.lua lua/ad/plugins/cmp.lua lazy-lock.json
git commit -m "feat: add language tooling and completion"
```

---

### Task 5: Git, Review, Outline, Diagnostics, and Quickfix

**Files:**
- Create: `lua/ad/plugins/git.lua`
- Modify: `lua/ad/plugins/picker.lua`
- Modify: `lua/ad/keymaps.lua`

- [ ] **Step 1: Create git and review plugin spec**

Create `lua/ad/plugins/git.lua`:

```lua
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("]h", gs.next_hunk, "Next hunk")
        map("[h", gs.prev_hunk, "Previous hunk")
        map("<leader>hp", gs.preview_hunk, "Preview hunk")
        map("<leader>hr", gs.reset_hunk, "Reset hunk")
      end,
    },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    opts = {
      integrations = { diffview = false },
    },
  },
  {
    "esmuellert/codediff.nvim",
    cmd = { "CodeDiff" },
    opts = {},
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
  },
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen" },
    opts = function()
      return {
        backends = { "lsp", "treesitter", "markdown", "man" },
        disable_max_lines = require("ad.core.bigfile").defaults.lines,
        disable_max_size = require("ad.core.bigfile").defaults.size,
      }
    end,
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    opts = {},
  },
}
```

- [ ] **Step 2: Add review keymaps**

Append to `lua/ad/keymaps.lua`:

```lua
map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
map("n", "<leader>gd", "<cmd>CodeDiff<cr>", { desc = "Code diff" })
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix" })
map("n", "<leader>o", "<cmd>AerialToggle<cr>", { desc = "Outline" })
```

- [ ] **Step 3: Sync and verify review layer**

Run: `nvim --headless "+Lazy! sync" +qa`

Expected: exits 0 and installs git/review plugins.

Run:

```bash
nvim --headless "+lua require('gitsigns'); require('neogit'); require('trouble'); require('aerial'); print('review layer ok')" +qa
```

Expected: exits 0 and prints `review layer ok`.

- [ ] **Step 4: Commit review layer**

```bash
git add lua/ad/plugins/git.lua lua/ad/keymaps.lua lazy-lock.json
git commit -m "feat: add git review and outline tools"
```

---

### Task 6: Sidekick and AI Contexts

**Files:**
- Create: `lua/ad/plugins/ai.lua`
- Create: `lua/ad/ai/sidekick.lua`
- Create: `lua/ad/ai/contexts/git.lua`
- Create: `lua/ad/ai/contexts/outline.lua`
- Create: `lua/ad/ai/contexts/test.lua`
- Create: `lua/ad/ai/contexts/debug.lua`
- Create: `lua/ad/ai/contexts/review.lua`
- Modify: `lua/ad/keymaps.lua`

- [ ] **Step 1: Verify current Sidekick context API**

Run:

```bash
mkdir -p /tmp/ad-nvim-api-check
git clone --depth 1 https://github.com/folke/sidekick.nvim.git /tmp/ad-nvim-api-check/sidekick.nvim
rg -n "context = \\{|prompts = \\{|picker =|mux =|function M.fn|sidekick.context.Fn" /tmp/ad-nvim-api-check/sidekick.nvim/lua /tmp/ad-nvim-api-check/sidekick.nvim/sk
```

Expected: output shows `cli.context`, `cli.prompts`, `cli.picker`, and `cli.mux.enabled`. If those names are absent, stop this task and revise `lua/ad/ai/sidekick.lua` against current source.

- [ ] **Step 2: Create git context renderer**

Create `lua/ad/ai/contexts/git.lua`:

```lua
local M = {}

local function system(args)
  local out = vim.system(args, { text = true }):wait()
  if out.code ~= 0 then
    return ""
  end
  return vim.trim(out.stdout or "")
end

function M.changed()
  local out = system({ "git", "status", "--short" })
  if out == "" then
    return "No git changes."
  end
  return "Git changed files:\n" .. out
end

function M.diff()
  local out = system({ "git", "diff", "--stat" })
  local diff = system({ "git", "diff", "--", "." })
  if diff == "" then
    return "No git diff."
  end
  local limit = 60000
  if #diff > limit then
    diff = diff:sub(1, limit) .. "\n\n[diff truncated at " .. limit .. " characters]"
  end
  return "Git diff stat:\n" .. out .. "\n\nGit diff:\n" .. diff
end

return M
```

- [ ] **Step 3: Create outline context renderer**

Create `lua/ad/ai/contexts/outline.lua`:

```lua
local M = {}

function M.render()
  local ok, aerial = pcall(require, "aerial")
  if not ok then
    return "Outline unavailable: aerial.nvim is not loaded."
  end

  local items = aerial.get_location(true) or {}
  if vim.tbl_isempty(items) then
    return "Outline unavailable: no symbols for current buffer."
  end

  local lines = { "Current outline:" }
  for _, item in ipairs(items) do
    local name = item.name or item.text or "<symbol>"
    local kind = item.kind or "symbol"
    table.insert(lines, ("- %s: %s"):format(kind, name))
  end
  return table.concat(lines, "\n")
end

return M
```

- [ ] **Step 4: Create test context renderer**

Create `lua/ad/ai/contexts/test.lua`:

```lua
local M = { last_output = nil }

function M.set_last_output(output)
  M.last_output = output
end

function M.render()
  if M.last_output and M.last_output ~= "" then
    return "Recent test output:\n" .. M.last_output
  end
  return "No recent neotest output captured."
end

return M
```

- [ ] **Step 5: Create debug context renderer**

Create `lua/ad/ai/contexts/debug.lua`:

```lua
local M = {}

function M.dap_state()
  local ok, dap = pcall(require, "dap")
  if not ok then
    return "DAP unavailable: nvim-dap is not loaded."
  end

  local session = dap.session()
  if not session then
    return "No active DAP session."
  end

  local lines = { "DAP session active." }
  if session.config and session.config.name then
    table.insert(lines, "Config: " .. session.config.name)
  end
  table.insert(lines, "Use DAP UI scopes/repl for full variable inspection.")
  return table.concat(lines, "\n")
end

function M.task_output()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    return "Task output unavailable: overseer.nvim is not loaded."
  end

  local tasks = overseer.list_tasks({ recent_first = true })
  local task = tasks and tasks[1]
  if not task then
    return "No recent Overseer task output."
  end

  local lines = task:get_output() or {}
  if #lines == 0 then
    return "Most recent Overseer task has no captured output."
  end
  return "Recent task output:\n" .. table.concat(lines, "\n")
end

function M.debug_pack()
  return table.concat({
    M.dap_state(),
    "",
    M.task_output(),
    "",
    require("ad.ai.contexts.test").render(),
  }, "\n")
end

return M
```

- [ ] **Step 6: Create review context renderer**

Create `lua/ad/ai/contexts/review.lua`:

```lua
local M = {}

local function diagnostics()
  local diags = vim.diagnostic.get(nil)
  if #diags == 0 then
    return "No diagnostics."
  end

  local lines = { "Diagnostics:" }
  for _, d in ipairs(diags) do
    local name = vim.api.nvim_buf_get_name(d.bufnr)
    table.insert(lines, ("%s:%d:%d %s"):format(name, d.lnum + 1, d.col + 1, d.message))
  end
  return table.concat(lines, "\n")
end

function M.render()
  return table.concat({
    require("ad.ai.contexts.git").changed(),
    "",
    require("ad.ai.contexts.git").diff(),
    "",
    diagnostics(),
    "",
    require("ad.ai.contexts.outline").render(),
  }, "\n")
end

return M
```

- [ ] **Step 7: Create Sidekick setup**

Create `lua/ad/ai/sidekick.lua`:

```lua
local M = {}

function M.setup()
  require("sidekick").setup({
    cli = {
      picker = "fzf-lua",
      mux = { enabled = false },
      context = {
        git_changed = function()
          return require("ad.ai.contexts.git").changed()
        end,
        git_diff = function()
          return require("ad.ai.contexts.git").diff()
        end,
        outline = function()
          return require("ad.ai.contexts.outline").render()
        end,
        review_pack = function()
          return require("ad.ai.contexts.review").render()
        end,
        dap_state = function()
          return require("ad.ai.contexts.debug").dap_state()
        end,
        test_output = function()
          return require("ad.ai.contexts.test").render()
        end,
        task_output = function()
          return require("ad.ai.contexts.debug").task_output()
        end,
        debug_pack = function()
          return require("ad.ai.contexts.debug").debug_pack()
        end,
      },
      prompts = {
        review_pack = "Review the current AI-generated changes for bugs, syntax errors, unnecessary edits, missing tests, and risky behavior.\n{review_pack}",
        debug_pack = "Help debug this failure. Use the diagnostics, DAP state, test output, and task output below.\n{debug_pack}",
      },
    },
  })
end

return M
```

- [ ] **Step 8: Create AI plugin spec**

Create `lua/ad/plugins/ai.lua`:

```lua
return {
  {
    "folke/sidekick.nvim",
    cmd = "Sidekick",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "ibhagwan/fzf-lua",
    },
    config = function()
      require("ad.ai.sidekick").setup()
    end,
  },
}
```

- [ ] **Step 9: Add AI keymaps**

Append to `lua/ad/keymaps.lua`:

```lua
map("n", "<leader>ar", "<cmd>Sidekick review_pack<cr>", { desc = "AI review pack" })
map("n", "<leader>ad", "<cmd>Sidekick debug_pack<cr>", { desc = "AI debug pack" })
map("v", "<leader>aa", "<cmd>Sidekick<cr>", { desc = "AI selection" })
```

- [ ] **Step 10: Sync and verify AI layer**

Run: `nvim --headless "+Lazy! sync" +qa`

Expected: exits 0 and installs Sidekick.

Run:

```bash
nvim --headless "+lua require('ad.ai.contexts.git').changed(); require('ad.ai.contexts.review').render(); print('ai contexts ok')" +qa
```

Expected: exits 0 and prints `ai contexts ok`.

- [ ] **Step 11: Commit AI layer**

```bash
git add lua/ad/plugins/ai.lua lua/ad/ai lua/ad/keymaps.lua lazy-lock.json
git commit -m "feat: add sidekick ai context workflow"
```

---

### Task 7: DAP, Tests, and Tasks

**Files:**
- Create: `lua/ad/plugins/dap.lua`
- Create: `lua/ad/plugins/test.lua`
- Modify: `lua/ad/keymaps.lua`

- [ ] **Step 1: Create DAP plugin spec**

Create `lua/ad/plugins/dap.lua`:

```lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "jay-babu/mason-nvim-dap.nvim",
      "Weissle/persistent-breakpoints.nvim",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "delve", "js", "codelldb" },
        automatic_installation = true,
      })
      dapui.setup()
      require("nvim-dap-virtual-text").setup({
        enabled = function()
          return not vim.b.bigfile
        end,
      })
      require("persistent-breakpoints").setup({ load_breakpoints_event = { "BufReadPost" } })
      require("dap-go").setup()

      local python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(python)

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
```

- [ ] **Step 2: Create test and task plugin spec**

Create `lua/ad/plugins/test.lua`:

```lua
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "nvim-neotest/neotest-plenary",
      "alfaix/neotest-gtest",
    },
    config = function()
      local adapters = {
        require("neotest-python")({}),
        require("neotest-go"),
        require("neotest-jest")({}),
        require("neotest-vitest"),
        require("neotest-plenary"),
        require("neotest-gtest"),
      }

      require("neotest").setup({ adapters = adapters })
    end,
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerInfo" },
    opts = {},
  },
}
```

- [ ] **Step 3: Add DAP and test keymaps**

Append to `lua/ad/keymaps.lua`:

```lua
map("n", "<F5>", function() require("dap").continue() end, { desc = "DAP continue" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP step over" })
map("n", "<F11>", function() require("dap").step_into() end, { desc = "DAP step into" })
map("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP step out" })
map("n", "<leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end, { desc = "Toggle breakpoint" })
map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "DAP UI" })
map("n", "<leader>tt", function() require("neotest").run.run() end, { desc = "Run nearest test" })
map("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Run file tests" })
map("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Test summary" })
map("n", "<leader>or", "<cmd>OverseerRun<cr>", { desc = "Run task" })
map("n", "<leader>ot", "<cmd>OverseerToggle<cr>", { desc = "Tasks" })
```

- [ ] **Step 4: Sync and verify debug/test layer**

Run: `nvim --headless "+Lazy! sync" +qa`

Expected: exits 0 and installs DAP/test/task plugins.

Run:

```bash
nvim --headless "+lua require('dap'); require('dapui'); require('neotest'); require('overseer'); print('debug test layer ok')" +qa
```

Expected: exits 0 and prints `debug test layer ok`.

- [ ] **Step 5: Commit debug/test layer**

```bash
git add lua/ad/plugins/dap.lua lua/ad/plugins/test.lua lua/ad/keymaps.lua lazy-lock.json
git commit -m "feat: add debug test and task workflow"
```

---

### Task 8: Markdown and Documentation Preview

**Files:**
- Create: `lua/ad/plugins/markdown.lua`
- Modify: `lua/ad/keymaps.lua`

- [ ] **Step 1: Create Markdown plugin spec**

Create `lua/ad/plugins/markdown.lua`:

```lua
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante", "codecompanion" },
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      enabled = true,
    },
    config = function(_, opts)
      if vim.b.bigfile then
        opts.enabled = false
      end
      require("render-markdown").setup(opts)
    end,
  },
  {
    "brianhuster/live-preview.nvim",
    ft = { "markdown", "html", "svg" },
    cmd = { "LivePreview", "LivePreviewClose", "LivePreviewToggle" },
    opts = {},
  },
}
```

- [ ] **Step 2: Add Markdown keymaps**

Append to `lua/ad/keymaps.lua`:

```lua
map("n", "<leader>mp", "<cmd>LivePreviewToggle<cr>", { desc = "Markdown preview" })
```

- [ ] **Step 3: Sync and verify Markdown layer**

Run: `nvim --headless "+Lazy! sync" +qa`

Expected: exits 0 and installs Markdown plugins.

Run:

```bash
nvim --headless "+lua require('render-markdown'); require('live-preview'); print('markdown layer ok')" +qa
```

Expected: exits 0 and prints `markdown layer ok`.

- [ ] **Step 4: Commit Markdown layer**

```bash
git add lua/ad/plugins/markdown.lua lua/ad/keymaps.lua lazy-lock.json
git commit -m "feat: add markdown reading and preview"
```

---

### Task 9: Final Validation and Health

**Files:**
- Modify: `lua/ad/core/health.lua`
- Modify: plugin specs only if validation reveals load errors.

- [ ] **Step 1: Run plugin installation**

Run: `nvim --headless "+Lazy! sync" +qa`

Expected: exits 0.

- [ ] **Step 2: Run startup smoke test**

Run: `nvim --headless "+lua print('startup ok')" +qa`

Expected: exits 0 and prints `startup ok`.

- [ ] **Step 3: Run module load checks**

Run:

```bash
nvim --headless "+lua require('ad.core.bigfile'); require('ad.core.health'); require('ad.ai.contexts.review').render(); print('modules ok')" +qa
```

Expected: exits 0 and prints `modules ok`.

- [ ] **Step 4: Run health check**

Run: `nvim --headless "+checkhealth ad" +qa`

Expected: exits 0. Missing optional tools such as `node`, `codex`, `opencode`, or `tree-sitter` appear as warnings, not Lua errors.

- [ ] **Step 5: Validate bigfile mode**

Run:

```bash
perl -e 'print "x" x (2 * 1024 * 1024)' > /tmp/ad-bigfile.txt
nvim --headless /tmp/ad-bigfile.txt "+lua assert(vim.b.bigfile == true, 'bigfile not detected'); print('bigfile ok')" +qa
rm -f /tmp/ad-bigfile.txt
```

Expected: exits 0 and prints `bigfile ok`.

- [ ] **Step 6: Validate git context**

Run:

```bash
nvim --headless "+lua local r=require('ad.ai.contexts.review').render(); assert(type(r)=='string' and #r > 0); print('review context ok')" +qa
```

Expected: exits 0 and prints `review context ok`.

- [ ] **Step 7: Run full status check**

Run: `git status --short`

Expected: only intentional tracked config changes and `lazy-lock.json` appear. `.superpowers/` remains untracked unless the user explicitly asks to track it.

- [ ] **Step 8: Commit validation fixes**

If validation required fixes, commit them:

```bash
git add init.lua lua lazy-lock.json
git commit -m "fix: stabilize workbench validation"
```

If validation required no fixes, skip this commit.

---

## Self-Review

- Spec coverage: package manager, LSP, completion, Copilot, Sidekick, contexts, navigation, buffer management, git review, debug/test/task, markdown, UI, bigfile, and health checks each have a task.
- Placeholder scan: no unresolved markers or incomplete file responsibilities are present.
- Type consistency: context names match the design: `git_changed`, `git_diff`, `review_pack`, `dap_state`, `test_output`, `task_output`, `outline`, and `debug_pack`.
- Boundary check: plugin specs own plugin setup; `core/*` owns policy; `ai/contexts/*` owns Sidekick context renderers.
- Known execution risk: plugin APIs may have shifted. The plan includes source-verification steps for Sidekick, blink.cmp, blink-copilot, and tree-sitter-manager before those files are implemented.
