local config = require("dapui.config")
local Variables = require("dapui.components.variables")

---@class Scopes
---@field frame_id string
---@field var_components table<number, Variables>
---@field state UIState
local Scopes = {}

function Scopes:new(state)
  local scopes = { frame_id = nil, var_components = {}, state = state }
  setmetatable(scopes, self)
  self.__index = self
  return scopes
end

---@param canvas dapui.Canvas
function Scopes:render(canvas)
  local frame = self.state:current_frame()
  if not frame then
    return
  end
  if frame.id ~= self.frame_id then
    self.frame_id = frame.id
    self.var_components = {}
  end
  for i, scope in pairs(self.state:scopes()) do
    canvas:write(scope.name, { group = "DapUIScope" })
    canvas:write(":\n")
    local variables = self.state:variables(scope.variablesReference) or {}
    self
      :_get_var_component(i)
      :render(canvas, scope.variablesReference, variables, config.windows().indent)
    if i < #self.state:scopes() then
      canvas:write("\n")
    end
  end
  canvas:remove_line()
end

function Scopes:_get_var_component(index)
  if not self.var_components[index] then
    self.var_components[index] = Variables(self.state)
  end
  return self.var_components[index]
end

---@param state UIState
---@return Scopes
return function(state)
  return Scopes:new(state)
end
