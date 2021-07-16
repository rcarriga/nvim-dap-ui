local _state = nil
local Hover = require("dapui.components.hover")

---@type Hover
local hover_component = nil

return {
  name = "DAP Hover",
  buf_options = { filetype = "dapui_hover" },
  render = function(render_state)
    hover_component:render(render_state)
  end,
  setup = function(state)
    _state = state
  end,
  set_expression = function(expression)
    _state:add_watch(expression, "hover")
    hover_component = Hover(expression, _state)
  end,
}
