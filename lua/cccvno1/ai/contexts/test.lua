local M = {
  last_output = nil,
  max_lines = 80,
  max_output_bytes = 12000,
}

local function trim_lines(lines, limit)
  if #lines <= limit then
    return lines
  end

  local trimmed = {}
  for i = math.max(#lines - limit + 1, 1), #lines do
    table.insert(trimmed, lines[i])
  end
  table.insert(trimmed, 1, ("... trimmed %d older lines ..."):format(#lines - limit))
  return trimmed
end

local function append_text(lines, text)
  if type(text) == "table" then
    text = table.concat(text, "\n")
  end
  if type(text) ~= "string" or text == "" then
    return
  end

  for line in text:gmatch("([^\n]*)\n?") do
    if line ~= "" then
      table.insert(lines, line)
    end
  end
end

local function read_output_file(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end
  if vim.fn.filereadable(path) ~= 1 then
    return nil
  end

  local ok, stat = pcall(vim.uv.fs_stat, path)
  local offset = 0
  local size = ok and stat and stat.size or 0
  if size > M.max_output_bytes then
    offset = size - M.max_output_bytes
  end

  local fd = vim.uv.fs_open(path, "r", 438)
  if not fd then
    return nil
  end
  local data = vim.uv.fs_read(fd, M.max_output_bytes, offset)
  vim.uv.fs_close(fd)
  if not data or data == "" then
    return nil
  end
  if offset > 0 then
    data = "... trimmed older output ...\n" .. data
  end
  return data
end

local function position_for(client, adapter_id, pos_id)
  if not client or type(client.get_position) ~= "function" then
    return nil
  end

  local ok, tree = pcall(client.get_position, client, nil, { adapter = adapter_id })
  if not ok or not tree or type(tree.get_key) ~= "function" then
    return nil
  end

  local node = tree:get_key(pos_id)
  if not node or type(node.data) ~= "function" then
    return nil
  end
  local ok_data, data = pcall(node.data, node)
  return ok_data and data or nil
end

local function format_position(pos_id, position)
  if not position then
    return pos_id
  end

  local name = position.name or position.id or pos_id
  local path = position.path
  local range = position.range
  if type(path) == "string" and path ~= "" and type(range) == "table" then
    return ("%s (%s:%d)"):format(name, path, (range[1] or 0) + 1)
  elseif type(path) == "string" and path ~= "" then
    return ("%s (%s)"):format(name, path)
  end
  return name
end

function M.set_last_output(output)
  if type(output) == "table" then
    output = table.concat(output, "\n")
  end
  M.last_output = output
end

function M.capture_neotest_results(adapter_id, results, client)
  if type(results) ~= "table" then
    return nil
  end

  local counts = { failed = 0, passed = 0, skipped = 0, other = 0 }
  local failed = {}
  for pos_id, result in pairs(results) do
    local status = type(result) == "table" and result.status or nil
    if status == "failed" then
      counts.failed = counts.failed + 1
      table.insert(failed, { pos_id = pos_id, result = result })
    elseif status == "passed" then
      counts.passed = counts.passed + 1
    elseif status == "skipped" then
      counts.skipped = counts.skipped + 1
    else
      counts.other = counts.other + 1
    end
  end

  table.sort(failed, function(a, b)
    return tostring(a.pos_id) < tostring(b.pos_id)
  end)

  local lines = {
    ("neotest results [%s]: %d failed, %d passed, %d skipped, %d other"):format(
      tostring(adapter_id or "unknown"),
      counts.failed,
      counts.passed,
      counts.skipped,
      counts.other
    ),
  }

  for _, item in ipairs(failed) do
    local result = item.result
    local position = position_for(client, adapter_id, item.pos_id)
    table.insert(lines, "")
    table.insert(lines, "FAILED " .. format_position(item.pos_id, position))

    if type(result.errors) == "table" then
      for _, err in ipairs(result.errors) do
        local msg = type(err) == "table" and err.message or tostring(err)
        if msg and msg ~= "" then
          if type(err) == "table" and err.line then
            table.insert(lines, ("  line %d: %s"):format(err.line + 1, msg))
          else
            table.insert(lines, "  " .. msg)
          end
        end
      end
    end

    append_text(lines, result.short)
    append_text(lines, read_output_file(result.output))
  end

  local output = table.concat(trim_lines(lines, M.max_lines), "\n")
  M.set_last_output(output)
  return output
end

function M.neotest_consumer(client)
  client.listeners.results = function(adapter_id, results, partial)
    if partial then
      return
    end
    pcall(M.capture_neotest_results, adapter_id, results, client)
  end
  return {}
end

function M.render()
  if M.last_output and M.last_output ~= "" then
    return "Recent test output:\n" .. M.last_output
  end
  return "No recent neotest output captured."
end

return M
