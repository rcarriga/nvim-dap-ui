local loop = require("dapui.render.loop")
local config = require("dapui.config")
local Frames = require("dapui.components.frames")

---@class Threads
---@field frames StackFrames
---@field state UIState
---@field _subtle_threads table<string, boolean>
local Threads = {}

function Threads:new(state)
  local elem = { frames = Frames(), state = state, _subtle_threads = {} }
  setmetatable(elem, self)
  self.__index = self
  return elem
end

---@param canvas dapui.Canvas
function Threads:render(canvas, indent)
  indent = indent or 0
  local threads = self.state:threads()
  local stopped = self.state:stopped_thread() or {}

  local function render_thread(thread, match_group)
    local first_line = canvas:length()

    canvas:write(thread.name, { group = match_group })
    canvas:write(":\n")
    local frames = self.state:frames(thread.id)
    if not self._subtle_threads[thread.id] then
      frames = vim.tbl_filter(function(frame)
        return frame.presentationHint ~= "subtle"
      end, frames)
    end

    self.frames:render(canvas, frames, indent + config.windows().indent)
    local last_line = canvas:length()

    for line = first_line, last_line, 1 do
      canvas:add_mapping("toggle", function()
        self._subtle_threads[thread.id] = not self._subtle_threads[thread.id]
        loop.run()
      end, { line = line })
    end

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
