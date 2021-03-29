local M = {}

local listener_id = "dapui"

local elements = {
  STACKS = "stacks",
  SCOPES = "scopes"
}

local function fill_config(config)
  return vim.tbl_deep_extend(
    "keep",
    config,
    {
      icons = {
        expanded = "⯆",
        collapsed = "⯈",
        circular = "↺"
      },
      mappings = {
        expand_variable = "<CR>",
      },
      sidebar_elems = {
        elements.SCOPES,
        elements.STACKS,
      },
      collapsed_icon = nil,
      expanded_icon = nil,
      circular_ref_icon = nil,
      open_scopes = true,
      open_stacks = true
    }
  )
end

function M.float_element(elem_name)
  local element = require("dapui."..elem_name)
  require("dapui.windows").open_float(element)
end
function M.setup(config)
  config = fill_config(config or {})
  require("dapui.scopes").setup(config)
  require("dapui.stacks").setup(config)

  local sidebar_elems = {}
  for _, module in pairs(config.sidebar_elems) do
    sidebar_elems[#sidebar_elems + 1] = require("dapui."..module)
  end

  local dap = require("dap")
  dap.listeners.before.event_initialized[listener_id] = function()
    require("dapui.windows").open_sidebar(sidebar_elems)
  end

  dap.listeners.before.event_terminated[listener_id] = function()
    require("dapui.windows").close_sidebar(sidebar_elems)
  end

  dap.listeners.before.event_exited[listener_id] = function()
    require("dapui.windows").close_sidebar(sidebar_elems)
  end
end

return M
