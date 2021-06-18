local M = {}

local listener_id = "dapui_repl"

M.name = "DAP REPL"

M.float_defaults = {
  width = 80,
  height = 20,
  enter = true
}

local win = nil

local false_render = {
  render_buffer = function()
    return true
  end
}

function M.on_open(buf, render_receiver)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_repl")
  win = vim.fn.bufwinid(buf)
  local wincmd = "call nvim_set_current_win(" .. tostring(win) .. ")"
  require("dap").repl.open({}, wincmd)
  vim.fn.setwinvar(win, "&winhl", "Normal:Normal")
  local cur_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(win)
  vim.fn.winrestview({leftcol = 0})
  vim.api.nvim_set_current_win(cur_win)
  render_receiver(false_render)
end

function M.on_close()
end

function M.setup()
  local dap = require("dap")
  dap.listeners.before.event_initialized[listener_id] = function()
    if win then
      require("dap").repl.close()
    end
  end
end

return M
