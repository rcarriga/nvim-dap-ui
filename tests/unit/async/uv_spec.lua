local async = require("dapui.async")
local a = async.tests
local tests = require("dapui.tests")
tests.bootstrap()

describe("file operations", function()
  local path = vim.fn.tempname()
  a.after_each(function()
    os.remove(path)
  end)
  a.it("reads a file", function()
    local f = assert(io.open(path, "w"))
    f:write("test read")
    f:close()

    local _, file = async.uv.fs_open(path, "r", 438)
    local _, data = async.uv.fs_read(file, 1024, -1)
    async.uv.fs_close(file)
    assert.equals("test read", data)
  end)

  a.it("writes a file", function()
    local _, file = async.uv.fs_open(path, "w", 438)
    async.uv.fs_write(file, "test write")
    async.uv.fs_close(file)

    local file = assert(io.open(path, "r"))
    local data = file:read()
    file:close()

    assert.equals("test write", data)
  end)
end)
