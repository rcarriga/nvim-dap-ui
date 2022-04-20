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

---@param canvas dapui.Canvas
function Hover:render(canvas)
  local hover_expr = self.state:watch(self.expression)
  if not hover_expr or (not hover_expr.evaluated and not hover_expr.error) then
    canvas:write(" \n")
    return
  end
  if hover_expr.evaluated and self.mode == "set" then
    hover_expr.evaluated.evaluateName = self.expression
    canvas:set_prompt(
      "> ",
      partial(self.set_var, self, hover_expr),
      { fill = hover_expr.evaluated.result }
    )
  end
  local var_ref = hover_expr.evaluated and hover_expr.evaluated.variablesReference
  local prefix
  if hover_expr.error or hover_expr.evaluated.variablesReference > 0 then
    prefix = config.icons()[self.expanded and "expanded" or "collapsed"] .. " "
    canvas:write(prefix, { group = hover_expr.error and "DapUIWatchesError" or "DapUIDecoration" })
  end

  canvas:write(self.expression)

  local val_start = 0
  local value
  if hover_expr.error then
    canvas:write(": ")
    val_start = canvas:line_width()
    value = hover_expr.error
  elseif hover_expr.evaluated then
    local evaluated = hover_expr.evaluated
    local eval_type = util.render_type(evaluated.type)
    if #eval_type > 0 then
      canvas:write(" ")
      canvas:write(eval_type, { group = "DapUIType" })
    end
    canvas:write(" = ")
    val_start = canvas:line_width()
    value = evaluated.result
  end
  for j, line in ipairs(vim.split(value, "\n")) do
    if j > 1 then
      canvas:write(string.rep(" ", val_start - 2))
    end
    canvas:write(line, { group = "DapUIValue" })
    if not hover_expr.error then
      canvas:add_mapping(config.actions.EXPAND, function()
        self.expanded = not self.expanded
        loop.run()
      end)
      canvas:add_mapping(config.actions.REPL, util.partial(util.send_to_repl, self.expression))
      canvas:add_mapping(config.actions.EDIT, function()
        self.mode = "set"
        loop.run()
      end)
    end
    canvas:write("\n")
  end

  if self.expanded and var_ref then
    local child_vars = self.state:variables(var_ref)
    if not child_vars then
      canvas:invalidate()
      return
    else
      self.var_component:render(canvas, var_ref, child_vars, config.windows().indent)
    end
  end
  canvas:remove_line()
end

---@param expression string
---@param state UIState
---@return Hover
local function new(expression, state)
  return Hover:new(expression, state)
end

return new
