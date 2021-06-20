local M = {}

M.elements = {
  BREAKPOINTS = "breakpoints",
  REPL = "repl",
  SCOPES = "scopes",
  STACKS = "stacks",
  WATCHES = "watches"
}

local default_config = {
  icons = {
    expanded = "▾",
    collapsed = "▸"
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
      M.elements.SCOPES,
    },
    width = 40,
    position = "left"
  },
  tray = {
    open_on_start = true,
    elements = {
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

function M.setup(config)
  local filled = vim.tbl_deep_extend("keep", config, default_config)
  local mappings = {}
  for action, keys in pairs(filled.mappings) do
    mappings[action] = type(keys) == "table" and keys or {keys}
  end
  filled.mappings = mappings
  user_config = filled
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
