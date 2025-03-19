local M = {}

local api = vim.api

local util = require("dapui.util")
local config = require("dapui.config")
M.namespace = api.nvim_create_namespace("dapui")

---@class dapui.Canvas
---@field lines table
---@field matches table
---@field mappings table
---@field prompt table
---@field valid boolean
---@field expand_lines boolean
local Canvas = {}

---@type dapui.Action[]
local all_actions = { "expand", "open", "remove", "edit", "repl", "toggle" }

---@return dapui.Canvas
function Canvas:new()
  local mappings = {}
  for _, action in pairs(all_actions) do
    mappings[action] = {}
  end
  local canvas = {
    lines = { "" },
    matches = {},
    mappings = mappings,
    prompt = nil,
    valid = true,
    expand_lines = config.expand_lines,
  }
  setmetatable(canvas, self)
  self.__index = self
  return canvas
end

function Canvas:write(text, opts)
  if type(text) == "table" then
    for _, line in pairs(text) do
      if type(line) == "table" then
        self:write(line[1], line)
      else
        self:write(line)
      end
    end
    return
  end

  if type(text) ~= "string" then
    text = tostring(text)
  end
  opts = opts or {}
  local lines = vim.split(text, "[\r]?\n", { plain = false, trimempty = false })
  if #self.lines == 0 then
    self.lines = { "" }
  end
  for i, line in ipairs(lines) do
    local cur_line = self.lines[#self.lines]
    self.lines[#self.lines] = cur_line .. line
    if opts.group and #line > 0 then
      self.matches[#self.matches + 1] = { opts.group, { #self.lines, #cur_line + 1, #line } }
    end
    if i < #lines then
      table.insert(self.lines, "")
    end
  end
end

function Canvas:line_width(line)
  line = line or self:length()
  return #(self.lines[line] or "")
end

--- Remove the last line from state
function Canvas:remove_line()
  self.lines[#self.lines] = nil
end

function Canvas:reset()
  self.lines = {}
  self.matches = {}
  for _, action in pairs(vim.tbl_keys(self.mappings)) do
    self.mappings[action] = {}
  end
end

---Add a mapping for a specific line
---@param action dapui.Action
---@param callback function Callback for when mapping is used
---@param opts? table Optional extra arguments
-- Extra arguments currently accepts:
--   `line` Line to map to, defaults to last in state
function Canvas:add_mapping(action, callback, opts)
  opts = opts or {}
  local line = opts.line or self:length()
  if line == 0 then
    line = 1
  end
  self.mappings[action][line] = self.mappings[action][line] or {}
  self.mappings[action][line][#self.mappings[action][line] + 1] = callback
end

function Canvas:set_prompt(text, callback, opts)
  opts = opts or {}
  self.prompt = { text = text, callback = callback, fill = opts.fill, enter = opts.enter or false }
end

---Get the number of lines in state
function Canvas:length()
  return #self.lines
end

---Get the length of the longest line in state
function Canvas:width()
  local width = 0
  for _, line in pairs(self.lines) do
    width = width < #line and #line or width
  end
  return width
end

function Canvas:set_expand_lines(value)
  self.expand_lines = value
end

---Apply a render.canvas to a buffer
---@param buffer number
function Canvas:render_buffer(buffer, action_keys)
  local success, _ = pcall(api.nvim_buf_set_option, buffer, "modifiable", true)
  if not success then
    return false
  end

  for action, line_callbacks in pairs(self.mappings) do
    util.apply_mapping(action_keys[action], function(line)
      line = line or vim.fn.line(".")
      local callbacks = line_callbacks[line]
      if not callbacks then
        util.notify("No " .. action .. " action for current line", vim.log.levels.INFO)
        return
      end
      for _, callback in pairs(callbacks) do
        callback()
      end
    end, buffer, action)
  end

  local lines = self.lines
  local matches = self.matches
  api.nvim_buf_clear_namespace(buffer, M.namespace, 0, -1)
  api.nvim_buf_set_lines(buffer, 0, #lines, false, lines)
  local last_line = vim.fn.getbufinfo(buffer)[1].linecount
  if last_line > #lines then
    api.nvim_buf_set_lines(buffer, #lines, last_line, false, {})
  end
  for _, match in pairs(matches) do
    local pos = match[2]
    pcall(
      api.nvim_buf_set_extmark,
      buffer,
      M.namespace,
      pos[1] - 1,
      (pos[2] or 1) - 1,
      { end_col = pos[3] and (pos[2] + pos[3] - 1), hl_group = match[1] }
    )
  end
  if self.expand_lines then
    local group = api.nvim_create_augroup(
      "DAPUIExpandLongLinesFor" .. vim.fn.bufname(buffer):gsub("DAP ", ""),
      { clear = true }
    )
    api.nvim_create_autocmd({ "CursorMoved", "WinScrolled" }, {
      buffer = buffer,
      group = group,
      callback = function()
        vim.schedule(require("dapui.render.line_hover").show)
      end,
    })
  end
  if self.prompt then
    api.nvim_buf_set_option(buffer, "buftype", "prompt")
    vim.fn.prompt_setprompt(buffer, self.prompt.text)
    vim.fn.prompt_setcallback(buffer, function(value)
      vim.cmd("stopinsert")
      self.prompt.callback(value)
    end)
    if self.prompt.fill then
      api.nvim_buf_set_lines(buffer, -1, -1, true, { "> " .. self.prompt.fill })
      if api.nvim_get_current_buf() == buffer then
        api.nvim_input("A")
      end
    end
    api.nvim_buf_set_option(buffer, "modified", false)
    local group = api.nvim_create_augroup("DAPUIPromptSetUnmodified" .. buffer, {})
    api.nvim_create_autocmd({ "ExitPre" }, {
      buffer = buffer,
      group = group,
      callback = function()
        api.nvim_buf_set_option(buffer, "modified", false)
      end,
    })
  else
    api.nvim_buf_set_option(buffer, "modifiable", false)
    api.nvim_buf_set_option(buffer, "buftype", "nofile")
  end
  return true
end

--- @return dapui.Canvas
function M.new()
  return Canvas:new()
end

return M
