local async = require("dapui.async")
local a = async.tests
local tests = require("dapui.tests")
tests.bootstrap()

describe("async helpers", function()
  a.it("sleep", function()
    local start = vim.loop.now()
    async.sleep(10)
    local end_ = vim.loop.now()
    assert.True(end_ - start >= 10)
  end)

  a.it("wrap returns values provided to callback", function()
    local result
    local wrapped = async.wrap(function(_, _, cb)
      cb(1, 2)
    end, 3)
    async.run(wrapped, function(_, ...)
      result = { ... }
    end)

    assert.same({ 1, 2 }, result)
  end)

  a.it("gather returns results", function()
    local worker = function(i)
      return function()
        async.sleep(100 - (i * 10))
        return i
      end
    end

    local workers = {}
    for i = 1, 10 do
      table.insert(workers, worker(i))
    end

    local results = async.gather(workers)
    assert.same({ { 1 }, { 2 }, { 3 }, { 4 }, { 5 }, { 6 }, { 7 }, { 8 }, { 9 }, { 10 } }, results)
  end)

  a.it("gather raises errors", function()
    local worker = function(i)
      return function()
        if i == 4 then
          error("error")
        end
        async.sleep(100 - (i * 10))
        return i
      end
    end

    local workers = {}
    for i = 1, 10 do
      table.insert(workers, worker(i))
    end

    assert.error(function()
      async.gather(workers)
    end)
  end)

  a.it("first returns first result", function()
    local worker = function(i)
      return function()
        async.sleep(100 - (i * 10))
        return i
      end
    end

    local workers = {}
    for i = 1, 10 do
      table.insert(workers, worker(i))
    end

    local result = async.first(workers)
    assert.same(10, result)
  end)

  a.it("first cancels pending tasks", function()
    local worker = function(i)
      return function()
        async.sleep(100 - (i * 10))
        if i ~= 10 then
          error("error")
        end
        return i
      end
    end

    local workers = {}
    for i = 1, 10 do
      table.insert(workers, worker(i))
    end

    async.first(workers)
  end)

  a.it("first raises errors", function()
    local worker = function(i)
      return function()
        if i == 4 then
          error("error")
        end
        async.sleep(100 - (i * 10))
        return i
      end
    end

    local workers = {}
    for i = 1, 10 do
      table.insert(workers, worker(i))
    end

    assert.error(function()
      async.first(workers)
    end)
  end)
end)
