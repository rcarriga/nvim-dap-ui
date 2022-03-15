---@class Controls
local Controls = {}

function Controls:new(state)
  local controls = {
    state = state,
  }
  setmetatable(controls, self)
  self.__index = self
  return controls
end

---@param canvas dapui.Canvas
function Controls:render(canvas)
  local line = " Play Pause "
  canvas:add_line(line)
  canvas:add_mapping("expand", function()
    vim.cmd("norm! \\<LeftMouse>")
    local pos = vim.api.nvim_win_get_cursor(0)
    local command = vim.fn.expand("<cword>")
    P({ command, pos })
  end)
end

---@param state UIState
---@return Controls
return function(state)
  return Controls:new(state)
end
