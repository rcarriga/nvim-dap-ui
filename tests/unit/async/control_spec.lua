local async = require("dapui.async")
local a = async.tests
local tests = require("dapui.tests")
tests.bootstrap()

describe("event", function()
  a.it("notifies listeners", function()
    local event = async.control.event()
    local notified = 0
    for _ = 1, 10 do
      async.run(function()
        event.wait()
        notified = notified + 1
      end)
    end

    event.set()
    async.sleep(10)
    assert.equals(10, notified)
  end)

  a.it("notifies listeners when already set", function()
    local event = async.control.event()
    local notified = 0
    event.set()
    for _ = 1, 10 do
      async.run(function()
        event.wait()
        notified = notified + 1
      end)
    end

    async.sleep(10)
    assert.equals(10, notified)
  end)

  a.it("notifies listeners with new value", function()
    local event = async.control.event()
    local value
    event.set("test")
    event.clear()
    async.run(function()
      value = event.wait()
    end)
    event.set()
    async.sleep(10)
    assert.Nil(value)
  end)
end)

describe("future", function()
  a.it("provides listeners result", function()
    local future = async.control.future()
    local notified = 0
    for _ = 1, 10 do
      async.run(function()
        local val = future.wait()
        notified = notified + val
      end)
    end

    future.set(1)
    async.sleep(10)
    assert.equals(10, notified)
  end)

  a.it("notifies listeners when already set", function()
    local future = async.control.future()
    local notified = 0
    future.set(1)
    for _ = 1, 10 do
      async.run(function()
        notified = notified + future.wait()
      end)
    end

    async.sleep(10)
    assert.equals(10, notified)
  end)

  a.it("raises error for listeners", function()
    local future = async.control.future()
    local notified = 0
    future.set_error("test")
    local success, err = pcall(future.wait)

    async.sleep(10)
    assert.False(success)
    assert.True(vim.endswith(err, "test"))
  end)
end)
describe("queue", function()
  a.it("adds and removes items", function()
    local queue = async.control.queue()
    queue.put(1)
    queue.put(2)

    assert.same(queue.size(), 2)
    assert.same(1, queue.get())
    assert.same(2, queue.get())
    assert.same(queue.size(), 0)
  end)

  a.it("get blocks while empty", function()
    local queue = async.control.queue()
    async.run(function()
      async.sleep(10)
      queue.put(1)
    end)
    assert.same(1, queue.get())
  end)

  a.it("put blocks while full", function()
    local queue = async.control.queue(1)
    async.run(function()
      async.sleep(10)
      queue.get()
    end)
    queue.put(1)
    queue.put(2)
    assert.same(2, queue.get())
  end)

  it("get_nowait errors when empty", function()
    local queue = async.control.queue()
    assert.error(queue.get_nowait)
  end)

  it("put_nowait errors while full", function()
    local queue = async.control.queue(1)
    queue.put_nowait(1)
    assert.error(function()
      queue.put_nowait(2)
    end)
  end)
end)

describe("semaphore", function()
  a.it("only allows permitted number of concurrent accesses", function()
    local concurrent = 0
    local max_concurrent = 0
    local allowed = 3
    local semaphore = async.control.semaphore(allowed)
    local worker = function()
      semaphore.with(function()
        concurrent = concurrent + 1
        max_concurrent = math.max(max_concurrent, concurrent)
        async.sleep(10)
        concurrent = concurrent - 1
      end)
    end
    local workers = {}
    for _ = 1, 10 do
      table.insert(workers, worker)
    end
    async.gather(workers)

    assert.same(max_concurrent, allowed)
  end)
end)
