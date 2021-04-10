local M = {}

local listener_id = "dapui"

require("dapui.highlights")

local elements = {
  STACKS = "stacks",
  SCOPES = "scopes",
  REPL = "repl",
  WATCHES = "watches"
}

local function element(name)
  return require("dapui.elements." .. name)
end

local open_float = nil

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
        jump_to_frame = "<CR>",
        expand_expression = "<CR>",
        remove_expression = "d"
      },
      sidebar = {
        elements = {
          elements.SCOPES,
          elements.STACKS,
          elements.WATCHES
        },
        width = 60,
        position = "left"
      },
      tray = {
        elements = {
        },
        height = 10,
        position = "top"
      }
    }
  )
end

local function query_elem_name()
  if open_float then
    return open_float
  end
  local entries = {"Select an element:"}
  local elems = {}
  for _, name in pairs(elements) do
    entries[#entries + 1] = tostring(#entries) .. ": " .. name
    elems[#elems + 1] = name
  end
  return elems[vim.fn.inputlist(entries)]
end

function M.float_element(elem_name)
  local line_no = vim.fn.screenrow()
  local col_no = vim.fn.screencol()
  local position = {line = line_no, col = col_no}
  elem_name = elem_name or query_elem_name()
  if not elem_name then
    return
  end
  open_float = elem_name
  local elem = element(elem_name)
  local win = require("dapui.windows").open_float(elem, position, elem.float_defaults or {})
  win:listen(
    "close",
    function()
      open_float = nil
    end
  )
end

function M.setup(config)
  config = fill_config(config or {})
  for _, module in pairs(elements) do
    element(module).setup(config)
  end

  local sidebar_elems = {}
  for _, module in pairs(config.sidebar.elements) do
    sidebar_elems[#sidebar_elems + 1] = element(module)
  end
  local tray_elems = {}
  for _, module in pairs(config.tray.elements) do
    tray_elems[#tray_elems + 1] = element(module)
  end

  local dap = require("dap")
  dap.listeners.after.event_initialized[listener_id] = function()
    require("dapui.windows").open_tray(tray_elems, config.tray.position, config.tray.height)
    require("dapui.windows").open_sidebar(sidebar_elems, config.sidebar.position, config.sidebar.width)
  end

  dap.listeners.before.event_terminated[listener_id] = function()
    require("dapui.windows").close_tray(tray_elems)
    require("dapui.windows").close_sidebar(sidebar_elems)
  end

  dap.listeners.before.event_exited[listener_id] = function()
    require("dapui.windows").close_tray(tray_elems)
    require("dapui.windows").close_sidebar(sidebar_elems)
  end
end

return M
