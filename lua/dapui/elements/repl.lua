local M = {}
local Repl = {}

local listener_id = "dapui_repl"

M.name = "DAP REPL"

M.buf_settings = {
  filetype = "dapui_repl"
}

M.float_defaults = {
  width = 80,
  height = 20,
  enter = true
}

local win = nil

local false_render = {
  render_buffer = function ()
    return true
  end
}

function M.on_open(buf, render_receiver)
  win = vim.fn.bufwinid(buf)
  local wincmd = "call nvim_set_current_win("..tostring(win)..")"
  require("dap").repl.open({}, wincmd)
  vim.fn.setwinvar(win, "&winhl", "Normal:Normal")
  render_receiver(false_render)
end

function M.on_close()
  -- require("dap").repl.close()
end

function M.setup(user_config)
  local dap = require("dap")
  dap.listeners.before.event_initialized[listener_id] = function()
    if win then
      require("dap").repl.close()
    end
  end
end

return M
