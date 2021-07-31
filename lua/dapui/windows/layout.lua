local render = require("dapui.render")
local util = require("dapui.util")

---@class WinState
---@field id string
---@field size number
---@field element Element

---@class WindowLayout
---@field open_wins table<integer, integer>
---@field win_states table<integer,WinState>
---@field open_index fun(index: number)
---@field win_size fun(win_id: integer): integer
---@field resize_win fun(win_id: integer, size: integer, total_size: integer)
---@field has_initial_open boolean
---@field loop RenderLoop
local WindowLayout = {}

function WindowLayout:open()
  local cur_win = vim.api.nvim_get_current_win()
  local total_size = 0
  for i, win_state in pairs(self.win_states) do
    local element = win_state.element
    local bufnr = vim.api.nvim_create_buf(false, true)
    self.open_index(i)
    local win_id = vim.api.nvim_get_current_win()
    if i == 1 then
      -- Account for statuslines
      total_size = self.win_size(win_id) - #self.win_states + 1
    end
    vim.api.nvim_set_current_buf(bufnr)
    self.open_wins[i] = win_id
    self.loop.register_buffer(element.name, bufnr)
    self:_init_win_settings(win_id)
    self.loop.run(element.name)
  end
  for i, win_state in pairs(self.win_states) do
    local win_size = win_state.size
    if not self.has_initial_open and win_size <= 1 then
      win_size = util.round(win_size * total_size)
    end
    self.resize_win(self.open_wins[i], win_size)
  end
  vim.api.nvim_set_current_win(cur_win)
  self.has_initial_open = true
end

function WindowLayout:update_sizes()
  if not self:is_open() then
    return
  end
  for i, win_state in ipairs(self.win_states) do
    local win = self.open_wins[i]
    local win_exists, _ = pcall(vim.api.nvim_win_get_buf, win)
    if win_exists then
      local current_size = self.win_size(self.open_wins[i])
      win_state.size = current_size
    end
  end
end

function WindowLayout:close()
  local current_win = vim.api.nvim_get_current_win()
  for _, win in pairs(self.open_wins) do
    local win_exists, buf = pcall(vim.api.nvim_win_get_buf, win)
    if win_exists then
      if win == current_win then
        vim.cmd("stopinsert") -- Prompt buffers act poorly when closed in insert mode, see #33
      end
    end
    pcall(vim.api.nvim_win_close, win, true)
    vim.api.nvim_buf_delete(buf, { force = true, unload = false })
  end
  self.open_wins = {}
end

---@return boolean
function WindowLayout:is_open()
  return not vim.tbl_isempty(self.open_wins)
end

function WindowLayout:toggle()
  if vim.tbl_isempty(self.open_wins) then
    self:open()
  else
    self:close()
  end
end

function WindowLayout:_init_win_settings(win)
  local win_settings = {
    list = false,
    relativenumber = false,
    number = false,
    winfixwidth = true,
    winfixheight = true,
    wrap = false,
  }
  for key, val in pairs(win_settings) do
    vim.api.nvim_win_set_option(win, key, val)
  end
end

function WindowLayout:new(open_index, win_size, resize_win, win_states, loop)
  local layout = {
    win_states = win_states,
    win_size = win_size,
    resize_win = resize_win,
    open_index = open_index,
    open_wins = {},
    loop = loop,
  }
  setmetatable(layout, self)
  self.__index = self
  return layout
end

---@param open_index fun(index: number)
---@param resize_win fun(win_id: integer, size: integer)
---@param win_size fun(win_id: integer): integer
---@param win_states table<integer,string>
---@param loop RenderLoop
---@return WindowLayout
return function(open_index, win_size, resize_win, win_states, loop)
  return WindowLayout:new(open_index, win_size, resize_win, win_states, loop)
end
