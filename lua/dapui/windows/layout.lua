local api = vim.api
local util = require("dapui.util")

---@class dapui.WinState
---@field id string
---@field size number
---@field init_size number

---@class dapui.AreaState
---@field init_size number
---@field size number

---@class dapui.WindowLayout
---@field opened_wins integer[]
---@field win_bufs table<integer, fun(): integer>
---@field win_states table<integer,dapui.WinState>
---@field area_state dapui.AreaState
---@field layout_type "horizontal" | "vertical"
--
---@field open_index fun(index: number): fun(): integer
---@field get_win_size fun(win_id: integer): integer
---@field get_area_size fun(win_id: integer): integer
---@field set_win_size fun(win_id: integer, size: integer)
---@field set_area_size fun(win_id: integer, size: integer)
local WindowLayout = {}

function WindowLayout:open()
  if self:is_open() then
    return
  end
  local cur_win = api.nvim_get_current_win()
  for i, _ in pairs(self.win_states) do
    local get_buffer = self.open_index(i)
    local win_id = api.nvim_get_current_win()
    api.nvim_set_current_buf(get_buffer())
    self.opened_wins[i] = win_id
    self:_init_win_settings(win_id)
    self.win_bufs[win_id] = get_buffer
  end
  self:resize()
  -- Fails if cur win was floating that closed
  pcall(api.nvim_set_current_win, cur_win)
end

function WindowLayout:force_buffers(keep_current)
  local curwin = api.nvim_get_current_win()
  for win, get_buffer in pairs(self.win_bufs) do
    local bufnr = get_buffer()
    local valid, curbuf = pcall(api.nvim_win_get_buf, win)
    if valid and curbuf ~= bufnr then
      if api.nvim_buf_is_loaded(bufnr) and api.nvim_buf_is_valid(bufnr) then
        -- pcall necessary to avoid erroring with `mark not set` although no mark are set
        -- this avoid other issues
        pcall(api.nvim_win_set_buf, win, bufnr)
      end
      if keep_current and curwin == win then
        util.open_buf(curbuf)
      end
    end
  end
end

function WindowLayout:_total_size()
  local total_size = 0
  for _, open_win in ipairs(self.opened_wins) do
    local success, win_size = pcall(self.get_win_size, open_win)
    total_size = total_size + (success and win_size or 0)
  end
  return total_size
end

function WindowLayout:_area_size()
  for _, win in ipairs(self.opened_wins) do
    local success, area_size = pcall(self.get_area_size, win)
    if success then
      return area_size
    end
  end
  return 0
end

function WindowLayout:resize(opts)
  opts = opts or {}
  if opts.reset then
    self.area_state.size = self.area_state.init_size
  end
  if not self:is_open() then
    return
  end

  -- Detecting whether self.area_state.size is a float or int
  if self.area_state.size < 1 then
    if self.layout_type == "vertical" then
      local left = 1
      local right = vim.opt.columns:get()
      self.area_state.size = math.floor((right - left) * self.area_state.size)
    elseif self.layout_type == "horizontal" then
      local top = vim.opt.tabline:get() == "" and 0 or 1
      local bottom = vim.opt.lines:get() - (vim.opt.laststatus:get() > 0 and 2 or 1)
      self.area_state.size = math.floor((bottom - top) * self.area_state.size)
    else
      error("Unknown layout type")
    end
  end

  self.set_area_size(self.opened_wins[1], self.area_state.size)
  local total_size = self:_total_size()
  for i, win_state in pairs(self.win_states) do
    local win_size = opts.reset and win_state.init_size or win_state.size or 1
    win_size = util.round(win_size * total_size)
    if win_size == 0 then
      win_size = 1
    end
    self.set_win_size(self.opened_wins[i], win_size)
  end
end

function WindowLayout:update_sizes()
  if not self:is_open() then
    return
  end
  local area_size = self:_area_size()
  if area_size == 0 then
    return
  end
  self.area_state.size = area_size
  local total_size = self:_total_size()
  for i, win_state in ipairs(self.win_states) do
    local win = self.opened_wins[i]
    local win_exists, _ = pcall(api.nvim_win_get_buf, win)
    if win_exists then
      local success, current_size = pcall(self.get_win_size, self.opened_wins[i])
      if success then
        win_state.size = current_size / total_size
      end
    end
  end
end

function WindowLayout:close()
  local current_win = api.nvim_get_current_win()
  for _, win in pairs(self.opened_wins) do
    local win_exists = api.nvim_win_is_valid(win)

    if win_exists then
      if win == current_win then
        vim.cmd("stopinsert") -- Prompt buffers act poorly when closed in insert mode, see #33
      end
      pcall(api.nvim_win_close, win, true)
    end
  end
  self.opened_wins = {}
end

---@return boolean
function WindowLayout:is_open()
  for _, win in ipairs(self.opened_wins) do
    if pcall(vim.api.nvim_win_get_number, win) then
      return true
    end
  end
  return false
end

function WindowLayout:toggle()
  if self:is_open() then
    self:close()
  else
    self:open()
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
    signcolumn = "auto",
    spell = false,
  }
  for key, val in pairs(win_settings) do
    api.nvim_win_set_option(win, key, val)
  end
  api.nvim_win_call(win, function()
    vim.opt.winhighlight:append({ Normal = "DapUINormal", EndOfBuffer = "DapUIEndOfBuffer" })
  end)
end

function WindowLayout:new(layout)
  layout.opened_wins = {}
  layout.win_bufs = {}
  setmetatable(layout, self)
  self.__index = self
  return layout
end

---@return dapui.WindowLayout
return function(layout)
  return WindowLayout:new(layout)
end
