local M = {}

local _mappings = {}
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
---@field expand_lines table
local Canvas = {}

---@return dapui.Canvas
function Canvas:new()
  local mappings = {}
  for _, action in pairs(config.actions) do
    mappings[action] = {}
  end
  local canvas = {
    lines = { "" },
    matches = {},
    mappings = mappings,
    prompt = nil,
    valid = true,
    expand_lines = false,
  }
  setmetatable(canvas, self)
  self.__index = self
  return canvas
end

-- Used by components waiting on state update to render.
-- This is to avoid flickering updates as information is updated.
function Canvas:invalidate()
  self.valid = false
end

function Canvas:write(text, opts)
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
  for _, action in pairs(config.actions) do
    self.mappings[action] = {}
  end
end

---Add a new highlight match to pass to matchaddpos
---@param group string Highlight group
---@param line number Line to add match for
---@param start_col number First column to start match
---@param length number Length of match
function Canvas:add_match(group, line, start_col, length)
  local pos = { line }
  if start_col ~= nil then
    pos[#pos + 1] = start_col
  end
  if length ~= nil then
    pos[#pos + 1] = length
  end
  self.matches[#self.matches + 1] = { group, pos }
end

---Add a mapping for a specific line
---@param action string Name of mapping action to use key for
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
---@param state dapui.Canvas
---@param buffer number
function M.render_buffer(state, buffer)
  local success, _ = pcall(api.nvim_buf_set_option, buffer, "modifiable", true)
  if not success then
    return false
  end
  local win = vim.fn.bufwinnr(buffer)
  if win == -1 then
    return false
  end

  _mappings[buffer] = state.mappings
  for action, _ in pairs(state.mappings) do
    util.apply_mapping(
      config.mappings()[action],
      "<cmd>lua require('dapui.render.canvas')._mapping('" .. action .. "')<CR>",
      buffer
    )
  end

  local lines = state.lines
  local matches = state.matches
  api.nvim_buf_clear_namespace(buffer, M.namespace, 0, -1)
  api.nvim_buf_set_lines(buffer, 0, #lines, false, lines)
  local last_line = vim.fn.getbufinfo(buffer)[1].linecount
  if last_line > #lines then
    api.nvim_buf_set_lines(buffer, #lines, last_line, false, {})
  end
  for _, match in pairs(matches) do
    local pos = match[2]
    api.nvim_buf_set_extmark(
      buffer,
      M.namespace,
      pos[1] - 1,
      (pos[2] or 1) - 1,
      { end_col = pos[3] and (pos[2] + pos[3] - 1), hl_group = match[1] }
    )
  end
  if state.expand_lines then
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
  if state.prompt then
    api.nvim_buf_set_option(buffer, "buftype", "prompt")
    vim.fn.prompt_setprompt(buffer, state.prompt.text)
    vim.fn.prompt_setcallback(buffer, function(value)
      vim.cmd("stopinsert")
      state.prompt.callback(value)
    end)
    if state.prompt.fill then
      vim.cmd("normal i" .. state.prompt.fill)
      api.nvim_input("A")
    end
    api.nvim_buf_set_option(buffer, "modified", false)
    api.nvim_buf_set_keymap(
      buffer,
      "i",
      "<BS>",
      "<cmd>lua require('dapui.render.canvas')._prompt_backspace()<CR>",
      { noremap = true }
    )
    vim.cmd("augroup DAPUIPromptSetUnmodified" .. buffer)
    vim.cmd(
      "autocmd ExitPre <buffer="
        .. buffer
        .. "> call nvim_buf_set_option("
        .. buffer
        .. ", 'modified', v:false)"
    )
    vim.cmd("augroup END")
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

function M._mapping(action)
  local buffer = api.nvim_get_current_buf()
  local line = vim.fn.line(".")
  local callbacks = _mappings[buffer][action][line]
  if not callbacks then
    vim.notify("No " .. action .. " action for current line", "INFO")
    return
  end
  for _, callback in pairs(callbacks) do
    callback()
  end
end

function M._prompt_backspace()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cur_line = cursor[1]
  local cur_col = cursor[2]
  local prompt_length = vim.str_utfindex(vim.fn["prompt_getprompt"]("%"))

  if cur_col ~= prompt_length then
    vim.api.nvim_buf_set_text(0, cur_line - 1, cur_col - 1, cur_line - 1, cur_col, { "" })
    vim.api.nvim_win_set_cursor(0, { cur_line, cur_col - 1 })
  end
end

return M
