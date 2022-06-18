local util = require("dapui.util")
---@class UIState
---@field private _listener_id string,
---@field private _variables table
---@field private _monitored_vars table
---@field private _scopes table
---@field private _frames table
---@field private _threads table
---@field private _current_frame table
---@field private _watches table
---@field private _stopped_thread_id string,
---@field private _listeners table
---@field private _step_number integer
---@field private _disabled_breakpoints table<string, table<integer, table>>
local UIState = {}

local events = { CLEAR = "clear", REFRESH = "refresh" }

function UIState:new()
  local state = {
    _listener_id = nil,
    _variables = {},
    _monitored_vars = {},
    _scopes = {},
    _frames = {},
    _threads = {},
    _current_frame = {},
    _watches = {},
    _stopped_thread_id = nil,
    _step_number = 0,
    _disabled_breakpoints = {},
    _listeners = { [events.CLEAR] = {}, [events.REFRESH] = {} },
  }
  setmetatable(state, self)
  self.__index = self
  return state
end

function UIState:_clear()
  self._variables = {}
  self._monitored_vars = {}
  self._scopes = {}
  self._frames = {}
  self._threads = {}
  self._current_frame = {}
  self._stopped_thread_id = nil
  for _, receiver in pairs(self._listeners[events.CLEAR]) do
    receiver()
  end
end

function UIState:attach(dap, listener_id)
  listener_id = listener_id or "dapui_state"
  self._listener_id = listener_id
  dap.listeners.after.event_terminated[listener_id] = function()
    self:_clear()
  end
  dap.listeners.after.disconnect[listener_id] = function()
    self:_clear()
  end
  dap.listeners.after.event_exited[listener_id] = function()
    self:_clear()
  end
  dap.listeners.after.event_stopped[listener_id] = function()
    self._step_number = self._step_number + 1
  end
  dap.listeners.after.scopes[listener_id] = function(session, err, response)
    if not err then
      self._scopes = response.scopes
      for _, scope in pairs(self._scopes) do
        session:request(
          "variables",
          { variablesReference = scope.variablesReference },
          function() end
        )
      end
      self:_refresh_watches(session)
    end
  end

  dap.listeners.after.variables[listener_id] = function(session, err, response, request)
    if not request then
      -- Session has been closed since request was made.
      return
    end
    if not err then
      for _, variable in pairs(response.variables) do
        if self._monitored_vars[variable.variablesReference] then
          session:request(
            "variables",
            { variablesReference = variable.variablesReference },
            function() end
          )
        end
      end
      self._variables[request.variablesReference] = response.variables
      self:_emit_refreshed(session)
    end
  end

  dap.listeners.after.threads[listener_id] = function(session, err, response)
    if not err then
      for _, thread in pairs(response.threads) do
        self._threads[thread.id] = thread
        session:request("stackTrace", { threadId = thread.id }, function() end)
      end
    end
  end

  dap.listeners.after.stackTrace[listener_id] = function(session, err, response, request)
    if not err then
      self._frames[request.threadId] = response.stackFrames
      self:_emit_refreshed(session)
    end
  end

  dap.listeners.after.evaluate[listener_id] = function(session, err, response)
    if not err and response.variablesReference then
      session:request(
        "variables",
        { variablesReference = response.variablesReference },
        function() end
      )
    end
  end

  dap.listeners.after.setExpression[listener_id] = function(session, err)
    if not err then
      self:_refresh_scopes(session)
    end
  end

  dap.listeners.after.setVariable[listener_id] = function(session, err)
    if not err then
      self:_refresh_scopes(session)
    end
  end
end

function UIState:_refresh_scopes(session)
  session:request("scopes", { frameId = session.current_frame.id }, function() end)
end

function UIState:_refresh_watches(session)
  for expression, expr_data in pairs(self._watches) do
    session:request("evaluate", {
      expression = expression,
      frameId = session.current_frame.id,
      context = expr_data.context,
    }, function(err, response)
      expr_data.evaluated = response
      expr_data.error = err and util.format_error(err)
      self:_emit_refreshed(session)
    end)
  end
end

function UIState:_emit_refreshed(session)
  if
    not session
    or not self:current_frame()
    or not session.current_frame
    or (self:current_frame().id ~= session.current_frame.id)
  then
    self._monitored_vars = {}
  end
  if session then
    self._current_frame = session.current_frame
    self._stopped_thread_id = session.stopped_thread_id
  else
    self:_clear()
  end
  for _, receiver in pairs(self._listeners[events.REFRESH]) do
    receiver(session)
  end
end

function UIState:monitor(var_ref)
  self._monitored_vars[var_ref] = (self._monitored_vars[var_ref] or 0) + 1
  util.with_session(function(session)
    session:request("variables", { variablesReference = var_ref }, function() end)
  end)
end

function UIState:step_number()
  return self._step_number
end

function UIState:is_monitored(var_ref)
  return self._monitored_vars[var_ref] ~= nil
end

function UIState:stop_monitor(var_ref)
  self._monitored_vars[var_ref] = (self._monitored_vars[var_ref] or 1) - 1
  if self._monitored_vars[var_ref] == 0 then
    self._monitored_vars[var_ref] = nil
    util.with_session(function(session)
      self:_emit_refreshed(session)
    end)
  end
end

function UIState:scopes()
  return self._scopes or {}
end

function UIState:variables(ref)
  return self._variables[ref]
end

function UIState:threads()
  return self._threads or {}
end

function UIState:stopped_thread()
  return self:threads()[self._stopped_thread_id or -1]
end

function UIState:frames(thread_id)
  return self._frames[thread_id] or {}
end

function UIState:current_frame()
  return self._current_frame
end

function UIState:set_variable(container_ref, variable, value)
  util.with_session(function(session)
    if session.capabilities.supportsSetExpression and variable.evaluateName then
      local frame_id = session.current_frame and session.current_frame.id
      session:request(
        "setExpression",
        { expression = variable.evaluateName, value = value, frameId = frame_id },
        function(err)
          if err then
            vim.notify(util.format_error(err))
          end
        end
      )
    elseif session.capabilities.supportsSetVariable and container_ref then
      session:request(
        "setVariable",
        { variablesReference = container_ref, name = variable.name, value = value },
        function(err)
          if err then
            vim.notify(util.format_error(err))
          end
        end
      )
    else
      vim.notify(
        "Debug server doesn't support setting " .. (variable.evaluateName or variable.name)
      )
    end
  end)
end

function UIState:breakpoints()
  local breakpoints = require("dap.breakpoints").get() or {}
  local merged_breakpoints = {}
  local buffers = {}
  for buf, _ in pairs(breakpoints) do
    buffers[buf] = true
  end
  for buf_name, _ in pairs(self._disabled_breakpoints) do
    local buf = vim.fn.bufnr(buf_name)
    buffers[buf] = true
  end
  for buffer, _ in pairs(buffers) do
    local buf_points = breakpoints[buffer] or {}
    local buf_name = vim.fn.bufname(buffer)
    for _, bp in ipairs(buf_points) do
      bp.file = buf_name
      bp.enabled = true
      if self._disabled_breakpoints[bp.file] then
        self._disabled_breakpoints[bp.file][bp.line] = nil
      end
    end
    merged_breakpoints[buffer] = buf_points
    for _, bp in pairs(self._disabled_breakpoints[buf_name] or {}) do
      table.insert(merged_breakpoints[buffer], bp)
    end
    table.sort(merged_breakpoints[buffer], function(a, b)
      return a.line < b.line
    end)
  end
  return merged_breakpoints
end

function UIState:toggle_breakpoint(bp)
  require("dap.breakpoints").toggle({
    condition = bp.condition,
    hit_condition = bp.hitCondition,
    log_message = bp.logMessage,
  }, vim.fn.bufnr(bp.file), bp.line)
  local buffer_breakpoints = require("dap.breakpoints").get(bp.file)
  local enabled = false
  for _, buf_bp in ipairs(buffer_breakpoints) do
    if buf_bp.line == bp.line then
      enabled = true
      break
    end
  end

  if not self._disabled_breakpoints[bp.file] then
    self._disabled_breakpoints[bp.file] = {}
  end

  if not enabled then
    bp.enabled = false
    self._disabled_breakpoints[bp.file][bp.line] = bp
  else
    self._disabled_breakpoints[bp.file][bp.line] = nil
  end
  util.with_session(function(session)
    self:_emit_refreshed(session)
  end, function()
    self:_emit_refreshed()
  end)
end

function UIState:add_watch(expression, context)
  self._watches[expression] = self._watches[expression]
    or { watchers = 0, context = context or "watch" }
  self._watches[expression].watchers = self._watches[expression].watchers + 1
  util.with_session(function(session)
    self:_refresh_watches(session)
  end)
end

function UIState:remove_watch(expression)
  if not self._watches[expression] then
    return
  end
  self._watches[expression].watchers = self._watches[expression].watchers - 1
  if self._watches[expression].watchers == 0 then
    self._watches[expression] = nil
  end
  util.with_session(function(session)
    self:_refresh_watches(session)
  end)
end

function UIState:watches()
  return self._watches
end

function UIState:watch(expression)
  return self._watches[expression]
end

function UIState:buffer_breakpoints(buffer)
  return self:breakpoints()[buffer] or {}
end

function UIState:_add_listener(event, callback)
  self._listeners[event][#self._listeners[event] + 1] = callback
end

function UIState:on_refresh(callback)
  self:_add_listener(events.REFRESH, callback)
end

function UIState:on_clear(callback)
  self:_add_listener(events.CLEAR, callback)
end

---@return UIState
return function()
  return UIState:new()
end
