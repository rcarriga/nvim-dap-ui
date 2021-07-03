local state = require("dapui.state")
local config = require("dapui.config")
local loop = require("dapui.render.loop")

local Variables = require("dapui.components.variables")

---@class Scopes
---@field frame_id string
---@field var_components table<number, Variables>
local Scopes = {}

function Scopes:new()
  local scopes = {frame_id = nil, var_components = {}}
  setmetatable(scopes, self)
  self.__index = self
  return scopes
end

function Scopes:render(render_state)
  local frame = state.current_frame()
  if not frame then return end
  if frame.id ~= self.frame_id then
    self.frame_id = frame.id
    self.var_components = {}
  end
  for i, scope in pairs(state.scopes()) do
    render_state:add_match(
      "DapUIScope", render_state:length() + 1, 1, #scope.name
    )
    render_state:add_line(scope.name .. ":")
    local variables = state.variables(scope.variablesReference)
    if not variables then
      state.monitor(scope.variablesReference)
      loop.ignore_current_render()
      return
    else
      self:_get_var_component(i):render(
        render_state, variables, config.windows().indent
      )
    end
    if i < #state.scopes() then render_state:add_line() end
  end
end

function Scopes:_get_var_component(index)
  if not self.var_components[index] then
    self.var_components[index] = Variables()
  end
  return self.var_components[index]
end

---@return Scopes
return function() return Scopes:new() end
