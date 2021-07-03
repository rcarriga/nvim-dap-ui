local config = require("dapui.config")
local variables = require("dapui.components.variables")
local state = require("dapui.state")
local util = require("dapui.util")
local partial = util.partial
local api = vim.api
local loop = require("dapui.render.loop")

---@class Watches
---@field expressions table
---@field expanded table
---@field var_components table
local Watches = {}

---@return Watches
function Watches:new()
  local watches = {expressions = {}, var_components = {}, expanded = {}}
  setmetatable(watches, self)
  self.__index = self
  return watches
end

function Watches:add_watch(value)
  vim.cmd("stopinsert")
  if value == "" then
    loop.run()
    return
  end
  self.expressions[#self.expressions + 1] = value
  self.var_components[#self.var_components + 1] = variables()
  state.add_watch(value)
end

function Watches:edit_expr(expr_i)
  local buf = api.nvim_win_get_buf(0)
  local old = self.expressions[expr_i]
  vim.fn.prompt_setcallback(
    buf, function(new)
      vim.cmd("stopinsert")
      if new ~= "" then
        self.expressions[expr_i] = new
        state.remove_watch(old)
        state.add_watch(new)
      else
        loop.run()
      end
    end
  )
  vim.cmd("normal i" .. old)
  vim.api.nvim_input("A")
end

function Watches:remove_expr(expr_i)
  local expression = util.pop(self.expressions, expr_i)
  self.var_components[expr_i] = nil
  state.remove_watch(expression)
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

function Watches:render(render_state)
  render_state:set_prompt("> ", partial(self.add_watch, self))
  if vim.tbl_count(self.expressions) == 0 then
    render_state:add_line("No Expressions")
    render_state:add_match("DapUIWatchesEmpty", render_state:length())
    render_state:add_line()
    return
  end
  local watches = state.watches()
  for i, expr in pairs(self.expressions) do
    local line_no = render_state:length() + 1

    local watch = watches[expr]
    if not vim.tbl_isempty(watch or {}) then
      local var_ref = watch.evaluated and watch.evaluated.variablesReference
      local prefix = config.icons()[self.expanded[i] and "expanded" or
                       "collapsed"]

      local indent = config.windows().indent
      local new_line = string.rep(" ", indent)
      render_state:add_match(
        watch.error and "DapUIWatchesError" or "DapUIWatchesValue", line_no,
        indent, 3
      )

      new_line = new_line .. prefix .. " " .. expr

      local val_indent = 0
      if watch.error then
        self.expanded[i] = false
        new_line = new_line .. ": " .. watch.error
      elseif watch.evaluated then
        local evaluated = watch.evaluated
        if #(evaluated.type or "") > 0 then
          new_line = new_line .. " "
          render_state:add_match(
            "DapUIType", line_no, #new_line + 1, #evaluated.type
          )
          new_line = new_line .. evaluated.type
        end
        new_line = new_line .. " = "
        val_indent = string.rep(" ", #new_line - 2)
        new_line = new_line .. evaluated.result
      end
      for j, line in pairs(vim.split(new_line, "\n")) do
        if j > 1 then line = val_indent .. line end
        render_state:add_line(line)
        render_state:add_mapping(
          config.actions.REMOVE, partial(self.remove_expr, self, i)
        )
        render_state:add_mapping(
          config.actions.EDIT, partial(self.edit_expr, self, i)
        )
        if not watch.error then
          render_state:add_mapping(
            config.actions.EXPAND, partial(self.toggle_expression, self, i)
          )
        end
      end

      if self.var_components[i] and self.expanded[i] then
        local child_vars = state.variables(var_ref)
        if not child_vars then
          state.monitor(var_ref)
          loop.ignore_current_render()
          return
        else
          self.var_components[i]:render(
            render_state, child_vars, config.windows().indent * 2
          )
        end
      end
    end
  end
  render_state:add_line()
end

---@type fun():Variables
local new = partial(Watches.new, Watches)

return new
