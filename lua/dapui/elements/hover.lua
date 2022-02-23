local _state = nil
local Hover = require("dapui.components.hover")

---@type Hover
local hover_component = nil

return {
  name = "DAP Hover",
  buf_options = { filetype = "dapui_hover" },
  render = function(canvas)
    hover_component:render(canvas)
  end,
  setup = function(state)
    _state = state
  end,
  set_expression = function(expression, context)
    _state:add_watch(expression, context or "hover")
    hover_component = Hover(expression, _state)
  end,
}
