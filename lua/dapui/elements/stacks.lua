local threads = require("dapui.components.threads")()

---@type Element
return {
  name = "DAP Stacks",
  buf_options = {filetype = "dapui_stacks"},
  render = function(render_state) threads:render(render_state) end,
}
