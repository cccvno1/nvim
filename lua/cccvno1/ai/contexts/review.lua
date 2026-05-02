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

function M.render()
  return table.concat({
    require("cccvno1.ai.contexts.git").changed(),
    "",
    require("cccvno1.ai.contexts.git").diff(),
    "",
    diagnostics(),
    "",
    "Quickfix context:\n" .. quickfix(),
    "",
    require("cccvno1.ai.contexts.outline").render(),
  }, "\n")
end

return M
