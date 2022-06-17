local config = require("dapui.config")
local Variables = require("dapui.components.variables")
local util = require("dapui.util")
local loop = require("dapui.render.loop")

local partial = util.partial

---@class Watches
---@field expressions table
---@field expanded table
---@field var_components table
---@field state UIState
---@field mode "new"|"edit"
---@field edit_index integer
---@field rendered_step integer | nil
---@field rendered_exprs table[]
local Watches = {}

function Watches:new(state)
  local watches = {
    expressions = {},
    var_components = {},
    expanded = {},
    state = state,
    mode = "new",
    edit_index = nil,
    rendered_exprs = {},
  }
  setmetatable(watches, self)
  self.__index = self
  return watches
end

function Watches:add_watch(value)
  if value == "" then
    loop.run()
    return
  end
  self.expressions[#self.expressions + 1] = value
  self.var_components[#self.var_components + 1] = Variables(self.state)
  self.state:add_watch(value)
end

function Watches:edit_expr(new_value)
  self.mode = "new"
  local index = self.edit_index
  self.edit_index = nil
  local old = self.expressions[index]
  if new_value == "" then
    loop.run()
    return
  end
  self.expressions[index] = new_value
  self.state:remove_watch(old)
  self.state:add_watch(new_value)
end

function Watches:remove_expr(expr_i)
  local expression = util.pop(self.expressions, expr_i)
  self.var_components[expr_i] = nil
  self.state:remove_watch(expression)
  loop.run()
end

function Watches:toggle_expression(expr_i)
  local expanded = self.expanded[expr_i]
  if expanded then
    self.expanded[expr_i] = nil
  else
    self.expanded[expr_i] = true
  end
  loop.run()
end

---@param canvas dapui.Canvas
function Watches:render(canvas)
  if self.mode == "new" then
    canvas:set_prompt("> ", partial(self.add_watch, self))
  else
    local old_val = self.expressions[self.edit_index]
    canvas:set_prompt("> ", partial(self.edit_expr, self), { fill = old_val })
  end
  if vim.tbl_count(self.expressions) == 0 then
    canvas:write("No Expressions\n", { group = "DapUIWatchesEmpty" })
    return
  end
  local watches = self.state:watches()
  for i, expr in pairs(self.expressions) do
    local watch = watches[expr]
    if not vim.tbl_isempty(watch or {}) then
      local var_ref = watch.evaluated and watch.evaluated.variablesReference
      local prefix = config.icons()[self.expanded[i] and "expanded" or "collapsed"]

      canvas:write(prefix, { group = watch.error and "DapUIWatchesError" or "DapUIWatchesValue" })
      canvas:write(" " .. expr)

      local value = ""
      if watch.error then
        self.expanded[i] = false
        canvas:write(": ")
        value = watch.error
      elseif watch.evaluated then
        local evaluated = watch.evaluated
        local eval_type = util.render_type(evaluated.type)
        if #eval_type > 0 then
          canvas:write(" ")
          canvas:write(eval_type, { group = "DapUIType" })
        end
        canvas:write(" = ")
        value = evaluated.result
      end
      local val_start = canvas:line_width()
      local var_group

      if
        not self.rendered_exprs[i]
        or not watch.evaluated
        or self.rendered_exprs[i].result == watch.evaluated.result
      then
        var_group = "DapUIValue"
      else
        var_group = "DapUIModifiedValue"
      end

      for j, line in pairs(vim.split(value, "\n")) do
        if j > 1 then
          canvas:write(string.rep(" ", val_start - 2))
        end
        canvas:write(line, { group = var_group })
        canvas:add_mapping(config.actions.REMOVE, partial(self.remove_expr, self, i))
        canvas:add_mapping(config.actions.EDIT, function()
          self.edit_index = i
          self.mode = "edit"
          loop.run()
        end)
        if not watch.error then
          canvas:add_mapping(config.actions.EXPAND, partial(self.toggle_expression, self, i))
          canvas:add_mapping(config.actions.REPL, partial(util.send_to_repl, expr))
        end
        canvas:write("\n")
      end

      if self.var_components[i] and self.expanded[i] then
        local child_vars = self.state:variables(var_ref) or {}
        if not self.state:is_monitored(var_ref) then
          self.state:monitor(var_ref)
        end
        self.var_components[i]:render(canvas, var_ref, child_vars, config.windows().indent)
      end
      if self.rendered_step ~= self.state:step_number() then
        self.rendered_exprs[i] = watch.evaluated
      end
    end
  end
  if self.rendered_step ~= self.state:step_number() then
    self.rendered_step = self.state:step_number()
  end
end

---@param state UIState
---@return Watches
return function(state)
  return Watches:new(state)
end
