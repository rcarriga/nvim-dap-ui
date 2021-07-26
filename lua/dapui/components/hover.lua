local config = require("dapui.config")
local Variables = require("dapui.components.variables")
local util = require("dapui.util")
local loop = require("dapui.render.loop")
local partial = util.partial

---@class Hover
---@field expression string
---@field expanded boolean
---@field var_component Variables
---@field state UIState
---@field mode "set" | nil
local Hover = {}

---@return Hover
function Hover:new(expression, state)
  local hover = {
    expression = expression,
    expanded = false,
    var_component = Variables(state),
    state = state,
  }
  setmetatable(hover, self)
  self.__index = self
  return hover
end

function Hover:set_var(hover_expr, value)
  self.state:set_variable(nil, hover_expr.evaluated, value)
  self.mode = nil
  loop.run()
end

function Hover:render(render_state)
  local hover_expr = self.state:watch(self.expression)
  if not hover_expr or (not hover_expr.evaluated and not hover_expr.error) then
    render_state:add_line(" ")
    return
  end
  if hover_expr.evaluated and self.mode == "set" then
    hover_expr.evaluated.evaluateName = self.expression
    render_state:set_prompt(
      "> ",
      partial(self.set_var, self, hover_expr),
      { fill = hover_expr.evaluated.result }
    )
  end
  local line_no = render_state:length() + 1
  local var_ref = hover_expr.evaluated and hover_expr.evaluated.variablesReference
  local prefix
  if hover_expr.error or hover_expr.evaluated.variablesReference > 0 then
    prefix = config.icons()[self.expanded and "expanded" or "collapsed"] .. " "
    render_state:add_match(
      hover_expr.error and "DapUIWatchesError" or "DapUIDecoration",
      line_no,
      1,
      3
    )
  else
    prefix = ""
  end
  local new_line = prefix .. self.expression

  local val_indent = 0
  if hover_expr.error then
    new_line = new_line .. ": " .. hover_expr.error
  elseif hover_expr.evaluated then
    local evaluated = hover_expr.evaluated
    if #(evaluated.type or "") > 0 then
      new_line = new_line .. " "
      render_state:add_match("DapUIType", line_no, #new_line + 1, #evaluated.type)
      new_line = new_line .. evaluated.type
    end
    new_line = new_line .. " = "
    val_indent = string.rep(" ", #new_line - 2)
    new_line = new_line .. evaluated.result
  end
  for j, line in pairs(vim.split(new_line, "\n")) do
    if j > 1 then
      line = val_indent .. line
    end
    render_state:add_line(line)
    if not hover_expr.error then
      render_state:add_mapping(config.actions.EXPAND, function()
        self.expanded = not self.expanded
        loop.run()
      end)
      render_state:add_mapping(
        config.actions.REPL,
        util.partial(util.send_to_repl, self.expression)
      )
      render_state:add_mapping(config.actions.EDIT, function()
        self.mode = "set"
        loop.run()
      end)
    end
  end

  if self.expanded and var_ref then
    local child_vars = self.state:variables(var_ref)
    if not child_vars then
      render_state:invalidate()
      return
    else
      self.var_component:render(render_state, var_ref, child_vars, config.windows().indent)
    end
  end
end

---@param expression string
---@param state UIState
---@return Hover
local function new(expression, state)
  return Hover:new(expression, state)
end

return new
