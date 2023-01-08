local dapui = { async = {} }

---@class dapui.async.tasks
dapui.async.tasks = {}

---@type table<thread, dapui.async.tasks.Task>
---@nodoc
local tasks = {}
---@type table<dapui.async.tasks.Task, dapui.async.tasks.Task[]>
---@nodoc
local child_tasks = {}

-- Coroutine.running() was changed between Lua 5.1 and 5.2:
-- - 5.1: Returns the running coroutine, or nil when called by the main thread.
-- - 5.2: Returns the running coroutine plus a boolean, true when the running coroutine is the main one.
-- For LuaJIT, 5.2 behaviour is enabled with LUAJIT_ENABLE_LUA52COMPAT

---@nodoc
local function current_non_main_co()
  local data = { coroutine.running() }

  if select("#", unpack(data)) == 2 then
    local co, is_main = unpack(data)
    if is_main then
      return nil
    end
    return co
  end

  return unpack(data)
end

---@text
--- Tasks represent a top level running asynchronous function
--- Only one task is ever executing at any time.
---@class dapui.async.tasks.Task
---@field parent? dapui.async.tasks.Task Parent task
---@field cancel fun(): nil Cancels the task
---@field trace fun(): string Get the stack trace of the task

---@class dapui.async.tasks.TaskError
---@field message string
---@field traceback? string

local TaskError = function(message, traceback)
  return setmetatable({
    message = message,
    traceback = traceback,
  }, {
    __tostring = function()
      if type(message) ~= "string" then
        message = tostring(message)
      end
      return string.format(
        "The coroutine failed with this message: %s\n%s",
        vim.startswith(traceback, message) and "" or ("\n" .. message),
        traceback
      )
    end,
  })
end

---@return dapui.async.tasks.Task
---@nodoc
function dapui.async.tasks.run(func, cb)
  local co = coroutine.create(func)
  local cancelled = false
  local task = { parent = dapui.async.tasks.current_task() }
  if task.parent then
    child_tasks[task.parent] = child_tasks[task.parent] or {}
    table.insert(child_tasks[task.parent], task)
  end

  function task.cancel()
    if coroutine.status(co) == "dead" then
      return
    end
    for _, child in pairs(child_tasks[task] or {}) do
      child.cancel()
    end
    cancelled = true
  end

  function task.trace()
    return debug.traceback(co)
  end

  local function close_task(result, err)
    tasks[co] = nil
    if not cb then
      return
    end
    if err then
      cb(false, err.message, err.traceback)
    else
      cb(true, unpack(result))
    end
  end

  tasks[co] = task

  local function step(...)
    if cancelled then
      close_task(nil, TaskError("Task was cancelled"))
      return
    end

    local ret = { coroutine.resume(co, ...) }
    local success = ret[1]

    if not success then
      close_task(nil, TaskError(ret[2], debug.traceback(co)))
      return
    end

    if coroutine.status(co) == "dead" then
      local result = {}
      for i, v in pairs(ret) do
        result[i - 1] = v
      end
      close_task(result)
      return
    end

    local _, nargs, err_or_fn = unpack(ret)

    assert(
      type(err_or_fn) == "function",
      ("type error :: expected func, got %s"):format(type(err_or_fn))
    )

    local args = { select(4, unpack(ret)) }

    args[nargs] = step

    err_or_fn(unpack(args, 1, nargs))
  end

  step()
  return task
end

---@nodoc
function dapui.async.tasks.wrap(func, argc)
  assert(argc, "Must provide argc")
  local protected = function(...)
    local args = { ... }
    local cb = args[argc]
    args[argc] = function(...)
      cb(true, ...)
    end
    xpcall(func, function(err)
      cb(false, err, debug.traceback())
    end, unpack(args, 1, argc))
  end

  return function(...)
    if not current_non_main_co() then
      return func(...)
    end

    local ret = { coroutine.yield(argc, protected, ...) }
    local success = ret[1]
    if not success then
      error(("Wrapped function failed: %s\n%s"):format(ret[2], ret[3]))
    end
    return unpack(ret, 2, table.maxn(ret))
  end
end

--- Get the current running task
---@return dapui.async.tasks.Task|nil
function dapui.async.tasks.current_task()
  local co = current_non_main_co()
  if not co then
    return nil
  end
  return tasks[co]
end

return dapui.async.tasks
