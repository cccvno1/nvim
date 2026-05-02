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
