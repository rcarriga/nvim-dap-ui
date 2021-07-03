local scopes = require("dapui.components.scopes")()

---@type Element
return {
  name = "DAP Scopes",
  buf_options = {filetype = "dapui_scopes"},
  render = function(render_state) scopes:render(render_state) end,
}
