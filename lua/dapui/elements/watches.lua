local watches
local name = "DAP Watches"

---@type Element
return {
  name = name,
  buf_options = {
    filetype = "dapui_watches",
    omnifunc = "v:lua.require'dap'.omnifunc",
  },
  setup = function(state)
    watches = require("dapui.components.watches")(state)
  end,
  render = function(canvas)
    watches:render(canvas)
  end,
}
