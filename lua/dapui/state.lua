local dap = require("dap")

local util = require("dapui.util")

local M = {}

local UIState = {}

local events = {CLEAR = "clear", REFRESH = "refresh"}

function UIState:new()
  local state = {
    listener_id = nil,
    awaiting_requests = 0,
    variables = {},
    monitored_vars = {},
    scopes = {},
    frames = {},
    threads = {},
    current_frame = {},
    watches = {},
    stopped_thread_id = nil,
    listeners = {[events.CLEAR] = {}, [events.REFRESH] = {}},
  }
  setmetatable(state, self)
  self.__index = self
  return state
end

function UIState:clear()
  self.awaiting_requests = 0
  self.variables = {}
  self.monitored_vars = {}
  self.scopes = {}
  self.frames = {}
  self.threads = {}
  self.current_frame = {}
  self.stopped_thread_id = nil
  for _, receiver in pairs(self.listeners[events.CLEAR]) do receiver() end
end

function UIState:attach(listener_id)
  self.listener_id = listener_id
  dap.listeners.after.scopes[listener_id] =
    function(session, err, response)
      if not err then
        self.scopes = response.scopes
        for ref, _ in pairs(self.monitored_vars) do
          session:request(
            "variables", {variablesReference = ref}, function() end
          )
        end
        self:refresh_watches(session)
      end
    end

  dap.listeners.after.variables[listener_id] =
    function(session, err, response, request)
      if not err then
        self.variables[request.variablesReference] = response.variables
        self:emit_refreshed(session)
      end
    end

  dap.listeners.after.threads[listener_id] =
    function(session, err, response)
      if not err then
        for _, thread in pairs(response.threads) do
          self.threads[thread.id] = thread
          session:request("stackTrace", {threadId = thread.id}, function() end)
        end
      end
    end

  dap.listeners.after.stackTrace[listener_id] =
    function(session, err, response, request)
      if not err then
        self.frames[request.threadId] = response.stackFrames
        self:emit_refreshed(session)
      end
    end
end

function UIState:refresh(session)
  if not session.current_frame then return end
  session:request("scopes", {frameId = session.current_frame.id}, function() end)
  for ref, _ in pairs(self.monitored_vars) do
    session:request("variables", {variablesReference = ref}, function() end)
  end
  session:request("threads", nil, function() end)
end

function UIState:refresh_watches(session)
  for expression, expr_data in pairs(self.watches) do
    session:request(
      "evaluate", {
        expression = expression,
        frameId = session.current_frame.id,
        context = expr_data.context,
      }, function(err, response)
        expr_data.evaluated = response
        expr_data.error = err and util.format_error(err)
        if not err and response.variablesReference then
          session:request(
            "variables", {variablesReference = response.variablesReference},
            function() end
          )
        end
        self:emit_refreshed(session)
      end
    )
  end
end

function UIState:emit_refreshed(session)
  self.current_frame = session.current_frame
  self.stopped_thread_id = session.stopped_thread_id
  for _, receiver in pairs(self.listeners[events.REFRESH]) do receiver(session) end
end

local ui_state

function M.setup()
  local listener_id = "dapui_state"
  ui_state = UIState:new()
  ui_state:attach(listener_id)
  dap.listeners.after.event_terminated[listener_id] = function()
    ui_state:clear()
  end
end

function M.monitor(var_ref)
  ui_state.monitored_vars[var_ref] = (ui_state.monitored_vars[var_ref] or 0) + 1
  local session = dap.session()
  if not session then return end
  session:request("variables", {variablesReference = var_ref}, function() end)
end

function M.stop_monitor(var_ref)
  ui_state.monitored_vars[var_ref] = (ui_state.monitored_vars[var_ref] or 1) - 1
  if ui_state.monitored_vars[var_ref] then
    ui_state.monitored_vars[var_ref] = nil
    ui_state:emit_refreshed(dap.session())
  end
end

function M.scopes() return ui_state.scopes or {} end

function M.variables(ref) return ui_state.variables[ref] end

function M.threads() return ui_state.threads or {} end

function M.stopped_thread() return M.threads()[ui_state.stopped_thread_id or -1] end

function M.frames(thread_id) return ui_state.frames[thread_id] or {} end

function M.current_frame() return ui_state.current_frame end

function M.breakpoints()
  local breakpoints = require("dap.breakpoints").get() or {}
  for buffer, buf_points in pairs(breakpoints) do
    if not vim.tbl_isempty(buf_points) then
      local buf_name = vim.fn.bufname(buffer)
      for _, bp in pairs(buf_points) do bp.file = buf_name end
    end
  end
  return breakpoints
end

function M.add_watch(expression, context)
  ui_state.watches[expression] = ui_state.watches[expression] or
                                   {watchers = 0, context = context or "watch"}
  ui_state.watches[expression].watchers =
    ui_state.watches[expression].watchers + 1
  ui_state:refresh_watches(dap.session())
end

function M.remove_watch(expression)
  if not ui_state.watches[expression] then return end
  ui_state.watches[expression].watchers =
    ui_state.watches[expression].watchers - 1
  if ui_state.watches[expression].watchers == 0 then
    ui_state.watches[expression] = nil
  end
  ui_state:refresh_watches(dap.session())
end

function M.watches() return ui_state.watches end

function M.watch(expression) return ui_state.watches[expression] end

function M.buffer_breakpoints(buffer) return M.breakpoints()[buffer] or {} end

local function add_listener(event, callback)
  ui_state.listeners[event][#ui_state.listeners[event] + 1] = callback
end

function M.on_refresh(callback) add_listener(events.REFRESH, callback) end

function M.on_clear(callback) add_listener(events.CLEAR, callback) end

function M.refresh() ui_state:refresh(dap.session()) end

return M
