local render = require("dapui.render")

---@class WindowLayout
---@field open_wins table<integer, Element>
---@field elements table<integer,Element>
---@field open_index fun(index: number)
local WindowLayout = {}

function WindowLayout:open()
  local cur_win = vim.api.nvim_get_current_win()
  for i, element in pairs(self.elements) do
    local win_id = vim.fn["bufwinid"](element.name)
    if win_id == -1 then
      local buf = vim.api.nvim_create_buf(false, true)
      self.open_index(i)
      win_id = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_buf(buf)
      self.open_wins[win_id] = element
    end
    local bufnr = vim.api.nvim_win_get_buf(win_id)
    render.loop.register_buffer(element.name, bufnr)
    self:_init_win_settings(win_id)
    render.loop.run(element.name)
  end
  vim.api.nvim_set_current_win(cur_win)
end

function WindowLayout:close()
  local current_win = vim.api.nvim_get_current_win()
  for win, _ in pairs(self.open_wins) do
    local win_exists, buf = pcall(vim.api.nvim_win_get_buf, win)
    if win_exists then
      if win == current_win then
        vim.cmd("stopinsert") -- Prompt buffers act poorly when closed in insert mode, see #33
      end
      pcall(vim.api.nvim_win_close, win, true)
      vim.api.nvim_buf_delete(buf, { force = true, unload = false })
    end
  end
  self.open_wins = {}
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
    wrap = false,
  }
  for key, val in pairs(win_settings) do
    vim.api.nvim_win_set_option(win, key, val)
  end
end

function WindowLayout:new(open_index, elements)
  local layout = { elements = elements, open_index = open_index, open_wins = {} }
  setmetatable(layout, self)
  self.__index = self
  return layout
end

---@param open_index fun(index: number)
---@param elements table<integer,Element>
---@return WindowLayout
return function(open_index, elements)
  return WindowLayout:new(open_index, elements)
end
