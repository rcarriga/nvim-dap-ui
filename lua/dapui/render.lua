local M = {}

local util = require("dapui.util")
M.namespace = vim.api.nvim_create_namespace("dapui")

---@class RenderState
---@field lines table
---@field matches table
---@field marks table
local RenderState = {}

---@return RenderState
function RenderState:new()
  local render_state = {lines = {}, matches = {}, marks = {}}
  setmetatable(render_state, self)
  self.__index = self
  return render_state
end

---Add a new line to state
---@param line string
function RenderState:add_line(line) self.lines[#self.lines + 1] = line or "" end

--- Remove the last line from state
function RenderState:remove_line() self.lines[#self.lines] = nil end

---Add a new highlight match to pass to matchaddpos
---@param group string Highlight group
---@param line number Line to add match for
---@param start_col number First column to start match
---@param length number Length of match
function RenderState:add_match(group, line, start_col, length)
  local pos = {line}
  if start_col ~= nil then pos[#pos + 1] = start_col end
  if length ~= nil then pos[#pos + 1] = length end
  self.matches[#self.matches + 1] = {group, pos}
end

function RenderState:add_mark(opts)
  opts = opts or {}
  opts["id"] = #self.marks + 1
  local line = util.pop(opts, "line", self:length())
  local col = util.pop(opts, "col", 0)
  self.marks[#self.marks + 1] = {line = line, col = col, opts = opts}
  return opts["id"]
end

---Get the number of lines in state
function RenderState:length() return #self.lines end

---Get the length of the longest line in state
function RenderState:width()
  local width = 0
  for _, line in pairs(self.lines) do width = width < #line and #line or width end
  return width
end

---Apply a render state to a buffer
---@param state RenderState
---@param buffer number
function M.render_buffer(state, buffer)
  if not state then return end
  if buffer < 0 then return false end
  local win = vim.fn.bufwinnr(buffer)
  if win == -1 then return false end
  local lines = state.lines
  local matches = state.matches
  local marks = state.marks
  vim.fn["clearmatches"](win)
  vim.api.nvim_buf_clear_namespace(buffer, M.namespace, 0, -1)
  vim.api.nvim_buf_set_lines(buffer, 0, #lines, false, lines)
  local last_line = vim.fn.getbufinfo(buffer)[1].linecount
  if last_line > #lines then
    vim.api.nvim_buf_set_lines(buffer, #lines, last_line, false, {})
  end
  for _, match in pairs(matches) do
    vim.fn["matchaddpos"](match[1], {match[2]}, 10, -1, {window = win})
  end
  for _, mark in pairs(marks) do
    vim.api.nvim_buf_set_extmark(
      buffer, M.namespace, mark.line, mark.col, mark.opts
    )
  end
  return true
end

function M.mark_at_line(cur_line, buffer)
  local marks = vim.api.nvim_buf_get_extmarks(
                  buffer or 0, M.namespace, 0, -1, {}
                )
  for _, mark in pairs(marks) do
    local id, line = mark[1], mark[2]
    if cur_line == line then return id end
  end
  return nil
end

--- @return RenderState
function M.new() return RenderState:new() end

return M
