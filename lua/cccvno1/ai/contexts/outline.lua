local M = {}

local function symbol_line(item, depth)
  local name = item.name or item.text or "<symbol>"
  local kind = item.kind or "symbol"
  local lnum = item.selection_range and item.selection_range.lnum or item.lnum
  local location = lnum and (" line " .. tostring(lnum)) or ""
  return ("%s- %s: %s%s"):format(string.rep("  ", depth), kind, name, location)
end

local function append_symbols(lines, items, depth, state)
  for _, item in ipairs(items or {}) do
    if state.count >= state.limit then
      state.truncated = true
      return
    end

    table.insert(lines, symbol_line(item, depth))
    state.count = state.count + 1
    if item.children and #item.children > 0 then
      append_symbols(lines, item.children, depth + 1, state)
      if state.truncated then
        return
      end
    end
  end
end

function M.render()
  local ok, aerial = pcall(require, "aerial")
  if not ok then
    return "Outline unavailable: aerial.nvim is not loaded."
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local ok_count, count = pcall(aerial.num_symbols, bufnr)
  if ok_count and count == 0 then
    pcall(aerial.refetch_symbols, bufnr)
  end

  local ok_data, data = pcall(require, "aerial.data")
  if not ok_data then
    return "Outline unavailable: aerial symbol data API is not available."
  end

  local ok_bufdata, bufdata = pcall(data.get, bufnr)
  local items = ok_bufdata and bufdata and bufdata.items or nil
  if not items or vim.tbl_isempty(items) then
    return "Outline unavailable: no symbols for current buffer."
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    name = "[No Name]"
  end

  local lines = { "File outline: " .. name }
  local state = { count = 0, limit = 200, truncated = false }
  append_symbols(lines, items, 0, state)
  if state.truncated then
    table.insert(lines, "... outline truncated ...")
  end
  return table.concat(lines, "\n")
end

return M
