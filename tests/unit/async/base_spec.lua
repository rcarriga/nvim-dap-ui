local async = require("dapui.async")
local a = async.tests
local tests = require("dapui.tests")
tests.bootstrap()

describe("task", function()
  a.it("provides result in callbacks when already complete", function()
    local task = async.run(function()
      return "test"
    end)
    local result
    async.sleep(10)
    task.add_callback(function()
      result = task.result()
    end)
    assert.equals("test", result)
  end)
  a.it("provides result in callbacks", function()
    local task = async.run(function()
      async.sleep(5)
      return "test"
    end)
    local result
    task.add_callback(function()
      result = task.result()
    end)
    async.sleep(10)
    assert.equals("test", result)
  end)
  a.it("cancels", function()
    local task = async.run(function()
      async.sleep(10)
      return "test"
    end)
    task.cancel()
    async.sleep(10)
    assert.True(task.cancelled())
    assert.same("Task was cancelled", task.error().message)
    assert.Nil(task.result())
  end)
  a.it("returns result if cancelled when completed", function()
    local task = async.run(function()
      return "test"
    end)
    async.sleep(10)
    task.cancel()
    assert.False(task.cancelled())
    assert.Nil(task.error())
    assert.same("test", task.result())
  end)
  a.it("assigns parent task", function()
    local current = async.current_task()
    local task = async.run(function()
      return "test"
    end)
    assert.Not.Nil(task.parent)
    assert.equal(current, task.parent)
  end)
  it("assigns no parent task", function()
    local task = async.run(function()
      return "test"
    end)
    assert.Nil(task.parent)
  end)

  it("returns error in function", function()
    local task = async.run(function()
      error("test")
    end)
    async.sleep(10)
    assert.True(task.done())
    assert.False(task.cancelled())
    assert.True(vim.endswith(task.error().message, "test"))
    assert.Nil(task.result())
  end)
end)

describe("async helpers", function()
  a.it("sleep", function()
    local start = vim.loop.now()
    async.sleep(10)
    local end_ = vim.loop.now()
    assert.True(end_ - start >= 10)
  end)

  a.it("current task", function()
    local current
    local task = async.run(function()
      current = async.current_task()
    end)
    assert.equal(task, current)
  end)

  a.it("wrap returns values provided to callback", function()
    local task = async.run(async.wrap(function(_, _, cb)
      cb(1, 2)
    end, 3))

    assert.same({ 1, 2 }, { task.result() })
  end)

  a.it("join returns results", function()
    local worker = function()
      async.sleep(10)
      return 1
    end

    local workers = {}
    for _ = 1, 10 do
      table.insert(workers, worker)
    end

    local success, results = async.join(workers)
    assert(success, results)
    assert.same({ { 1 }, { 1 }, { 1 }, { 1 }, { 1 }, { 1 }, { 1 }, { 1 }, { 1 }, { 1 } }, results)
  end)
end)
