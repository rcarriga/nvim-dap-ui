local util = require("dapui.util")

local BufBreakpoints = require("dapui.components.buf_breakpoints")

---@class Breakpoints
---@field buffer_breakpoints BufBreakpoints
---@field state UIState
local BreakPoints = {}

function BreakPoints:new(state)
  local elem = {buffer_breakpoints = BufBreakpoints(), state = state}
  setmetatable(elem, self)
  self.__index = self
  return elem
end

function BreakPoints:render(render_state)
  local current_frame = self.state:current_frame()
  local current_line = 0
  local current_file = ""
  if current_frame and current_frame.source and current_frame.source.path then
    current_file = vim.fn.bufname(current_frame.source.path)
    current_line = current_frame.line
  end
  for buffer, breakpoints in pairs(self.state:breakpoints()) do
    local name = util.pretty_name(vim.fn.bufname(buffer))
    render_state:add_match("DapUIBreakpointsPath", render_state:length() + 1, 1,
                           #name)
    render_state:add_line(name .. ":")
    self.buffer_breakpoints:render(render_state, buffer, breakpoints,
                                   current_line, current_file)

    render_state:add_line()
  end
  render_state:remove_line()
end

---@param state UIState
---@return Breakpoints
local function new(state) return BreakPoints:new(state) end

return new
