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
