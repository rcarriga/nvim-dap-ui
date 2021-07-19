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
  dap.listeners.after.scopes[listener_id] = function(session, err, response)
    if not err then
      self._scopes = response.scopes
      for ref, _ in pairs(self._monitored_vars) do
        session:request("variables", { variablesReference = ref }, function() end)
      end
      self:_refresh_watches(session)
    end
  end

  dap.listeners.after.variables[listener_id] = function(session, err, response, request)
    if not err then
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
end

function UIState:_refresh(session)
  if not session.current_frame then
    return
  end
  session:request("scopes", { frameId = session.current_frame.id }, function() end)
  for ref, _ in pairs(self._monitored_vars) do
    session:request("variables", { variablesReference = ref }, function() end)
  end
  session:request("threads", nil, function() end)
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
      if not err and response.variablesReference then
        session:request(
          "variables",
          { variablesReference = response.variablesReference },
          function() end
        )
      end
      self:_emit_refreshed(session)
    end)
  end
end

function UIState:_emit_refreshed(session)
  if self:current_frame().id ~= session.current_frame.id then
    self._monitored_vars = {}
  end
  self._current_frame = session.current_frame
  self._stopped_thread_id = session.stopped_thread_id
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

function UIState:stop_monitor(var_ref)
  self._monitored_vars[var_ref] = (self._monitored_vars[var_ref] or 1) - 1
  if self._monitored_vars[var_ref] then
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

function UIState:breakpoints()
  local breakpoints = require("dap.breakpoints").get() or {}
  for buffer, buf_points in pairs(breakpoints) do
    if not vim.tbl_isempty(buf_points) then
      local buf_name = vim.fn.bufname(buffer)
      for _, bp in pairs(buf_points) do
        bp.file = buf_name
      end
    end
  end
  return breakpoints
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

function UIState:refresh()
  util.with_session(function(session)
    self:_refresh(session)
  end)
end

---@return UIState
return function()
  return UIState:new()
end
