local api = vim.api
local util = require("dapui.util")

---@class WinState
---@field id string
---@field size number
---@field element Element

---@class AreaState
---@field size number

---@class WindowLayout
---@field open_wins table<integer, integer>
--
---@field win_states table<integer,WinState>
---@field area_state AreaState
--
---@field open_index fun(index: number)
---@field get_win_size fun(win_id: integer): integer
---@field get_area_size fun(win_id: integer): integer
---@field set_win_size fun(win_id: integer, size: integer, total_size: integer)
---@field set_area_size fun(win_id: integer, size: integer)
--
---@field has_initial_open boolean
---@field loop RenderLoop
local WindowLayout = {}

function WindowLayout:open()
  if self:is_open() then
    return
  end
  local cur_win = api.nvim_get_current_win()
  for i, win_state in pairs(self.win_states) do
    local element = win_state.element
    local bufnr = api.nvim_create_buf(false, true)
    self.open_index(i)
    local win_id = api.nvim_get_current_win()
    api.nvim_set_current_buf(bufnr)
    self.open_wins[i] = win_id
    self.loop.register_buffer(element.name, bufnr)
    self:_init_win_settings(win_id)
    self.loop.run(element.name)
  end
  self:resize()
  api.nvim_set_current_win(cur_win)
  self.has_initial_open = true
end

function WindowLayout:_total_size()
  local total_size = 0
  for _, open_win in pairs(self.open_wins) do
    local success, win_size = pcall(self.get_win_size, open_win)
    total_size = total_size + (success and win_size or 0)
  end
  return total_size
end

function WindowLayout:resize()
  if not self:is_open() then
    return
  end
  self.set_area_size(self.open_wins[1], self.area_state.size)
  local total_size = self:_total_size()
  for i, win_state in pairs(self.win_states) do
    local win_size = win_state.size
    win_size = util.round(win_size * total_size)
    if win_size == 0 then
      win_size = 1
    end
    self.set_win_size(self.open_wins[i], win_size)
  end
end

function WindowLayout:update_sizes()
  if not self:is_open() then
    return
  end
  self.area_state.size = self.get_area_size(self.open_wins[1])
  local total_size = self:_total_size()
  for i, win_state in ipairs(self.win_states) do
    local win = self.open_wins[i]
    local win_exists, _ = pcall(api.nvim_win_get_buf, win)
    if win_exists then
      local current_size = self.get_win_size(self.open_wins[i])
      win_state.size = current_size / total_size
    end
  end
end

function WindowLayout:close()
  local current_win = api.nvim_get_current_win()
  for _, win in pairs(self.open_wins) do
    local win_exists, buf = pcall(api.nvim_win_get_buf, win)

    if win_exists then
      if win == current_win then
        vim.cmd("stopinsert") -- Prompt buffers act poorly when closed in insert mode, see #33
      end
      pcall(api.nvim_win_close, win, true)
      api.nvim_buf_delete(buf, { force = true, unload = false })
    end
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
    api.nvim_win_set_option(win, key, val)
  end
end

function WindowLayout:new(layout)
  layout.open_wins = {}
  setmetatable(layout, self)
  self.__index = self
  return layout
end

---@return WindowLayout
return function(layout)
  return WindowLayout:new(layout)
end
