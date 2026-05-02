local M = {}

local function notify_result(label, result)
  if result.code == 0 then
    vim.notify(label .. " sent", vim.log.levels.INFO)
  else
    vim.notify(label .. " failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
  end
end

local function send_text(label, text)
  vim.system({ "ws", "agent-send", "--stdin", "--label", label }, { text = true, stdin = text }, function(result)
    vim.schedule(function()
      notify_result(label, result)
    end)
  end)
end

function M.selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getregion(start_pos, end_pos, { type = vim.fn.mode() })
  send_text("selection", table.concat(lines, "\n"))
end

function M.diagnostics()
  local diagnostics = vim.diagnostic.get(0)
  if vim.tbl_isempty(diagnostics) then
    vim.notify("No diagnostics in current buffer", vim.log.levels.INFO)
    return
  end

  local items = {}
  local name = vim.api.nvim_buf_get_name(0)
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(items, string.format("%s:%d:%d: %s", name, diagnostic.lnum + 1, diagnostic.col + 1, diagnostic.message))
  end
  send_text("diagnostics", table.concat(items, "\n"))
end

function M.quickfix()
  local items = vim.fn.getqflist()
  if vim.tbl_isempty(items) then
    vim.notify("Quickfix list is empty", vim.log.levels.INFO)
    return
  end

  local rendered = {}
  for _, item in ipairs(items) do
    local file = item.bufnr > 0 and vim.api.nvim_buf_get_name(item.bufnr) or ""
    table.insert(rendered, string.format("%s:%d:%d: %s", file, item.lnum, item.col, item.text))
  end
  send_text("quickfix", table.concat(rendered, "\n"))
end

function M.git_review()
  vim.system({ "ws", "git", "review" }, { text = true }, function(result)
    vim.schedule(function()
      notify_result("git review", result)
    end)
  end)
end

return M
