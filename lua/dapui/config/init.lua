local dapui = {}

---@tag dapui.config
---@toc_entry Configuration Options

---@class dapui.Config
---@field icons dapui.Config.icons
---@field mappings table<dapui.Action, string|string[]> Keys to trigger actions in elements
---@field element_mappings table<string, table<dapui.Action, string|string[]>> Per-element overrides of global mappings
---@field expand_lines boolean Expand current line to hover window if larger
--- than window size
---@field force_buffers boolean Prevents other buffers being loaded into
--- nvim-dap-ui windows
---@field layouts dapui.Config.layout[] Layouts to display elements within.
--- Layouts are opened in the order defined
---@field floating dapui.Config.floating Floating window specific options
---@field controls dapui.Config.controls Controls configuration
---@field render dapui.Config.render Rendering options which can be updated
--- after initial setup
---@field select_window? fun(): integer A function which returns a window to be
--- used for opening buffers such as a stack frame location.

---@class dapui.Config.icons
---@field expanded string
---@field collapsed string
---@field current_frame string

---@class dapui.Config.layout
---@field elements string[]|dapui.Config.layout.element[] Elements to display
--- in this layout
---@field size number Size of the layout in lines/columns
---@field position "left"|"right"|"top"|"bottom" Which side of editor to open
--- layout on

---@class dapui.Config.layout.element
---@field id string Element ID
---@field size number Size of the element in lines/columns or as proportion of
--- total editor size (0-1)

---@class dapui.Config.floating
---@field max_height? number Maximum height of floating window (integer or float
--- between 0 and 1)
---@field max_width? number Maximum width of floating window (integer or float
--- between 0 and 1)
---@field border string|string[] Border argument supplied to `nvim_open_win`
---@field mappings table<dapui.FloatingAction, string|string[]> Keys to trigger
--- actions in elements

---@class dapui.Config.controls
---@field enabled boolean Show controls on an element (requires winbar feature)
---@field element string Element to show controls on
---@field icons dapui.Config.controls.icons

---@class dapui.Config.controls.icons
---@field pause string
---@field play string
---@field step_into string
---@field step_over string
---@field step_out string
---@field step_back string
---@field run_last string
---@field terminate string

---@class dapui.Config.render
---@field indent integer Default indentation size
---@field max_type_length? integer Maximum number of characters to allow a type
--- name to fill before trimming
---@field max_value_lines? integer Maximum number of lines to allow a value to
--- fill before trimming
---@field sort_variables? fun(a: dapui.types.Variable, b: dapui.types.Variable):boolean Sorting function to determine
--- render order of variables.

---@alias dapui.Action "expand"|"open"|"remove"|"edit"|"repl"|"toggle"

---@alias dapui.FloatingAction "close"

---@type dapui.Config
---@nodoc
local default_config = {
  icons = { expanded = "", collapsed = "", current_frame = "" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  element_mappings = {},
  expand_lines = vim.fn.has("nvim-0.7") == 1,
  force_buffers = true,
  layouts = {
    {
      -- You can change the order of elements in the sidebar
      elements = {
        -- Provide IDs as strings or tables with "id" and "size" keys
        {
          id = "scopes",
          size = 0.25, -- Can be float or integer > 1
        },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 40,
      position = "left", -- Can be "left" or "right"
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 10,
      position = "bottom", -- Can be "bottom" or "top"
    },
  },
  floating = {
    max_height = nil,
    max_width = nil,
    border = "single",
    mappings = {
      ["close"] = { "q", "<Esc>" },
    },
  },
  controls = {
    enabled = vim.fn.exists("+winbar") == 1,
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "",
      terminate = "",
      disconnect = "",
    },
  },
  render = {
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100, -- Can be integer or nil.
    indent = 1,
  },
}

local user_config = default_config

local function fill_elements(area)
  area = vim.deepcopy(area)
  local filled = {}
  vim.validate({
    size = { area.size, "number" },
    elements = { area.elements, "table" },
    position = { area.position, "string" },
  })
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

local function fill_mappings(mappings)
  local filled = {}
  for action, keys in pairs(mappings) do
    filled[action] = type(keys) == "table" and keys or { keys }
  end
  return filled
end

---@class dapui.config : dapui.Config
---@nodoc
dapui.config = {}

function dapui.config.setup(config)
  config = config or {}
  local filled = vim.tbl_deep_extend("keep", config, default_config)

  if config.layouts then
    filled.layouts = config.layouts
  end
  filled.mappings = fill_mappings(filled.mappings)

  local element_mappings = {}
  for elem, mappings in pairs(filled.element_mappings) do
    element_mappings[elem] = fill_mappings(mappings)
  end

  filled.element_mappings = element_mappings
  filled.floating.mappings = fill_mappings(filled.floating.mappings)
  for i, layout in ipairs(filled.layouts) do
    filled.layouts[i] = fill_elements(layout)
  end

  user_config = filled
  require("dapui.config.highlights").setup()
end

function dapui.config._format_default()
  local lines = { "Default values:", ">lua" }
  for line in vim.gsplit(vim.inspect(default_config), "\n", true) do
    table.insert(lines, "  " .. line)
  end
  table.insert(lines, "<")
  return lines
end

---@param update dapui.Config.render
---@nodoc
function dapui.config.update_render(update)
  user_config.render = vim.tbl_deep_extend("keep", update, user_config.render)
end

function dapui.config.element_mapping(element)
  return vim.tbl_extend("keep", user_config.element_mappings[element] or {}, user_config.mappings)
end

setmetatable(dapui.config, {
  __index = function(_, key)
    return user_config[key]
  end,
})

dapui.config.setup()

return dapui.config
