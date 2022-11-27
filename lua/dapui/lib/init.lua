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
      render()
      async.util.sleep(10)
    end
  end)

  return function()
    pending = true
    render_cond:notify_all()
  end
end

function M.create_buffer(name, options)
  local buf = async.api.nvim_create_buf(false, true)
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
