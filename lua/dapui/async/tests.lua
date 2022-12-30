local async = require("dapui.async")

local dapui = { async = {} }

---@text
--- Async versions of plenary's test functions.
---@class dapui.async.tests
dapui.async.tests = {}

local with_timeout = function(func, timeout)
  return function()
    local task = async.run(func)

    vim.wait(timeout or 2000, function()
      return task.done()
    end, 20, false)

    if not task.done() or task.error() then
      error(
        string.format(
          "Blocking on future timed out or was interrupted.\n%s",
          task.error() or "Timed out"
        )
      )
    end
  end
end

---@param name string
---@param async_func function
dapui.async.tests.it = function(name, async_func)
  it(name, with_timeout(async_func, tonumber(vim.env.PLENARY_TEST_TIMEOUT)))
end

---@param async_func function
dapui.async.tests.before_each = function(async_func)
  before_each(with_timeout(async_func))
end

---@param async_func function
dapui.async.tests.after_each = function(async_func)
  after_each(with_timeout(async_func))
end

return dapui.async.tests
