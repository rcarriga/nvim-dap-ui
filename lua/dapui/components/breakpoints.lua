local M = {}

local state = require("dapui.state")
local util = require("dapui.util")

---@class BreakPoints
---@field buffer_breakpoints BufferBreakPoints
local BreakPoints = {}

---@param buffer_breakpoints BufferBreakPoints
function BreakPoints:new(buffer_breakpoints)
  local elem = {buffer_breakpoints = buffer_breakpoints}
  setmetatable(elem, self)
  self.__index = self
  return elem
end

function BreakPoints:render(render_state)
  local current_frame = state.current_frame()
  local current_line = 0
  local current_file = ""
  if current_frame and current_frame.source then
    current_file = util.pretty_name(current_frame.source.path)
    current_line = current_frame.line
  end
  for buffer, breakpoints in pairs(state.breakpoints()) do
    local name = util.pretty_name(vim.fn.bufname(buffer))
    render_state:add_match(
      "DapUIBreakpointsPath", render_state:length() + 1, 1, #name
    )
    render_state:add_line(name .. ":")
    self.buffer_breakpoints:render(
      render_state, buffer, breakpoints, current_line, current_file
    )

    render_state:add_line()
  end
  render_state:remove_line()
end

---@return BreakPoints
function M.new(buffer_breakpoints) return BreakPoints:new(buffer_breakpoints) end

return M

