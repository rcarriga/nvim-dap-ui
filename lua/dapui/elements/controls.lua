local Controls = require("dapui.components.controls")

---@type Controls
local controls_component = nil

return {
  name = "DAP Controls",
  buf_options = { filetype = "dapui_controls" },
  render = function(canvas)
    controls_component:render(canvas)
  end,
  setup = function(state)
    controls_component = Controls(state)
  end,
  float_defaults = function()
    return {
      row = 0,
      col = vim.opt.columns:get(),
      auto_close = false,
    }
  end,
}
