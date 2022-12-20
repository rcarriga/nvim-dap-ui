local async = require("dapui.async")

local M = {}

---@return function
function M.create_render_loop(render)
  local render_cond = async.control.Condvar.new()
  local pending = false

  async.run(function()
    while true do
      if not pending then
        render_cond:wait()
      end
      pending = false
      xpcall(render, function(msg)
        local traceback = debug.traceback(msg, 1)
        M.notify(("Rendering failed: %s"):format(traceback), vim.log.levels.WARN)
      end)
      async.util.sleep(10)
    end
  end)

  return function()
    pending = true
    render_cond:notify_all()
  end
end

function M.notify(msg, level, opts)
  return vim.notify(
    msg,
    level or vim.log.levels.INFO,
    vim.tbl_extend("keep", opts or {}, {
      title = "nvim-dap-ui",
      icon = "",
      on_open = function(win)
        vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(win), "filetype", "markdown")
      end,
    })
  )
end

function M.create_buffer(name, options)
  local buf = async.api.nvim_create_buf(true, true)
  options = vim.tbl_extend("keep", options or {}, {
    modifiable = false,
  })
  async.api.nvim_buf_set_name(buf, name)
  for opt, value in pairs(options) do
    async.api.nvim_buf_set_option(buf, opt, value)
  end
  return buf
end

return M
