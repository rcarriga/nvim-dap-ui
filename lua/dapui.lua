local M = {}

local listener_id = "dapui"

local elements = {
  STACKS = "stacks",
  SCOPES = "scopes",
  REPL = "repl",
  WATCHES = "watches"
}

local user_config = {
  icons = {
    expanded = "⯆",
    collapsed = "⯈",
    circular = "↺"
  },
  mappings = {
    expand = {"<CR>", "<2-LeftMouse>"},
    open = "o",
    remove = "d",
    edit = "e",
  },
  sidebar = {
    elements = {
      elements.SCOPES,
      elements.STACKS,
      elements.WATCHES
    },
    width = 40,
    position = "left"
  },
  tray = {
    elements = {
      elements.REPL
    },
    height = 10,
    position = "bottom"
  },
  floating = {
    max_height = nil,
    max_width = nil
  },
  windows = {
    indent = 1
  }
}

local function element(name)
  return require("dapui.elements." .. name)
end

local open_float = nil

local function fill_config(config)
  local filled = vim.tbl_deep_extend("keep", config, user_config)
  local mappings = {}
  for action, keys in pairs(filled.mappings) do
    mappings[action] = type(keys) == "table" and keys or {keys}
  end
  filled.mappings = mappings
  return filled
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

function M.eval(expr)
  if not expr then
    if vim.fn.mode() == "v" then
      local start = vim.fn.getpos("v")
      local finish = vim.fn.getpos(".")
      local lines = require("dapui.util").get_selection(start, finish)
      expr = table.concat(lines, "\n")
    else
      expr = expr or vim.fn.expand("<cexpr>")
    end
  end
  require("dapui.hover").eval(expr)
end

function M.setup(config)
  user_config = fill_config(config or {})

  require("dapui.highlights").setup()
  require("dapui.windows.float").setup(user_config.floating)

  for _, module in pairs(elements) do
    element(module).setup(user_config)
  end

  local sidebar_elems = {}
  for _, module in pairs(user_config.sidebar.elements) do
    sidebar_elems[#sidebar_elems + 1] = element(module)
  end
  local tray_elems = {}
  for _, module in pairs(user_config.tray.elements) do
    tray_elems[#tray_elems + 1] = element(module)
  end

  local dap = require("dap")
  dap.listeners.after.event_initialized[listener_id] = function()
    require("dapui.windows").open_tray(tray_elems, user_config.tray.position, user_config.tray.height)
    require("dapui.windows").open_sidebar(sidebar_elems, user_config.sidebar.position, user_config.sidebar.width)
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
