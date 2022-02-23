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

function Threads:render(canvas, indent)
  indent = indent or 0
  local threads = self.state:threads()
  local stopped = self.state:stopped_thread() or {}

  local function render_thread(thread, match_group)
    canvas:write(thread.name, { group = match_group })
    canvas:write(":\n")
    local frames = self.state:frames(thread.id)
    self.frames:render(canvas, frames, indent + config.windows().indent)
    canvas:write("\n\n")
  end

  if stopped.id then
    render_thread(stopped, "DapUIStoppedThread")
  end
  for _, thread in pairs(threads) do
    if thread.id ~= stopped.id then
      render_thread(thread, "DapUIThread")
    end
  end
  canvas:remove_line()
  canvas:remove_line()
end

---@param state UIState
---@return Threads
return function(state)
  return Threads:new(state)
end
