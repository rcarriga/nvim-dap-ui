local dap = require("dap")
local async = require("dapui.async")

---@alias dap.Session Session

---@param session_factory fun(): dap.Session
---@return dapui.DAPClient
local function create_client(session_factory)
  local async_request = async.wrap(function(command, args, cb)
    session_factory():request(command, args, cb)
  end, 3)

  local requests = setmetatable({}, {
    __index = function(command)
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
    __index = function(event)
      return function(listener)
        local listener_id = listener_prefix .. tostring(listener_count)
        listener_count = listener_count + 1
        dap.listeners.after[event][listener_id] = function(...)
          local should_stop_listening = listener(...)
          if should_stop_listening then
            dap.listeners.after[event][listener_id] = nil
          end
        end
      end
    end,
  })

  return {
    requests = requests,
    listen = listen,
  }
end

return create_client
