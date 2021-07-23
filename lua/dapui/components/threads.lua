local config = require("dapui.config")
local Frames = require("dapui.components.frames")

---@class Threads
---@field frames StackFrames
---@field state UIState
local Threads = {}

function Threads:new(state)
  local elem = { frames = Frames(), state = state }
  setmetatable(elem, self)
  self.__index = self
  return elem
end

function Threads:render(render_state, indent)
  indent = indent or 0
  local threads = self.state:threads()
  local stopped = self.state:stopped_thread() or {}

  local function render_thread(thread, match_group)
    render_state:add_match(match_group, render_state:length() + 1, 1, #thread.name)
    render_state:add_line(thread.name .. ":")
    local frames = self.state:frames(thread.id)
    self.frames:render(render_state, frames, indent + config.windows().indent)
    render_state:add_line()
  end

  if stopped.id then
    render_thread(stopped, "DapUIStoppedThread")
  end
  for _, thread in pairs(threads) do
    if thread.id ~= stopped.id then
      render_thread(thread, "DapUIThread")
    end
  end
  render_state:remove_line()
end

---@param state UIState
---@return Threads
return function(state)
  return Threads:new(state)
end
