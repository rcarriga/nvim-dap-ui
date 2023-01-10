local api = vim.api
local dap = require("dap")

local console_buf = -1
local autoscroll = true

local function create_buf()
  console_buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(console_buf, "filetype", "dapui_console")

  if vim.fn.has("nvim-0.7") == 1 then
    vim.keymap.set("n", "G", function()
      autoscroll = true
      vim.cmd("normal! G")
    end, { silent = true, buffer = console_buf })
    api.nvim_create_autocmd({ "InsertEnter", "CursorMoved" }, {
      group = api.nvim_create_augroup("dap-repl-au", { clear = true }),
      buffer = console_buf,
      callback = function()
        local active_buf = api.nvim_win_get_buf(0)
        if active_buf == console_buf then
          local lnum = api.nvim_win_get_cursor(0)[1]
          autoscroll = lnum == api.nvim_buf_line_count(console_buf)
        end
      end,
    })
    api.nvim_buf_attach(console_buf, false, {
      on_lines = function(_, _, _, _, _, _)
        if autoscroll then
          vim.cmd("normal! G")
        end
      end,
    })
  end
end

---@type Element
return {
  name = "DAP Console",
  buf_options = { filetype = "dapui_console" },
  float_defaults = { width = 80, height = 20, enter = true },
  setup = function()
    dap.defaults.fallback.terminal_win_cmd = function()
      if not vim.api.nvim_buf_is_valid(console_buf) then
        create_buf()
      end
      -- TODO: Create a temp window so nvim-dap gets the width and height for the PTY.
      -- Should make this configurable but the neovim terminal doesn't reflow so resizing looks bad.
      -- https://github.com/neovim/neovim/issues/2514
      local win = vim.api.nvim_open_win(console_buf, true, {
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
      return console_buf, win
    end
  end,
  setup_buffer = function(buf)
    if not vim.api.nvim_buf_is_valid(console_buf) then
      create_buf()
    end
    local win = vim.fn.bufwinid(buf)
    vim.api.nvim_win_set_buf(win, console_buf)
    local cur_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(win)
    vim.fn.winrestview({ leftcol = 0 })
    vim.api.nvim_set_current_win(cur_win)
  end,
  render = function() end,
}
