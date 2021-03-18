local M = {}

local function init_buf_settings(buf_info)
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
    buf_info.settings or {}
  )
  for key, val in pairs(buf_settings) do
    vim.fn["setbufvar"](buf_info.name, "&" .. key, val)
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

local function open_wins(buffers_info)
  local wins = {}
  for i, buf in pairs(buffers_info) do
    local win = vim.fn["bufwinnr"](buf.name)
    if win == -1 then
      if i == 1 then
        vim.cmd("botright vnew " .. buf.name .. " | vertical resize 60")
      else
        vim.cmd("new " .. buf.name)
      end
      win = vim.fn["bufwinnr"](buf.name)
    end
    init_buf_settings(buf)
    init_win_settings(win)
    wins[i] = win
  end
end

function M.open(buffers_info)
  local cur_win = vim.api.nvim_get_current_win()
  open_wins(buffers_info)
  for _, buf in pairs(buffers_info) do
    buf.on_open()
  end
  vim.api.nvim_set_current_win(cur_win)
end

function M.close(buffers_info)
  for _, buf in pairs(buffers_info) do
    local win = vim.fn.bufwinnr(buf.name)
    if win > -1 then
      vim.cmd(win.."close")
    end
  end
end

return M
