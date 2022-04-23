local dap = require("dap")

local win = nil

---@type Element
return {
  name = "DAP REPL",
  buf_options = { filetype = "dapui_repl" },
  float_defaults = { width = 80, height = 20, enter = true },
  setup = function() end,
  setup_buffer = function(buf)
    dap.repl.close({ mode = "toggle" })
    win = vim.fn.bufwinid(buf)
    local wincmd = "call nvim_set_current_win(" .. tostring(win) .. ")"
    dap.repl.open({}, wincmd)
    vim.fn.setwinvar(win, "&winhl", "Normal:Normal")
    local cur_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(win)
    vim.fn.winrestview({ leftcol = 0 })
    vim.api.nvim_set_current_win(cur_win)
  end,
  render = function() end,
}
