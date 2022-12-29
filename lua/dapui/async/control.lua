local async = require("dapui.async")

local dapui = { async = {} }

---@class dapui.async.control
dapui.async.control = {}

---@text
--- An event can signal to multiple listeners to resume execution
---@class dapui.async.control.Event()
---@field set fun(): nil Set the event and signal to all listeners that the event has occurred
---@field wait fun(): nil Wait for the event to occur
---@field clear fun(): nil Clear the event
---@field is_set fun(): boolean Returns true if the event is set

---@return dapui.async.control.Event
function dapui.async.control.event()
  local waiters = {}
  local is_set = false
  return {
    is_set = function()
      return is_set
    end,
    set = function()
      is_set = true
      local waiters_to_notify = {}
      while #waiters > 0 do
        waiters_to_notify[#waiters_to_notify + 1] = table.remove(waiters)
      end
      for _, waiter in ipairs(waiters_to_notify) do
        waiter()
      end
    end,
    wait = async.wrap(function(callback)
      if is_set then
        callback()
      else
        waiters[#waiters + 1] = callback
      end
    end, 1),
    clear = function()
      is_set = false
    end,
  }
end

return dapui.async.control
