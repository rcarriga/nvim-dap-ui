local util = require("dapui.util")

describe("checking with_session", function()
  it("doesn't run without session", function()
    local data = { x = 0 }
    util.with_session(function()
      data.x = 1
    end)
    assert.equals(data.x, 0)
  end)

  it("runs with session", function()
    package.loaded["dap"] = {
      session = function()
        return true
      end,
    }
    local data = { x = 0 }
    util.with_session(function(session)
      assert.equals(session, true)
      data.x = 1
    end)
    assert.equals(data.x, 1)
    package.loaded["dap"] = nil
  end)
end)

describe("checking is_uri", function()
  it("returns true on uri", function()
    assert(util.is_uri("file://myfile"))
  end)

  it("returns false on non-uri", function()
    assert(not util.is_uri("/myfile"))
  end)
end)

describe("checking pretty name", function()
  it("converts a path", function()
    local uri = "/home/file.py"
    local result = util.pretty_name(uri)
    assert.equals(result, "file.py")
  end)

  it("converts a uri", function()
    local uri = "file:///home/file.py"
    local result = util.pretty_name(uri)
    assert.equals(result, "file.py")
  end)
end)

describe("checking pop", function()
  it("returns existing value", function()
    local data = { x = 1 }
    local result = util.pop(data, "x", 2)
    assert.equals(result, 1)
  end)
  it("returns default", function()
    local data = {}
    local result = util.pop(data, "x", 2)
    assert.equals(result, 2)
  end)
  it("removes existing key", function()
    local data = { x = 1 }
    util.pop(data, "x", 2)
    assert.equals(data.x, nil)
  end)
end)

describe("checking format_error", function()
  it("formats variables", function()
    local error = {
      body = {
        error = {
          format = 'Unable to eval expression: "{e}"',
          variables = { e = "could not find symbol value for a" },
        },
      },
    }
    local expected = 'Unable to eval expression: "could not find symbol value for a"'
    local result = util.format_error(error)
    assert.equals(expected, result)
  end)
  it("returns message", function()
    local error = { message = "Couldn't evaluate expression 'a'" }
    local expected = "Couldn't evaluate expression 'a'"
    local result = util.format_error(error)
    assert.equals(expected, result)
  end)
  it("returns message within body", function()
    local error = { body = { message = "Couldn't evaluate expression 'a'" } }
    local expected = "Couldn't evaluate expression 'a'"
    local result = util.format_error(error)
    assert.equals(expected, result)
  end)
end)

describe("checking partial", function()
  it("supplies preloaded args", function()
    local f = function(a, b)
      assert.equals(a, 1)
      assert.equals(b, 2)
    end
    local g = util.partial(f, 1, 2)
    g()
  end)

  it("supplies new args", function()
    local f = function(a, b)
      assert.equals(a, 1)
      assert.equals(b, 2)
    end
    local g = util.partial(f, 1)
    g(2)
  end)
end)

describe("checking round", function()
  it("rounds down", function()
    assert.equal(0, util.round(0.1))
  end)
  it("rounds up", function()
    assert.equal(1, util.round(0.5))
  end)
end)
