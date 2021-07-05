local state = require("dapui.state")
local Frames = require("dapui.components.frames")

--- @class Threads
--- @field frames StackFrames
local Threads = {}

function Threads:new()
  local elem = {frames = Frames()}
  setmetatable(elem, self)
  self.__index = self
  return elem
end

function Threads:render(render_state)
  local threads = state.threads()
  local stopped = state.stopped_thread() or {}

  local function render_thread(thread, match_group)
    render_state:add_match(match_group, render_state:length() + 1, 1,
                           #thread.name)
    render_state:add_line(thread.name .. ":")
    self.frames:render(render_state, thread.id)
    render_state:add_line()
  end

  if stopped.id then render_thread(stopped, "DapUIStoppedThread") end
  for _, thread in pairs(threads) do
    if thread.id ~= stopped.id then render_thread(thread, "DapUIThread") end
  end
  render_state:remove_line()
end

---@return Threads
return function() return Threads:new() end
