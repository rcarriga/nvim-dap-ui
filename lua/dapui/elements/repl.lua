local async = require("dapui.async")
local dap = require("dap")

return function()
  local dapui = { repl = {} }

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

  function dapui.repl.render() end

  function dapui.repl.buffer()
    return buf
  end

  function dapui.repl.float_defaults()
    return { width = 80, height = 20, enter = true }
  end

  ---@type dapui.Element
  return dapui.repl
end
