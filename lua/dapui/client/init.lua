local dap = require("dap")
local async = require("dapui.async")

---@alias dap.Session Session

---@class dapui.DAPClient
---@field request dapui.DAPRequestsClient
---@field listen dapui.DAPEventListenerClient
---@field session dapui.SessionProxy
---@field lib dapui.DAPClientLib
local DAPUIClient = {}

---@class dapui.SessionProxy
---@field current_frame? dapui.types.StackFrame
---@field _frame_set fun(frame: dapui.types.StackFrame)
---@field stopped_thread_id integer
---@field capabilities dapui.types.Capabilities

local proxied = {}
for _, key in ipairs({
  "current_frame",
  "_frame_set",
  "stopped_thread_id",
  "capabilities",
}) do
  proxied[key] = true
end

---@return dapui.SessionProxy
local function create_session_proxy(session)
  return setmetatable({}, {
    __index = function(_, key)
      if not proxied[key] then
        return nil
      end
      local value = session[key]
      if type(value) == "function" then
        return function(...)
          return value(session, ...)
        end
      end
      return value
    end,
  })
end

---@param session_factory fun(): dap.Session
---@return dapui.DAPClient
local function create_client(session_factory)
  local async_request = async.wrap(function(command, args, cb)
    session_factory():request(command, args, cb)
  end, 3)

  local request = setmetatable({}, {
    __index = function(_, command)
      return function(args)
        local err, body = async_request(command, args)
        if err then
          error(err)
        end
        return body
      end
    end,
  })

  local listener_prefix = "DAPClient" .. tostring(os.time())
  local listener_count = 0
  local listen = setmetatable({}, {
    __index = function(_, event)
      return function(listener)
        local listener_id = listener_prefix .. tostring(listener_count)
        listener_count = listener_count + 1
        local listener_wrapper = function(_, ...)
          local should_stop_listening = listener(...)
          if should_stop_listening then
            dap.listeners.after[event][listener_id] = nil
            dap.listeners.after["event_"..event][listener_id] = nil
          end
        end
        dap.listeners.after["event_" .. event][listener_id] = listener_wrapper 
        dap.listeners.after[event][listener_id] = listener 
      end
    end,
  })

  local client = setmetatable({
    request = request,
    listen = listen,
  }, {
    __index = function(_, key)
      if key == "session" then
        return create_session_proxy(session_factory())
      end
    end,
  })
  client.lib = require("dapui.client.lib")(client)
  return client
end

return create_client
