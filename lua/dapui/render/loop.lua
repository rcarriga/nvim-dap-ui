local M = {}

local render_state = require("dapui.render.state")

M.EVENTS = { RENDER = "render", CLOSE = "close" }

---@class Element
---@field render fun(render: RenderState) Fill a given render state
---@field name string
---@field buf_options string
---@field dap_after_listeners table<number, string>
---@field setup fun(state: UIState)
---@field setup_buffer fun(buf: number)
---@field float_defaults table

---@class Canvas
---@field buffers table<number, number>
---@field listeners table<string, table<number, fun(buffer: number)>>
---@field element Element

---@type table <string, Canvas>
local canvasses = {}

---@param element Element
function M.register_element(element)
  canvasses[element.name] = {
    element = element,
    buffers = {},
    listeners = { [M.EVENTS.RENDER] = {}, [M.EVENTS.CLOSE] = {} },
  }
end

---@param element_name string
---@param buf number
function M.register_buffer(element_name, buf)
  local canvas = canvasses[element_name]
  local element = canvas.element
  canvas.buffers[#canvas.buffers + 1] = buf
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
  local canvas = canvasses[element_name]
  canvas.buffers = vim.tbl_filter(function(buf)
    return buf_to_remove ~= buf
  end, canvas.buffers)
  for _, listener in pairs(canvas.listeners[M.EVENTS.CLOSE] or {}) do
    listener(buf_to_remove)
  end
end

---@param element_name string
---@param event string
---@param listener_id string
---@param listener function
function M.register_listener(listener_id, element_name, event, listener)
  canvasses[element_name].listeners[event][listener_id] = listener
end

function M.unregister_listener(listener_id, element_name, event)
  canvasses[element_name].listeners[event][listener_id] = nil
end

local function get_elements(names)
  if type(names) == "string" then
    return { names }
  elseif names == nil then
    return vim.tbl_keys(canvasses)
  end
  return names
end

function M.run(element_names)
  element_names = get_elements(element_names)
  for _, elem_name in pairs(element_names) do
    local canvas = canvasses[elem_name]
    if not vim.tbl_isempty(canvas.buffers) then
      local state = render_state.new()
      canvas.element.render(state)
      if state.valid then
        for _, buf in pairs(canvas.buffers) do
          local success, _ = pcall(vim.api.nvim_buf_set_option, buf, "modifiable", true)
          if success then
            local rendered = render_state.render_buffer(state, buf)
            vim.api.nvim_buf_set_option(buf, "modifiable", false)
            if rendered then
              for _, listener in pairs(canvas.listeners[M.EVENTS.RENDER] or {}) do
                listener(buf, state)
              end
            end
          end
        end
      else
      end
    end
  end
end

return M
