local dapui = {}

---@toc_entry Async Library
---@text
--- This library was originally taken from https://github.com/lewis6991/async.nvim with
--- some refactoring and convenience functions added.
---@class dapui.async
dapui.async = {}

-- Coroutine.running() was changed between Lua 5.1 and 5.2:
-- - 5.1: Returns the running coroutine, or nil when called by the main thread.
-- - 5.2: Returns the running coroutine plus a boolean, true when the running
--   coroutine is the main one.
--
-- For LuaJIT, 5.2 behaviour is enabled with LUAJIT_ENABLE_LUA52COMPAT
--
-- We can handle both by just doing an equality check of `corouine.running` against this
local main_co_or_nil = coroutine.running()

---@class dapui.async.Task
---@field cancel fun(): nil Cancels the task

---@nodoc
---@return dapui.async.Task
local function execute(func, callback, ...)
  local co = coroutine.create(func)

  local function step(...)
    local ret = { coroutine.resume(co, ...) }
    local stat, nargs, protected, err_or_fn = unpack(ret)

    if not stat then
      error(
        string.format(
          "The coroutine failed with this message: %s\n%s",
          err_or_fn,
          debug.traceback(co)
        )
      )
    end

    if coroutine.status(co) == "dead" then
      if callback then
        callback(unpack(ret, 4))
      end
      return
    end

    assert(
      type(err_or_fn) == "function",
      ("type error :: expected func, got %s"):format(type(err_or_fn))
    )

    local args = { select(5, unpack(ret)) }

    if protected then
      args[nargs] = function(...)
        step(true, ...)
      end
      local ok, err = pcall(err_or_fn, unpack(args, 1, nargs))
      if not ok then
        step(false, err, debug.traceback(co, err, 2))
      end
    else
      args[nargs] = step
      err_or_fn(unpack(args, 1, nargs))
    end
  end

  step(...)
  return {
    cancel = function()
      if coroutine.status(co) == "dead" then
        return
      end
      coroutine.resume(co, false, "Task cancelled")
    end,
  }
end

--- Use this to create a function which executes in an async context but
--- called from a non-async context. Inherently this cannot return anything
--- since it is non-blocking
---@param func function
---@param argc number The number of arguments of func. Defaults to 0
function dapui.async.sync(func, argc)
  argc = argc or 0
  return function(...)
    if coroutine.running() ~= main_co_or_nil then
      return func(...)
    end
    local callback = select(argc + 1, ...)
    execute(func, callback, unpack({ ... }, 1, argc))
  end
end

--- Create a function which executes in an async context but
--- called from a non-async context.
---@param func function
function dapui.async.void(func)
  return function(...)
    if coroutine.running() ~= main_co_or_nil then
      return func(...)
    end
    execute(func, nil, ...)
  end
end

--- Run a function in an async context
---@param func function
function dapui.async.run(func)
  return execute(func)
end

--- Creates an async function with a callback style function.
---@param func function A callback style function to be converted. The last argument must be the callback.
---@param argc integer The number of arguments of func. Must be included.
---@param protected boolean? Call the function in protected mode (like pcall), except on error a third value is returned which is the stack trace of where the error occurred.
---@return function Returns an async function
function dapui.async.wrap(func, argc, protected)
  assert(argc)
  return function(...)
    if coroutine.running() == main_co_or_nil then
      return func(...)
    end
    return coroutine.yield(argc, protected or false, func, ...)
  end
end

--- Run a collection of async functions (`thunks`) concurrently and return when
--- all have finished.
---@param n integer Max number of thunks to run concurrently
---@param interrupt_check function Function to abort thunks between calls
---@tparam function[] thunks
function dapui.async.join(n, interrupt_check, thunks)
  local function run(finish)
    if #thunks == 0 then
      return finish()
    end

    local remaining = { select(n + 1, unpack(thunks)) }
    local to_go = #thunks

    local ret = {}

    local function cb(...)
      ret[#ret + 1] = { ... }
      to_go = to_go - 1
      if to_go == 0 then
        finish(ret)
      elseif not interrupt_check or not interrupt_check() then
        if #remaining > 0 then
          local next_task = table.remove(remaining)
          next_task(cb)
        end
      end
    end

    for i = 1, math.min(n, #thunks) do
      thunks[i](cb)
    end
  end

  return coroutine.yield(1, false, run)
end

function dapui.async.sleep(ms)
  local async_defer = dapui.async.wrap(function(time, cb)
    vim.defer_fn(cb, time)
  end, 2)
  async_defer(ms)
end

local wrapped_schedule = dapui.async.wrap(vim.schedule, 1, false)

--- Yields to the Neovim scheduler to be able to call the API.
---@async
function dapui.async.scheduler()
  wrapped_schedule()
end

---@nodoc
local function proxy_vim(prop)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...)
        -- if we are in a fast event await the scheduler
        if vim.in_fast_event() then
          async.scheduler()
        end

        return vim[prop][k](...)
      end
    end,
  })
end

--- Safely proxies calls to the vim.api module while in an async context.
dapui.async.api = proxy_vim("api")
--- Safely proxies calls to the vim.fn module while in an async context.
dapui.async.fn = proxy_vim("fn")
--- Async versions of vim.ui functions
dapui.async.ui = {
  ---@type fun(entries: string[], opts: table): string
  ---@nodoc
  select = dapui.async.wrap(vim.ui.select, 3),
  ---@type fun(opts: table): string
  ---@nodoc
  input = dapui.async.wrap(vim.ui.input, 2),
}

-- For type checking
if false then
  dapui.async.api = vim.api
  dapui.async.fn = vim.fn
  dapui.async.control = require("dapui.async.control")
  dapui.async.tests = require("dapui.async.tests")
end

return dapui.async
