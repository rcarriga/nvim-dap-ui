local M = {}

local api = vim.api
local listener_id = "dapui_watch"

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
  if vim.tbl_count(self.expressions) == 0 then
    render_state:add_line("No Expressions")
    render_state:add_match("DapUIWatchesEmpty", render_state:length())
    render_state:add_line()
    return
  end
  render_state:add_line("Expressions:")
  render_state:add_match("DapUIWatchesHeader", render_state:length())
  for i, expr in pairs(self.expressions) do
    local line_no = render_state:length() + 1
    self.line_expr_map[line_no] = i

    local prefix = self.config.icons[#expr.evaluated > 0 and "expanded" or "collapsed"]
    local new_line = " " .. prefix
    render_state:add_match("DapUIDecoration", line_no, 1, 3)

    new_line = new_line .. " " .. expr.value

    render_state:add_line(new_line)

    if #expr.evaluated > 0 then
      local val_prefix = "  Value: "
      render_state:add_match("DapUIWatchesValue", line_no + 1, 1, #val_prefix)
      for j, line in pairs(vim.split(expr.evaluated, "\n")) do
        if j > 1 then
          line = string.rep(" ", #val_prefix) .. line
        else
          line = val_prefix .. line
        end
        render_state:add_line(line)
      end
    end
  end
  render_state:add_line()
end

function Element:should_render(session)
  return session and not vim.tbl_isempty(self.render_receivers)
end

function Element:refresh(session)
  for index, expr in pairs(self.expressions) do
    self:refresh_expr(session, expr)
  end
end

function Element:refresh_expr(session, expr)
  session:request(
    "evaluate",
    {
      expression = expr.value,
      frameId = expr.frame,
      context = "watch"
    },
    function(err, response)
      expr.evaluated = response and response.result or format_error(err)
      self:render(session)
    end
  )
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
        evaluated = response and response.result or format_error(err),
        frame = frame
      }
      self:render(require("dap").session())
    end
  )
end

function _G.watches_toggle_expr()
  local line = vim.fn.line(".")
  local current_expr_i = Element.line_expr_map[line]
  if not current_expr_i then
    return
  end
  local current_expr = Element.expressions[current_expr_i]
  local session = require("dap").session()
  if not session then
    print("No active session to query")
    return
  end
  if #current_expr.evaluated > 0 then
    current_expr.evaluated = ""
    Element:render(session)
  else
    Element:refresh_expr(session, current_expr)
  end
end

function _G.watches_remove_expr()
  local line = vim.fn.line(".")
  local current_expr_i = Element.line_expr_map[line]
  if not current_expr_i then
    return
  end
  Element.expressions[current_expr_i] = nil
  Element:render(require("dap").session())
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
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    Element.config.mappings.expand_expression,
    "<Cmd>call v:lua.watches_toggle_expr()<CR>",
    {}
  )
  vim.api.nvim_buf_set_keymap(
    buf,
    "n",
    Element.config.mappings.remove_expression,
    "<Cmd>call v:lua.watches_remove_expr()<CR>",
    {}
  )
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
  dap.listeners.after.event_stopped[listener_id] = function(session)
    Element:refresh(session)
  end
  dap.listeners.after.event_stopped[listener_id] = function(session)
    Element:refresh(session)
  end
  dap.listeners.before.event_terminated[listener_id] = function()
    Element.expressions = {}
  end
end

function M.on_close(info)
  Element.render_receivers[info.buffer] = nil
end

return M
