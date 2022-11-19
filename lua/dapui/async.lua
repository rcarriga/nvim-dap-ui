local plen_async = require("plenary.async")

local function proxy_vim(prop)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...)
        -- if we are in a fast event await the scheduler
        if vim.in_fast_event() then
          plen_async.util.scheduler()
        end

        return vim[prop][k](...)
      end
    end,
  })
end

local async_wrapper = {
  api = proxy_vim("api"),
  fn = proxy_vim("fn"),
  ui = {
    select = plen_async.wrap(vim.ui.select, 3),
    input = plen_async.wrap(vim.ui.input, 2),
  },
  lib = {
    first = function(...)
      local functions = { ... }
      local send_ran, await_ran = plen_async.control.channel.oneshot()
      local result, ran
      for _, func in ipairs(functions) do
        plen_async.run(function()
          local func_result = func()
          if not ran then
            result = func_result
            ran = true
            send_ran()
          end
        end)
      end
      await_ran()
      return result
    end,
  },
}
if false then
  -- For type checking
  async_wrapper.api = vim.api
  async_wrapper.fn = vim.fn
end

setmetatable(async_wrapper, {
  __index = function(_, k)
    return plen_async[k]
  end,
})

return async_wrapper
