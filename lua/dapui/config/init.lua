local M = {}

M.elements = {
  BREAKPOINTS = "breakpoints",
  REPL = "repl",
  SCOPES = "scopes",
  STACKS = "stacks",
  WATCHES = "watches",
  HOVER = "hover",
}

M.actions = {
  EXPAND = "expand",
  OPEN = "open",
  REMOVE = "remove",
  EDIT = "edit",
  REPL = "repl",
  TOGGLE = "toggle",
}

M.FLOAT_MAPPINGS = {
  CLOSE = "close",
}

local default_config = {
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    [M.actions.EXPAND] = { "<CR>", "<2-LeftMouse>" },
    [M.actions.OPEN] = "o",
    [M.actions.REMOVE] = "d",
    [M.actions.EDIT] = "e",
    [M.actions.REPL] = "r",
    [M.actions.TOGGLE] = "t",
  },
  sidebar = {
    -- You can change the order of elements in the sidebar
    elements = {
      -- Provide IDs as strings or tables with "id" and "size" keys
      {
        id = M.elements.SCOPES,
        size = 0.25, -- Can be float or integer > 1
      },
      { id = M.elements.BREAKPOINTS, size = 0.25 },
      { id = M.elements.STACKS, size = 0.25 },
      { id = M.elements.WATCHES, size = 0.25 },
    },
    size = 40,
    position = "left", -- Can be "left" or "right"
  },
  tray = {
    elements = { M.elements.REPL },
    size = 10,
    position = "bottom", -- Can be "bottom" or "top"
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      [M.FLOAT_MAPPINGS.CLOSE] = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
}

local user_config = {}

local function fill_elements(area)
  area = vim.deepcopy(area)
  local filled = {}
  for i, element in ipairs(area.elements) do
    if type(element) == "string" then
      filled[i] = { id = element, size = 1 / #area.elements }
    else
      filled[i] = element
    end
  end
  area.elements = filled
  return area
end

local dep_warnings = {}

local function dep_warning(message)
  vim.schedule(function()
    if not dep_warnings[message] then
      dep_warnings[message] = true
      vim.notify(message, "warn", { title = "nvim-dap-ui" })
    end
  end)
end

local function fill_mappings(mappings)
  local filled = {}
  for action, keys in pairs(mappings) do
    filled[action] = type(keys) == "table" and keys or { keys }
  end
  return filled
end

function M.setup(config)
  local filled = vim.tbl_deep_extend("keep", config or {}, default_config)
  filled.mappings = fill_mappings(filled.mappings)
  filled.floating.mappings = fill_mappings(filled.floating.mappings)
  filled.sidebar = fill_elements(filled.sidebar)
  filled.tray = fill_elements(filled.tray)

  user_config = filled
  require("dapui.config.highlights").setup()
end

function M.mappings()
  return user_config.mappings
end

function M.icons()
  return user_config.icons
end

function M.sidebar()
  return user_config.sidebar
end

function M.tray()
  return user_config.tray
end

function M.floating()
  return user_config.floating
end

function M.windows()
  return user_config.windows
end

return M
