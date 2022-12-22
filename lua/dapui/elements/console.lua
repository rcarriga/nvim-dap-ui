local async = require("dapui.async")
local dap = require("dap")
local util = require("dapui.util")

return function()
  local dapui = { console = {} }

  local console_buf = -1
  local autoscroll = true
  local function get_buf()
    if async.api.nvim_buf_is_valid(console_buf) then
      return console_buf
    end
    console_buf = util.create_buffer("DAP Console", { filetype = "dapui_console" })
    if vim.fn.has("nvim-0.7") == 1 then
      vim.keymap.set("n", "G", function()
        autoscroll = true
        vim.cmd("normal! G")
      end, { silent = true, buffer = console_buf })
      async.api.nvim_create_autocmd({ "InsertEnter", "CursorMoved" }, {
        group = async.api.nvim_create_augroup("dap-repl-au", { clear = true }),
        buffer = console_buf,
        callback = function()
          local active_buf = async.api.nvim_win_get_buf(0)
          if active_buf == console_buf then
            local lnum = async.api.nvim_win_get_cursor(0)[1]
            autoscroll = lnum == async.api.nvim_buf_line_count(console_buf)
          end
        end,
      })
      async.api.nvim_buf_attach(console_buf, false, {
        on_lines = function(_, _, _, _, _, _)
          if autoscroll and vim.fn.mode() == "n" then
            vim.cmd("normal! G")
          end
        end,
      })
    end
    return console_buf
  end

  dap.defaults.fallback.terminal_win_cmd = function()
    -- TODO: Create a temp window so nvim-dap gets the width and height for the PTY.
    -- Should make this configurable but the neovim terminal doesn't reflow so resizing looks bad.
    -- https://github.com/neovim/neovim/issues/2514
    local win = vim.api.nvim_open_win(get_buf(), true, {
      relative = "editor",
      width = 80,
      height = 20,
      row = 0,
      col = 0,
      border = nil,
      style = "minimal",
    })
    vim.api.nvim_set_current_win(win)
    vim.schedule(function()
      vim.api.nvim_win_close(win, true)
    end)
    return get_buf(), win
  end

  function dapui.console.render() end

  function dapui.console.buffer()
    return get_buf()
  end

  function dapui.console.float_defaults()
    return { width = 80, height = 20, enter = true }
  end

  ---@type dapui.Element
  return dapui.console
end
