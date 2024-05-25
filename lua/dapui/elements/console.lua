local nio = require("nio")
local dap = require("dap")
local util = require("dapui.util")

return function()
  local dapui = { elements = {} }

  ---@class dapui.elements.console
  ---@toc_entry Console
  ---@text
  --- The console window used by nvim-dap for the integrated terminal.
  dapui.elements.console = {}

  local console_buf = -1
  local autoscroll = true
  ---@nodoc
  local function get_buf()
    if nio.api.nvim_buf_is_valid(console_buf) then
      return console_buf
    end
    console_buf = util.create_buffer("DAP Console", { filetype = "dapui_console" })()
    if vim.fn.has("nvim-0.7") == 1 then
      vim.keymap.set("n", "G", function()
        autoscroll = true
        vim.cmd("normal! G")
      end, { silent = true, buffer = console_buf })
      nio.api.nvim_create_autocmd({ "InsertEnter", "CursorMoved" }, {
        group = nio.api.nvim_create_augroup("dap-repl-au", { clear = true }),
        buffer = console_buf,
        callback = function()
          local active_buf = nio.api.nvim_win_get_buf(0)
          if active_buf == console_buf then
            local lnum = nio.api.nvim_win_get_cursor(0)[1]
            autoscroll = lnum == nio.api.nvim_buf_line_count(console_buf)
          end
        end,
      })
      nio.api.nvim_buf_attach(console_buf, false, {
        on_lines = function(_, _, _, _, _, _)
          local active_buf = nio.api.nvim_win_get_buf(0)

          if autoscroll and vim.fn.mode() == "n" and active_buf == console_buf then
            vim.cmd("normal! G")
          end
        end,
      })
    end
    return console_buf
  end

  dap.defaults.fallback.terminal_win_cmd = get_buf

  function dapui.elements.console.render() end

  function dapui.elements.console.buffer()
    return get_buf()
  end

  function dapui.elements.console.float_defaults()
    return { width = 80, height = 20, enter = true }
  end

  return dapui.elements.console
end
