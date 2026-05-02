local M = {}

local required = { "git", "rg", "fd", "fzf" }
local optional = { "node", "unzip", "codex", "opencode", "tree-sitter", "tmux", "gum", "lazygit", "ws" }

local mason_packages = {
  "lua-language-server",
  "pyright",
  "gopls",
  "typescript-language-server",
  "clangd",
  "json-lsp",
  "yaml-language-server",
  "bash-language-server",
  "marksman",
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

local function safe_require(module)
  local ok, result = pcall(require, module)
  if ok then
    return result
  end
  return nil, result
end

local function lazy_plugin(name)
  local config = safe_require("lazy.core.config")
  return config and config.plugins and config.plugins[name] or nil
end

local function check_configured_plugin(name, module)
  if lazy_plugin(name) then
    vim.health.ok(name .. " configured")
  else
    vim.health.warn(name .. " is not configured in lazy.nvim")
  end

  local loaded = package.loaded[module]
  if loaded then
    vim.health.ok(module .. " module loaded")
    return loaded
  end
  vim.health.info(module .. " module is not loaded; runtime state checks skipped")
  return nil
end

local function check_lazy()
  local lazy = safe_require("lazy")
  if lazy then
    vim.health.ok("lazy.nvim loaded")
  else
    vim.health.error("lazy.nvim is not loaded")
  end
end

local function check_mason()
  local mason = safe_require("mason")
  if not mason then
    vim.health.warn("mason.nvim unavailable; package checks skipped")
    return
  end
  vim.health.ok("mason.nvim available")

  local registry, err = safe_require("mason-registry")
  if not registry then
    vim.health.warn("mason-registry unavailable: " .. tostring(err))
    return
  end

  for _, package in ipairs(mason_packages) do
    local ok_has, has_package = pcall(registry.has_package, package)
    if ok_has and not has_package then
      vim.health.warn("Mason package not in registry: " .. package)
    elseif ok_has then
      local ok_installed, installed = pcall(registry.is_installed, package)
      if ok_installed and installed then
        vim.health.ok("Mason package installed: " .. package)
      elseif ok_installed then
        vim.health.warn("Mason package missing: " .. package)
      else
        vim.health.warn("Could not inspect Mason package: " .. package)
      end
    end
  end
end

local function check_treesitter()
  if not lazy_plugin("tree-sitter-manager.nvim") then
    vim.health.warn("tree-sitter-manager.nvim is not configured in lazy.nvim")
    return
  end
  vim.health.ok("tree-sitter-manager.nvim configured")

  local ts = safe_require("cccvno1.core.treesitter")
  if not ts then
    vim.health.warn("cccvno1.core.treesitter unavailable")
    return
  end

  for _, parser in ipairs(ts.parsers) do
    if pcall(vim.treesitter.language.inspect, parser) then
      vim.health.ok("Tree-sitter parser installed: " .. parser)
    else
      vim.health.warn("Tree-sitter parser missing: " .. parser)
    end
  end
end

local function check_dap()
  local dap = check_configured_plugin("nvim-dap", "dap")
  if dap and type(dap.adapters) == "table" then
    for _, adapter in ipairs({ "python", "delve", "pwa-node", "codelldb" }) do
      if dap.adapters[adapter] then
        vim.health.ok("DAP adapter configured: " .. adapter)
      else
        vim.health.warn("DAP adapter not configured in current session: " .. adapter)
      end
    end
  end

  local data = vim.fn.stdpath("data")
  local paths = {
    debugpy = data .. "/mason/packages/debugpy/venv/bin/python",
    delve = data .. "/mason/packages/delve/dlv",
    ["js-debug-adapter"] = data .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
    codelldb = data .. "/mason/packages/codelldb/extension/adapter/codelldb",
  }

  for name, path in pairs(paths) do
    if vim.uv.fs_stat(path) then
      vim.health.ok("DAP external found: " .. name)
    else
      vim.health.warn(("DAP external missing or not executable path absent: %s (%s)"):format(name, path))
    end
  end
end

local function check_copilot()
  local node_version = ""
  if has("node") then
    local ok, out = pcall(vim.fn.systemlist, { "node", "--version" })
    if ok and out and out[1] then
      node_version = " " .. out[1]
    end
    vim.health.ok("node found for Copilot" .. node_version)
  else
    vim.health.warn("node missing")
  end

  local client_mod = check_configured_plugin("copilot.lua", "copilot.client")
  local auth = package.loaded["copilot.auth"]

  if auth and type(auth.is_authenticated) == "function" then
    local ok_auth, authenticated = pcall(auth.is_authenticated)
    if ok_auth and authenticated then
      vim.health.ok("Copilot authenticated")
    elseif ok_auth then
      vim.health.warn("Copilot auth is not confirmed")
    else
      vim.health.warn("Copilot auth state unavailable: " .. tostring(authenticated))
    end
  else
    vim.health.info("Copilot auth API is not loaded; auth state check skipped")
  end

  if client_mod and type(client_mod.get) == "function" then
    local ok_client, client = pcall(client_mod.get)
    if ok_client and client and client.initialized then
      vim.health.ok("Copilot LSP client initialized")
    elseif ok_client and client then
      vim.health.warn("Copilot LSP client exists but is not initialized")
    else
      vim.health.warn("Copilot LSP client is not running")
    end
  end
end

local function check_sidekick()
  check_configured_plugin("sidekick.nvim", "sidekick")

  local config = package.loaded["sidekick.config"]
  if config and type(config.get_client) == "function" then
    local ok_client, client = pcall(config.get_client)
    if ok_client and client then
      vim.health.ok("Sidekick Copilot provider client available")
    elseif ok_client then
      vim.health.warn("Sidekick Copilot provider client not attached")
    else
      vim.health.warn("Sidekick provider check failed: " .. tostring(client))
    end
  else
    vim.health.info("Sidekick provider config is not loaded; provider state check skipped")
  end

  local status = package.loaded["sidekick.status"]
  if status and type(status.cli) == "function" then
    local ok_cli, cli = pcall(status.cli)
    if ok_cli then
      vim.health.info(("Sidekick CLI sessions: %d"):format(type(cli) == "table" and #cli or 0))
    else
      vim.health.warn("Sidekick CLI status unavailable: " .. tostring(cli))
    end
  else
    vim.health.info("Sidekick CLI status API is not loaded; session check skipped")
  end

  for _, cmd in ipairs({ "codex", "opencode" }) do
    check_cmd(cmd, false)
  end
end

function M.check()
  vim.health.start("cccvno1.nvim")
  vim.health.info("Neovim " .. tostring(vim.version()))
  for _, cmd in ipairs(required) do
    check_cmd(cmd, true)
  end
  for _, cmd in ipairs(optional) do
    check_cmd(cmd, false)
  end

  check_lazy()
  check_mason()
  check_treesitter()
  check_dap()
  check_copilot()
  check_sidekick()
end

return M
