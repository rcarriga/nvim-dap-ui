local M = {}

local config = require("dapui.config")
local state = require("dapui.state")
local util = require("dapui.util")

---@class StackFrames
---@field mark_frame_map table
local StackFrames = {}

function StackFrames:new()
  local elem = {mark_frame_map = {}}
  setmetatable(elem, self)
  self.__index = self
  return elem
end

function StackFrames:render(render_state, thread_id, indent)
  indent = indent or config.windows().indent
  local frames = state.frames(thread_id)
  local visible = vim.tbl_filter(
                    function(frame) return frame.presentationHint ~= "subtle" end,
                    frames
                  )
  for _, frame in pairs(visible) do
    local line_no = render_state:length() + 1

    local new_line = string.rep(" ", indent)

    render_state:add_match("DapUIFrameName", line_no, #new_line + 1, #frame.name)
    new_line = new_line .. frame.name .. " "

    if frame.source ~= nil then
      local file_name = frame.source.name or frame.source.path or "<unknown>"
      local source_name = require("dapui.util").pretty_name(file_name)
      render_state:add_match("DapUISource", line_no, #new_line + 1, #source_name)
      new_line = new_line .. source_name
    end

    if frame.line ~= nil then
      new_line = new_line .. ":"
      render_state:add_match(
        "DapUILineNumber", line_no, #new_line + 1, #tostring(frame.line)
      )
      new_line = new_line .. frame.line
    end

    render_state:add_line(new_line)
    self.mark_frame_map[render_state:add_mark()] = frame
  end
end

function StackFrames:open_frame(mark_id)
  local current_frame = self.mark_frame_map[mark_id]
  if not current_frame then return end
  local session = require("dap").session()
  util.jump_to_frame(current_frame, session)
end

---@return StackFrames
function M.new()
  return StackFrames:new()
end

return M
