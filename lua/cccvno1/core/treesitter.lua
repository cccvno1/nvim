local M = {}

M.parsers = {
  "bash",
  "c",
  "cpp",
  "go",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

function M.missing()
  local missing = {}
  for _, parser in ipairs(M.parsers) do
    if not pcall(vim.treesitter.language.inspect, parser) then
      table.insert(missing, parser)
    end
  end
  return missing
end

return M
