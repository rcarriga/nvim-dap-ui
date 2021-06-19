local dap = require("dap")

local M = {}

local UIState = {}

function UIState:new(listener_id)
  local state = {
    listener_id = listener_id,
    awaiting_requests = 0,
    variables = {},
    monitored_vars = {},
    scopes = {},
    frames = {},
    threads = {},
    current_frame = {},
    listeners = {}
  }
  setmetatable(state, self)
  self.__index = self

  dap.listeners.after.scopes[listener_id] = function(session, err, response)
    if not err then
      state.scopes = response.scopes
      for ref, _ in pairs(state.monitored_vars) do
        session:request(
          "variables",
          {variablesReference = ref},
          function()
          end
        )
      end
    end
  end

  dap.listeners.after.variables[listener_id] = function(session, err, response, request)
    if not err then
      state.variables[request.variablesReference] = response.variables
      state:emit_refreshed(session)
    end
  end

  dap.listeners.after.threads[listener_id] = function(session, err, response)
    if not err then
      for _, thread in pairs(response.threads) do
        state.threads[thread.id] = thread
        session:request(
          "stackTrace",
          {threadId = thread.id},
          function()
          end
        )
      end
    end
  end

  dap.listeners.after.stackTrace[listener_id] = function(session, err, response, request)
    if not err then
      state.frames[request.threadId] = response.stackFrames
      state:emit_refreshed(session)
    end
  end

  return state
end

function UIState:destroy()
  for _, listeners in pairs(dap.listeners.after) do
    listeners[self.listener_id] = nil
  end
end

function UIState:refresh(session)
  if not session.current_frame then
    return
  end
  session:request(
    "scopes",
    {frameId = session.current_frame.id},
    function()
    end
  )
  for ref, _ in pairs(self.monitored_vars) do
    session:request(
      "variables",
      {variablesReference = ref},
      function()
      end
    )
  end
  session:request(
    "threads",
    nil,
    function()
    end
  )
end

function UIState:emit_refreshed(session)
  self.current_frame = session.current_frame
  if not self.current_frame then
    return
  end
  for _, receiver in pairs(self.listeners) do
    receiver(session)
  end
end

local ui_state

function M.setup()
  local listener_id = "dapui_state"
  ui_state = UIState:new(listener_id)
  dap.listeners.after.event_terminated[listener_id] = function()
    ui_state:destroy()
    ui_state = UIState:new(listener_id)
  end
end

function M.monitor(var_ref)
  ui_state.monitored_vars[var_ref] = (ui_state.monitored_vars[var_ref] or 0) + 1
  dap.session():request(
    "variables",
    {variablesReference = var_ref},
    function()
    end
  )
end

function M.stop_monitor(var_ref)
  ui_state.monitored_vars[var_ref] = ui_state.monitored_vars[var_ref] - 1
  if ui_state.monitored_vars[var_ref] then
    ui_state.monitored_vars[var_ref] = nil
  end
end

function M.scopes()
  return ui_state.scopes or {}
end

function M.variables(ref)
  return ui_state.variables[ref] or {}
end

function M.threads()
  return ui_state.threads or {}
end

function M.frames(thread_id)
  return ui_state.frames[thread_id] or {}
end

function M.on_refresh(callback)
  ui_state.listeners[#ui_state.listeners + 1] = callback
end

function M.refresh()
  ui_state:refresh(dap.session())
end

return M
