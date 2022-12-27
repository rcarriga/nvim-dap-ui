local async = require("dapui.async")
local dap = require("dap")

return function()
  local dapui = { elements = {} }

  ---@class dapui.elements.repl
  ---@toc_entry Repl
  ---@text
  --- The REPL provided by nvim-dap.
  dapui.elements.repl = {}

  dap.repl.close({ mode = "toggle" })
  local win = vim.api.nvim_open_win(
    0,
    false,
    { relative = "editor", row = 1, col = 1, height = 1, width = 1, style = "minimal" }
  )
  local wincmd = "call nvim_set_current_win(" .. tostring(win) .. ")"
  dap.repl.open({}, wincmd)
  local buf = async.api.nvim_win_get_buf(win)
  async.api.nvim_win_close(win, true)

  ---@nodoc
  function dapui.elements.repl.render() end

  ---@nodoc
  function dapui.elements.repl.buffer()
    return buf
  end

  ---@nodoc
  function dapui.elements.repl.float_defaults()
    return { width = 80, height = 20, enter = true }
  end

  return dapui.elements.repl
end
