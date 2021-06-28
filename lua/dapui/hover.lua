local M = {}
local render = require("dapui.render")
local hover = require("dapui.components.hover")
local state = require("dapui.state")
local HoverElement = {}

local hover_elements = {}

function HoverElement:new(expression)
  local hover_elem = {
    hover_component = hover(expression),
    name = expression,
    render_receivers = {},
  }
  setmetatable(hover_elem, self)
  self.__index = self
  function hover_elem.on_open(buf, render_receiver)
    vim.api.nvim_buf_set_option(buf, "filetype", "dapui_hover")
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    pcall(vim.api.nvim_buf_set_name, buf, M.name)
    hover_elem.render_receivers[buf] = render_receiver
    state.add_watch(expression, "hover")
  end
  function hover_elem.on_close()
    hover_elements[expression] = nil
    state.remove_watch(expression)
  end
  return hover_elem
end

function HoverElement:render()
  local render_state = render.new()
  self.hover_component:render(render_state)
  for buf, reciever in pairs(self.render_receivers) do
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    reciever(render_state)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
  end
end

local function render_elements()
  for _, element in pairs(hover_elements) do element:render() end
end

function M.new(expression)
  local elem = HoverElement:new(expression)
  hover_elements[expression] = elem
  return elem
end

function M.setup() state.on_refresh(render_elements) end

return M
