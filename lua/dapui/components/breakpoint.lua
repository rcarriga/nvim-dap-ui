local M = {}

local config = require("dapui.config")
local util = require("dapui.util")

---@class BufferBreakPoints
---@field mark_breakpoint_map table
---@field expanded_breakpoints table
local BufferBreakPoints = {}

function BufferBreakPoints:new()
  local elem = {mark_breakpoint_map = {}, expanded_breakpoints = {}}
  setmetatable(elem, self)
  self.__index = self
  return elem
end

function BufferBreakPoints:render(render_state, buffer, breakpoints,
                                  current_line, current_file, indent)
  indent = indent or config.windows().indent
  local function is_current_line(bp)
    return bp.line == current_line and bp.file == current_file
  end
  for _, bp in pairs(breakpoints) do
    local line_no = render_state:length() + 1
    local text = vim.api.nvim_buf_get_lines(buffer, bp.line - 1, bp.line, false)
    if text ~= 0 then
      local new_line = string.rep(" ", indent) .. bp.line
      render_state:add_match(
        is_current_line(bp) and "DapUIBreakpointsCurrentLine" or
          "DapUIBreakpointsLine", line_no, indent + 1, #tostring(bp.line)
      )

      new_line = new_line .. " " .. vim.trim(text[1])
      render_state:add_line(new_line)
      self.mark_breakpoint_map[render_state:add_mark()] = bp

      local info_indent = indent + #tostring(bp.line) + 1
      local whitespace = string.rep(" ", info_indent)

      local function add_info(message, data)
        local log_line = whitespace .. message .. " " .. data
        render_state:add_line(log_line)
        render_state:add_match(
          "DapUIBreakpointsInfo", render_state:length(), info_indent, #message
        )
        self.mark_breakpoint_map[render_state:add_mark()] = bp
      end
      if bp.logMessage then add_info("Log Message:", bp.logMessage) end
      if bp.condition then add_info("Condition:", bp.condition) end
      if bp.hitCondition then add_info("Hit Condition:", bp.hitCondition) end
    end
  end
end

function BufferBreakPoints:open_frame(mark_id)
  local current_bp = self.mark_breakpoint_map[mark_id]
  if not current_bp then return end
  util.jump_to_frame(
    {line = current_bp.line, column = 0, source = {path = current_bp.file}}
  )
end

---@return BufferBreakPoints
function M.new() return BufferBreakPoints:new() end

return M
