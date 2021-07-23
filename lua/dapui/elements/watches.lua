local api = vim.api
local watches
local name = "DAP Watches"

---@type Element
return {
  name = name,
  buf_options = {
    filetype = "dapui_watches",
    buftype = "prompt",
    omnifunc = "v:lua.require'dap'.omnifunc",
  },
  setup = function(state)
    watches = require("dapui.components.watches")(state)
  end,
  setup_buffer = function(buf)
    require("dapui.render.loop").register_listener("watches_modifiable", name, "render", function(b)
      vim.api.nvim_buf_set_option(b, "modifiable", true)
    end)
    api.nvim_buf_attach(buf, false, {
      on_lines = function(b)
        api.nvim_buf_set_option(b, "modified", false)
      end,
      on_changedtick = function(b)
        api.nvim_buf_set_option(b, "modified", false)
      end,
    })
  end,
  render = function(render_state)
    watches:render(render_state)
  end,
}
