local M = {}

local config = require("dapui.config")
local api = vim.api
local listener_id = "dapui_watch"

local Element = {
  render_receivers = {},
  expressions = {},
  line_expr_map = {},
  mode = "new"
}

local function format_error(error)
  if vim.tbl_isempty(error.body or {}) then
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

    local prefix = config.icons()[expr.expanded and "expanded" or "collapsed"]
    local new_line = string.rep(" ", config.windows().indent) .. prefix
    render_state:add_match("DapUIDecoration", line_no, config.windows().indent, 3)

    new_line = new_line .. " " .. expr.value

    render_state:add_line(new_line)

    if expr.expanded then
      local indent = string.rep(" ", config.windows().indent * 2)
      local val_line = line_no + 1
      local val_prefix
      if expr.error then
        val_prefix = indent .. "Error: "
        render_state:add_match("DapUIWatchesError", val_line, 1, #val_prefix)
      else
        val_prefix = indent .. "Value: "
        render_state:add_match("DapUIWatchesValue", val_line, 1, #val_prefix)
      end
      for j, line in pairs(vim.split(expr.evaluated, "\n")) do
        self.line_expr_map[val_line + j - 1] = i
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
  if not session.current_frame then
    return
  end
  session:request(
    "evaluate",
    {
      expression = expr.value,
      frameId = session.current_frame.id,
      context = "watch"
    },
    function(err, response)
      expr.evaluated = response and response.result or format_error(err)
      expr.error = err and true
      self:render(session)
    end
  )
end

function Element:evaluate(session, expr)
  local frame = session.current_frame
  session:request(
    "evaluate",
    {
      expression = expr,
      frameId = frame.id,
      context = "watch"
    },
    function(err, response)
      self.expressions[#self.expressions + 1] = {
        value = expr,
        evaluated = response and response.result or format_error(err),
        error = err and true,
        expanded = true
      }
      self:render(require("dap").session())
    end
  )
end

function M.toggle_expr()
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
  current_expr.expanded = not current_expr.expanded
  Element:render(session)
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

function M.edit_expr()
  local line = vim.fn.line(".")
  Element.mode = "edit"
  local current_expr_i = Element.line_expr_map[line]
  if not current_expr_i then
    return
  end
  local current_expr = Element.expressions[current_expr_i]
  local frame = require("dap").session().current_frame
  vim.cmd("normal i" .. current_expr.value)
  local buf = api.nvim_win_get_buf(0)
  vim.fn.prompt_setcallback(buf, add_watch)
  local function edit_watch(value)
    vim.cmd("stopinsert")
    if value ~= "" then
      Element.mode = "new"
      local session = require("dap").session()
      session:request(
        "evaluate",
        {
          expression = value,
          frameId = frame.id,
          context = "watch"
        },
        function(err, response)
          Element.expressions[current_expr_i] = {
            value = value,
            evaluated = response and response.result or format_error(err),
            error = err and true,
            expanded = true
          }
          vim.cmd("normal " .. line .. "gg")
          Element:render(session)
        end
      )
    end
  end
  vim.fn.prompt_setcallback(buf, edit_watch)
  vim.cmd("startinsert")
end

function M.remove_expr()
  local line = vim.fn.line(".")
  local current_expr_i = Element.line_expr_map[line]
  if not current_expr_i then
    return
  end
  Element.expressions[current_expr_i] = nil
  Element:render(require("dap").session())
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

function M.setup()
end

function M.set_prompt(buf)
  if Element.mode == "new" then
    vim.fn.prompt_setprompt(buf, "New Expression: ")
  else
    vim.fn.prompt_setprompt(buf, "Edit Expression: ")
  end
end

M.name = "DAP Watches"

function M.on_open(buf, render_receiver)
  vim.fn.prompt_setcallback(buf, add_watch)
  vim.api.nvim_buf_set_option(buf, "filetype", "dapui_watches")
  vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
  vim.api.nvim_buf_set_option(buf, "omnifunc", "v:lua.require'dap'.omnifunc")
  pcall(vim.api.nvim_buf_set_name, buf, M.name)
  local mappings = config.mappings()
  require("dapui.util").apply_mapping(
    mappings.expand,
    "<Cmd>lua require('dapui.elements.watches').toggle_expr()<CR>",
    buf
  )
  require("dapui.util").apply_mapping(
    mappings.remove,
    "<Cmd>lua require('dapui.elements.watches').remove_expr()<CR>",
    buf
  )
  require("dapui.util").apply_mapping(mappings.edit, "<Cmd>lua require('dapui.elements.watches').edit_expr()<CR>", buf)
  vim.cmd("autocmd InsertEnter <buffer=" .. buf .. "> lua require('dapui.elements.watches').set_prompt(" .. buf .. ")")
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
  dap.listeners.after.scopes[listener_id] = function(session)
    Element:refresh(session)
  end
end

function M.on_close(info)
  Element.render_receivers[info.buffer] = nil
end

return M
