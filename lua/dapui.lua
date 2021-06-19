local M = {}

local listener_id = "dapui"

local elements = {
  BREAKPOINTS = "breakpoints",
  REPL = "repl",
  SCOPES = "scopes",
  STACKS = "stacks",
  WATCHES = "watches"
}

local default_config = {
  icons = {
    expanded = "⯆",
    collapsed = "⯈"
  },
  mappings = {
    expand = {"<CR>", "<2-LeftMouse>"},
    open = "o",
    remove = "d",
    edit = "e"
  },
  sidebar = {
    open_on_start = true,
    elements = {
      elements.SCOPES,
      elements.BREAKPOINTS,
      elements.STACKS,
      elements.WATCHES
    },
    width = 40,
    position = "left"
  },
  tray = {
    open_on_start = true,
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

local user_config = {}
local sidebar_open = true
local tray_open = true

local function element(name)
  return require("dapui.elements." .. name)
end

local open_float = nil

local function fill_config(config)
  local filled = vim.tbl_deep_extend("keep", config, default_config)
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
  for _, name in ipairs(elements) do
    entries[#entries + 1] = tostring(#entries) .. ": " .. name
    elems[#elems + 1] = name
  end
  return elems[vim.fn.inputlist(entries)]
end

function M.float_element(elem_name)
  vim.schedule(
    function()
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

  local dap = require("dap")
  dap.listeners.after.event_initialized[listener_id] = function()
    if user_config.tray.open_on_start then
      M.open("tray")
    end
    if user_config.sidebar.open_on_start then
      M.open("sidebar")
    end
  end

  dap.listeners.before.event_terminated[listener_id] = function()
    M.close()
  end

  dap.listeners.before.event_exited[listener_id] = function()
    M.close()
  end
end

function M.close(component)
  if not component or component == "tray" then
    tray_open = false
    require("dapui.windows").close_tray()
  end
  if not component or component == "sidebar" then
    sidebar_open = false
    require("dapui.windows").close_sidebar()
  end
end

function M.open(component)
  if not component or component == "tray" then
    tray_open = true
    local tray_elems = {}
    for _, module in pairs(user_config.tray.elements) do
      tray_elems[#tray_elems + 1] = element(module)
    end
    require("dapui.windows").open_tray(tray_elems, user_config.tray.position, user_config.tray.height)
  end
  if not component or component == "sidebar" then
    sidebar_open = true
    local sidebar_elems = {}
    for _, module in pairs(user_config.sidebar.elements) do
      sidebar_elems[#sidebar_elems + 1] = element(module)
    end
    require("dapui.windows").open_sidebar(sidebar_elems, user_config.sidebar.position, user_config.sidebar.width)
  end
end

function M.toggle(component)
  if not component then
    M.toggle("tray")
    M.toggle("sidebar")
  end
  if component == "tray" then
    if tray_open then
      M.close(component)
    else
      M.open(component)
    end
  end
  if component == "sidebar" then
    if sidebar_open then
      M.close(component)
    else
      M.open(component)
    end
  end
end

return M
