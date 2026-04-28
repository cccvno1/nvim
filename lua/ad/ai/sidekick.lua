local M = {}

local function safe_context(fn)
  return function()
    local ok, result = pcall(fn)
    if ok then
      return result
    end
    return "Context unavailable: " .. result
  end
end

local function nes_enabled(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  return vim.g.sidekick_nes ~= false and vim.b[bufnr].sidekick_nes ~= false and vim.b[bufnr].bigfile ~= true
end

function M.setup()
  require("sidekick").setup({
    nes = {
      enabled = nes_enabled,
    },
    cli = {
      picker = "fzf-lua",
      mux = { enabled = false },
      context = {
        git_changed = safe_context(function()
          return require("ad.ai.contexts.git").changed()
        end),
        git_diff = safe_context(function()
          return require("ad.ai.contexts.git").diff()
        end),
        outline = safe_context(function()
          return require("ad.ai.contexts.outline").render()
        end),
        review_pack = safe_context(function()
          return require("ad.ai.contexts.review").render()
        end),
        dap_state = safe_context(function()
          return require("ad.ai.contexts.debug").dap_state()
        end),
        test_output = safe_context(function()
          return require("ad.ai.contexts.test").render()
        end),
        task_output = safe_context(function()
          return require("ad.ai.contexts.debug").task_output()
        end),
        debug_pack = safe_context(function()
          return require("ad.ai.contexts.debug").debug_pack()
        end),
      },
      prompts = {
        review_pack = "Review the current AI-generated changes for bugs, syntax errors, unnecessary edits, missing tests, and risky behavior.\n{review_pack}",
        debug_pack = "Help debug this failure. Use the diagnostics, DAP state, test output, and task output below.\n{debug_pack}",
      },
    },
  })
end

return M
