local config = require("dapui.config")
local util = require("dapui.util")

---@class StackFrames
---@field mark_frame_map table
local StackFrames = {}

function StackFrames:new()
  local elem = { mark_frame_map = {} }
  setmetatable(elem, self)
  self.__index = self
  return elem
end

local function open_frame(frame)
  util.with_session(util.partial(util.jump_to_frame, frame))
end

---@param render_state RenderState
function StackFrames:render(render_state, frames, indent)
  indent = indent or 0
  local visible = vim.tbl_filter(function(frame)
    return frame.presentationHint ~= "subtle"
  end, frames)
  for _, frame in pairs(visible) do
    local line_no = render_state:length() + 1

    local new_line = string.rep(" ", indent)

    render_state:add_match("DapUIFrameName", line_no, #new_line + 1, #frame.name)
    new_line = new_line .. frame.name .. " "

    if frame.source ~= nil then
      local file_name = frame.source.name or frame.source.path or "<unknown>"
      local source_name = util.pretty_name(file_name)
      render_state:add_match("DapUISource", line_no, #new_line + 1, #source_name)
      new_line = new_line .. source_name
    end

    if frame.line ~= nil then
      new_line = new_line .. ":"
      render_state:add_match("DapUILineNumber", line_no, #new_line + 1, #tostring(frame.line))
      new_line = new_line .. frame.line
    end

    render_state:add_line(new_line)
    render_state:add_mapping(config.actions.OPEN, util.partial(open_frame, frame))
  end
end

---@return StackFrames
return function()
  return StackFrames:new()
end
