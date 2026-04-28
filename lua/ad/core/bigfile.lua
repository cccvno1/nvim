local M = {}

M.defaults = {
  size = 1.5 * 1024 * 1024,
  lines = 100000,
  line_length = 1000,
}

local cache = {}
local pending = {}

local function file_size(path)
  if not path or path == "" then
    return 0
  end
  local ok, stat = pcall(vim.uv.fs_stat, path)
  return ok and stat and stat.size or 0
end

local function mark_bigfile(bufnr)
  vim.b[bufnr].bigfile = true
  vim.b[bufnr].completion = false
  vim.b[bufnr].autoformat = false
  vim.b[bufnr].sidekick_nes = false
end

local function sample_average_line_length(bufnr, line_count)
  if line_count <= 0 then
    return 0
  end

  local sample_count = math.min(line_count, 200)
  local step = math.max(math.floor(line_count / sample_count), 1)
  local total = 0
  local seen = 0

  for lnum = 0, line_count - 1, step do
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, lnum, lnum + 1, false)
    local line = ok and lines and lines[1] or ""
    total = total + #line
    seen = seen + 1
    if seen >= sample_count then
      break
    end
  end

  return seen > 0 and (total / seen) or 0
end

local function buffer_metrics(bufnr)
  local lines = math.max(vim.api.nvim_buf_line_count(bufnr), 1)
  if lines > M.defaults.lines then
    return lines, 0
  end
  return lines, sample_average_line_length(bufnr, lines)
end

function M.detect(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  if cache[bufnr] == true then
    mark_bigfile(bufnr)
    return true
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  if file_size(path) > M.defaults.size then
    cache[bufnr] = true
    mark_bigfile(bufnr)
    return true
  end

  return false
end

function M.is_big(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if cache[bufnr] == true then
    return true
  end

  local path = vim.api.nvim_buf_get_name(bufnr)
  local size = file_size(path)
  local lines, average = buffer_metrics(bufnr)
  if size > 0 then
    average = math.max(average, (size - lines) / lines)
  end

  local big = size > M.defaults.size or lines > M.defaults.lines or average > M.defaults.line_length
  if big then
    cache[bufnr] = true
  end
  return big
end

function M.apply(bufnr)
  bufnr = bufnr or 0
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  if not M.is_big(bufnr) then
    return false
  end

  local already_big = vim.b[bufnr].bigfile == true
  mark_bigfile(bufnr)

  vim.api.nvim_buf_call(bufnr, function()
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.list = false
    vim.opt_local.spell = false
    vim.opt_local.swapfile = false
    vim.opt_local.undolevels = -1
    vim.opt_local.statuscolumn = ""
    vim.opt_local.conceallevel = 0
  end)

  pcall(vim.treesitter.stop, bufnr)
  vim.diagnostic.enable(false, { bufnr = bufnr })

  vim.api.nvim_exec_autocmds("User", {
    pattern = "BigFile",
    data = { buf = bufnr },
  })

  if not already_big then
    vim.notify("Big file mode enabled", vim.log.levels.WARN, { title = "Neovim" })
  end
  return true
end

local function schedule_apply(bufnr, delay)
  if not vim.api.nvim_buf_is_valid(bufnr) or pending[bufnr] then
    return
  end
  pending[bufnr] = true
  vim.defer_fn(function()
    pending[bufnr] = nil
    if vim.api.nvim_buf_is_valid(bufnr) then
      M.apply(bufnr)
    end
  end, delay)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ad_bigfile", { clear = true })
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = group,
    callback = function(event)
      M.detect(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(event)
      M.apply(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufWritePost" }, {
    group = group,
    callback = function(event)
      schedule_apply(event.buf, 50)
    end,
  })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    callback = function(event)
      schedule_apply(event.buf, 500)
    end,
  })
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(event)
      cache[event.buf] = nil
      pending[event.buf] = nil
    end,
  })
end

return M
