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
  "debugpy",
  "delve",
  "js-debug-adapter",
  "codelldb",
}

local function guarded_root_dir(name, config)
  local base = vim.tbl_deep_extend("force", {}, vim.lsp.config[name] or {}, config or {})
  local root_dir = base.root_dir
  local root_markers = base.root_markers

  return function(bufnr, on_dir)
    if require("cccvno1.core.bigfile").is_big(bufnr) then
      return
    end

    if type(root_dir) == "function" then
      root_dir(bufnr, on_dir)
    elseif root_dir ~= nil then
      on_dir(root_dir)
    elseif root_markers ~= nil then
      on_dir(vim.fs.root(bufnr, root_markers))
    else
      on_dir(nil)
    end
  end
end

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
        vim.lsp.config(name, vim.tbl_deep_extend("force", config, {
          root_dir = guarded_root_dir(name, config),
        }))
        vim.lsp.enable(name)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("cccvno1_lsp_attach", { clear = true }),
        callback = function(event)
          if vim.b[event.buf].bigfile then
            return
          end

          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end

          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
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
        group = vim.api.nvim_create_augroup("cccvno1_lint", { clear = true }),
        callback = function(event)
          if not vim.b[event.buf].bigfile then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
