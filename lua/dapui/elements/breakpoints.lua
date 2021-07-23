local breakpoints = nil
---@type Element
return {
  name = "DAP Breakpoints",
  buf_options = { filetype = "dapui_breakpoints" },
  setup = function(state)
    breakpoints = require("dapui.components.breakpoints")(state)
  end,
  render = function(render_state)
    breakpoints:render(render_state)
  end,
  dap_after_listeners = {
    "setBreakpoints",
    "setFunctionBreakpoints",
    "setInstructionBreakpoints",
    "setDataBreakpoints",
    "stackTrace",
  },
}
