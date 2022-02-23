local threads

---@type Element
return {
  name = "DAP Stacks",
  buf_options = { filetype = "dapui_stacks" },
  setup = function(state)
    threads = require("dapui.components.threads")(state)
  end,
  render = function(canvas)
    threads:render(canvas)
  end,
}
