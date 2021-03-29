local M = {}

vim.cmd("hi default DapUIFloatBorder guifg=#00F1F5")
local float_windows = {}

local function init_buf_settings(element)
  local buf_settings =
    vim.tbl_extend(
    "force",
    {
      buftype = "nofile",
      bufhidden = "hide",
      buflisted = 0,
      swapfile = 0,
      modifiable = 0,
      relativenumber = 0,
      number = 0,
      foldmethod = "expr"
    },
    element.buf_settings or {}
  )
  for key, val in pairs(buf_settings) do
    vim.fn["setbufvar"](element.name, "&" .. key, val)
  end
end

local function init_win_settings(win)
  local win_settings = {
    list = 0,
    winfixwidth = 1
  }
  for key, val in pairs(win_settings) do
    vim.fn["setwinvar"](win, "&" .. key, val)
  end
end

local function open_wins(elements)
  local win_bufnrs = {}
  for i, element in pairs(elements) do
    local win_id = vim.fn["bufwinnr"](element.name)
    if win_id == -1 then
      if i == 1 then
        vim.cmd("botright vnew " .. element.name .. " | vertical resize 60")
      else
        vim.cmd("new " .. element.name)
      end
      win_id = vim.fn["bufwinnr"](element.name)
    end
    init_buf_settings(element)
    init_win_settings(win_id)
    win_bufnrs[#win_bufnrs + 1] = vim.fn.winbufnr(win_id)
  end
  return win_bufnrs
end

function M.open_sidebar(elements)
  local cur_win = vim.api.nvim_get_current_win()
  local bufnrs = open_wins(elements)
  for i, buf in pairs(elements) do
    buf.on_open(
      bufnrs[i],
      function(render_state)
        render_state:render_buffer(bufnrs[i])
      end
    )
  end
  vim.api.nvim_set_current_win(cur_win)
end

function M.open_float(element)
  if float_windows[element.name] then
    float_windows[element.name]:jump_to()
    return
  end
  local float_win =
    require("dapui.windows.float").open_float({height = 1, width = 1, filetype = element.buf_settings.filetype})
  element.on_open(
    float_win:get_buf(),
    function(render_state)
      local rendered = render_state:render_buffer(float_win:get_buf())
      if rendered then
        float_win:resize(render_state:width(), render_state:length())
      end
    end
  )
  vim.cmd("au CursorMoved * ++once lua require('dapui.windows').close_float('" .. element.name .. "')")
  float_windows[element.name] = float_win
  return float_win
end

function M.close_float(element_name)
  if float_windows[element_name] == nil then
    return
  end
  local closed = float_windows[element_name]:close(false)
  if not closed then
    vim.cmd("au CursorMoved * ++once lua require('dapui.windows').close_float('" .. element_name .. "')")
  else
    float_windows[element_name] = nil
  end
end

function M.close_sidebar(buffers_info)
  for _, buf in pairs(buffers_info) do
    local win = vim.fn.bufwinnr(buf.name)
    if win > -1 then
      vim.cmd(win .. "close")
    end
  end
end

return M
