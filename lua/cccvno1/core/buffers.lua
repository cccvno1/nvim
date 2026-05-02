local M = {}

local function cmd(name)
  return function()
    vim.cmd(name)
  end
end

M.close = cmd("BufferClose")
M.close_force = cmd("BufferClose!")
M.close_others = cmd("BufferCloseAllButCurrentOrPinned")
M.close_left = cmd("BufferCloseBuffersLeft")
M.close_right = cmd("BufferCloseBuffersRight")
M.pick = cmd("BufferPick")
M.pin = cmd("BufferPin")

function M.find()
  require("fzf-lua").buffers({ sort_mru = true, sort_lastused = true })
end

return M
