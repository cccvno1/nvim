local M = {}

local function system(args)
  local out = vim.system(args, { text = true }):wait()
  if out.code ~= 0 then
    return ""
  end
  return vim.trim(out.stdout or "")
end

function M.changed()
  local out = system({ "git", "status", "--short" })
  if out == "" then
    return "No git changes."
  end
  return "Git changed files:\n" .. out
end

function M.diff()
  local unstaged_stat = system({ "git", "diff", "--stat", "--", "." })
  local staged_stat = system({ "git", "diff", "--cached", "--stat", "--", "." })
  local unstaged_diff = system({ "git", "diff", "--", "." })
  local staged_diff = system({ "git", "diff", "--cached", "--", "." })

  if unstaged_diff == "" and staged_diff == "" then
    return "No git diff."
  end

  local diff = table.concat({
    "Unstaged diff:",
    unstaged_diff ~= "" and unstaged_diff or "No unstaged diff.",
    "",
    "Staged diff:",
    staged_diff ~= "" and staged_diff or "No staged diff.",
  }, "\n")

  local limit = 60000
  if #diff > limit then
    diff = diff:sub(1, limit) .. "\n\n[diff truncated at " .. limit .. " characters]"
  end

  return table.concat({
    "Git diff stat:",
    "Unstaged:",
    unstaged_stat ~= "" and unstaged_stat or "No unstaged diff stat.",
    "",
    "Staged:",
    staged_stat ~= "" and staged_stat or "No staged diff stat.",
    "",
    "Git diff:",
    diff,
  }, "\n")
end

return M
