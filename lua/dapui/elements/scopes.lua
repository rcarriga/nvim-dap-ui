local scopes

---@type Element
return {
  name = "DAP Scopes",
  buf_options = { filetype = "dapui_scopes" },
  setup = function(state)
    scopes = require("dapui.components.scopes")(state)
  end,
  render = function(canvas)
    scopes:render(canvas)
  end,
}
