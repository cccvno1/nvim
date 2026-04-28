local M = {}

local function diagnostics()
  local ok, diags = pcall(vim.diagnostic.get, nil)
  if not ok then
    return "Diagnostics unavailable: " .. diags
  end

  if #diags == 0 then
    return "Diagnostics: none."
  end

  local lines = { "Diagnostics:" }
  for _, d in ipairs(diags) do
    local name = vim.api.nvim_buf_get_name(d.bufnr)
    if name == "" then
      name = "[No Name]"
    end
    table.insert(lines, ("%s:%d:%d %s"):format(name, d.lnum + 1, d.col + 1, d.message))
  end
  return table.concat(lines, "\n")
end

local function quickfix()
  local ok, qf = pcall(vim.fn.getqflist, { items = 0, title = 0 })
  if not ok then
    return "Quickfix unavailable: " .. qf
  end

  local items = qf.items or {}
  if #items == 0 then
    return "No quickfix items."
  end

  local lines = { "Quickfix:" }
  for _, item in ipairs(items) do
    local name = item.filename
    if not name and item.bufnr and item.bufnr > 0 and vim.api.nvim_buf_is_valid(item.bufnr) then
      name = vim.api.nvim_buf_get_name(item.bufnr)
    end
    if not name or name == "" then
      name = "[No Name]"
    end
    table.insert(lines, ("%s:%d:%d %s"):format(name, item.lnum or 0, item.col or 0, item.text or ""))
  end
  return table.concat(lines, "\n")
end

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

  local ok_output, lines = pcall(function()
    return task:get_output()
  end)
  if not ok_output or not lines or #lines == 0 then
    return "Most recent Overseer task has no captured output."
  end

  return "Recent task output:\n" .. table.concat(lines, "\n")
end

function M.debug_pack()
  return table.concat({
    diagnostics(),
    "",
    "Quickfix context:\n" .. quickfix(),
    "",
    M.dap_state(),
    "",
    M.task_output(),
    "",
    require("ad.ai.contexts.test").render(),
  }, "\n")
end

return M
