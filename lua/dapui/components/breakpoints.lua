local util = require("dapui.util")

local BufBreakpoints = require("dapui.components.buf_breakpoints")

---@class Breakpoints
---@field buffer_breakpoints dapui.BufBreakpoints
---@field state UIState
local BreakPoints = {}

function BreakPoints:new(state)
  local elem = { buffer_breakpoints = BufBreakpoints(state), state = state }
  setmetatable(elem, self)
  self.__index = self
  return elem
end

---@param canvas dapui.Canvas
function BreakPoints:render(canvas)
  local current_frame = self.state:current_frame()
  local current_line = 0
  local current_file = ""
  if current_frame and current_frame.source and current_frame.source.path then
    current_file = vim.fn.bufname(current_frame.source.path)
    current_line = current_frame.line
  end
  for buffer, breakpoints in pairs(self.state:breakpoints()) do
    local name = util.pretty_name(vim.fn.bufname(buffer))
    canvas:write(name, { group = "DapUIBreakpointsPath" })
    canvas:write(":\n")
    self.buffer_breakpoints:render(canvas, buffer, breakpoints, current_line, current_file)

    canvas:write("\n\n")
  end
  if canvas:length() > 1 then
    canvas:remove_line()
    canvas:remove_line()
  else
    canvas:write("")
  end
end

---@param state UIState
---@return Breakpoints
local function new(state)
  return BreakPoints:new(state)
end

return new
