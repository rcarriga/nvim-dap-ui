---@class RenderLoop
local M = {}

local Canvas = require("dapui.render.canvas")
local config = require("dapui.config")

M.EVENTS = { RENDER = "render", CLOSE = "close" }

---@class Element
---@field render fun(canvas: dapui.Canvas) Fill a given canvas
---@field name string
---@field buf_options string
---@field dap_after_listeners table<number, string>
---@field setup fun(state: UIState)
---@field setup_buffer fun(buf: number)
---@field float_defaults table

---@class ElementCanvasState
---@field buffers table<number, number>
---@field listeners table<string, table<number, fun(buffer: number)>>
---@field element Element

---@type table <string, ElementCanvasState>
local canvas_states = {}

function M.clear()
  canvas_states = {}
end

---@param element Element
function M.register_element(element)
  canvas_states[element.name] = {
    element = element,
    buffers = {},
    listeners = { [M.EVENTS.RENDER] = {}, [M.EVENTS.CLOSE] = {} },
  }
end

---@param element_name string
---@param buf number
function M.register_buffer(element_name, buf)
  local canvas_state = canvas_states[element_name]
  local element = canvas_state.element
  canvas_state.buffers[#canvas_state.buffers + 1] = buf
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  for opt, val in pairs(element.buf_options or {}) do
    pcall(vim.api.nvim_buf_set_option, buf, opt, val)
  end
  pcall(vim.api.nvim_buf_set_name, buf, element.name)
  if element.setup_buffer then
    element.setup_buffer(buf)
  end
  vim.cmd(
    "autocmd BufDelete <buffer="
      .. buf
      .. "> ++once lua require('dapui.render.loop').remove_buffer('"
      .. element_name
      .. "', "
      .. buf
      .. ")"
  )
end

function M.remove_buffer(element_name, buf_to_remove)
  local canvas_state = canvas_states[element_name]
  canvas_state.buffers = vim.tbl_filter(function(buf)
    return buf_to_remove ~= buf
  end, canvas_state.buffers)
  for _, listener in pairs(canvas_state.listeners[M.EVENTS.CLOSE] or {}) do
    listener(buf_to_remove)
  end
end

---@param element_name string
---@param event string
---@param listener_id string
---@param listener function
function M.register_listener(listener_id, element_name, event, listener)
  canvas_states[element_name].listeners[event][listener_id] = listener
end

function M.unregister_listener(listener_id, element_name, event)
  canvas_states[element_name].listeners[event][listener_id] = nil
end

local function get_elements(names)
  if type(names) == "string" then
    return { names }
  elseif names == nil then
    return vim.tbl_keys(canvas_states)
  end
  return names
end

function M.run(element_names)
  element_names = get_elements(element_names)
  for _, elem_name in pairs(element_names) do
    local canvas_state = canvas_states[elem_name]
    if not vim.tbl_isempty(canvas_state.buffers) then
      local canvas = Canvas.new()
      canvas:set_expand_lines(config.expand_lines())
      canvas_state.element.render(canvas)
      if canvas.valid then
        for _, buf in pairs(canvas_state.buffers) do
          local rendered = Canvas.render_buffer(canvas, buf)
          if rendered then
            for _, listener in pairs(canvas_state.listeners[M.EVENTS.RENDER] or {}) do
              listener(buf, canvas)
            end
          end
        end
      end
    end
  end
end

return M
