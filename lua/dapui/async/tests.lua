local async = require("dapui.async")

local dapui = { async = {} }

---@class dapui.async.tests
dapui.async.tests = {}

local with_timeout = function(func, timeout)
  return function()
    local stat, ret

    async.run(function()
      ret = { pcall(func) }
      stat = table.remove(ret, 1)
    end)

    vim.wait(timeout or 2000, function()
      return stat ~= nil
    end, 20, false)

    if not stat then
      error(
        string.format(
          "Blocking on future timed out or was interrupted.\n%s",
          unpack(ret or { "Async function failed" })
        )
      )
    end

    return unpack(ret)
  end
end

dapui.async.tests.it = function(s, async_func)
  it(s, with_timeout(async_func, tonumber(vim.env.PLENARY_TEST_TIMEOUT)))
end

dapui.async.tests.before_each = function(async_func)
  before_each(with_timeout(async_func))
end

dapui.async.tests.after_each = function(async_func)
  after_each(with_timeout(async_func))
end

return dapui.async.tests
