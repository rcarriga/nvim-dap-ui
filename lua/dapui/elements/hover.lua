local state = require("dapui.state")
local hover = require("dapui.components.hover")

---@type Hover
local hover_component = nil

return {
  name = "DAP Hover",
  buf_options = {filetype = "dapui_scopes"},
  render = function(render_state) hover_component:render(render_state) end,
  set_expression = function(expression)
    state.add_watch(expression, "hover")
    hover_component = hover(expression)
  end,
}
