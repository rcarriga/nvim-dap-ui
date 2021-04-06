local M = {}

local api = vim.api
local listener_id = "dapui_watch"

-- Expr = {value: str, evaluated: str, frame_id: number}

local Element = {
  config = {},
  render_receivers = {},
  current_frame_id = nil,
  expressions = {},
  line_expr_map = {}
}

local function format_error(error)
  if not error.body then
    return error.message
  end
  local formatted = error.body.error.format
  for name, val in pairs(error.body.error.variables) do
    formatted = string.gsub(formatted, "{" .. name .. "}", val)
  end
  return formatted
end

function Element:fill_render_state(render_state)
  for _, expr in ipairs(self.expressions) do
    local indent = #expr.value + 2
    for i, line in pairs(vim.split(expr.evaluated, "\n")) do
      if i > 1 then
        line = string.rep(" ", indent) .. line
        render_state:add_line(line)
      else
        render_state:add_line(expr.value .. ": " .. line)
      end
    end
  end
  render_state:add_line()
end

function Element:should_render(session)
  return session and session.current_frame and not vim.tbl_isempty(self.render_receivers)
end

function Element:refresh_values(session)
  for _, expr in pairs(self.expressions) do
    session:request(
      "evaluate",
      {
        expression = expr.value,
        frameId = expr.frame,
        context = "watch"
      },
      function(err, response)
        expr.evaluated = err and format_error(err) or response.result
        self:render(session)
      end
    )
  end
end

function Element:evaluate(session, expr)
  local frame = session.current_frame.id
  session:request(
    "evaluate",
    {
      expression = expr,
      frameId = frame,
      context = "watch"
    },
    function(err, response)
      self.expressions[#self.expressions + 1] = {
        value = expr,
        evaluated = err and format_error(err.body) or response.result,
        frame = frame
      }
      self:render(require("dap").session())
    end
  )
end

local function add_watch(value)
  if value == "" then
    Element:render(require("dap").session())
    return
  end
  vim.cmd("stopinsert")
  local session = require("dap").session()
  Element:evaluate(session, value)
end

function Element:render(session)
  if not self:should_render(session) then
    return
  end
  local render_state = require("dapui.render").init_state()
  self:fill_render_state(render_state)
  for _, reciever in pairs(self.render_receivers) do
    reciever(render_state)
  end
end

function M.setup(user_config)
  Element.config = user_config
end

M.name = "DAP Watches"

function M.on_open(buf, render_receiver)
  vim.fn.prompt_setcallback(buf, add_watch)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_watches")
  vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
  pcall(vim.api.nvim_buf_set_name, buf, M.name)
  vim.cmd("autocmd InsertEnter <buffer=" .. buf .. "> call prompt_setprompt(" .. buf .. ", 'New Expression: ')")
  Element.render_receivers[buf] = render_receiver
  vim.api.nvim_buf_attach(
    buf,
    false,
    {
      on_lines = function(b)
        api.nvim_buf_set_option(b, "modified", false)
      end,
      on_changedtick = function(b)
        api.nvim_buf_set_option(b, "modified", false)
      end
    }
  )
  Element:render(require("dap").session())

  local dap = require("dap")
  dap.listeners.after.event_stopped[listener_id] = function(session, response)
    Element:refresh_values(session)
  end
  dap.listeners.after.event_stopped[listener_id] = function(session, response)
    Element:refresh_values(session)
  end
  dap.listeners.before.event_terminated[listener_id] = function()
    Element.expressions = {}
  end
end

function M.on_close(info)
  Element.render_receivers[info.buffer] = nil
end

return M
