local async = require("dapui.async")
local a = async.tests
local Watches = require("dapui.elements.watches")
local tests = require("dapui.tests")
tests.bootstrap()
local mocks = tests.mocks

describe("watches element", function()
  ---@type dapui.elements.watches
  local watches
  local client, buf
  a.before_each(function()
    client = mocks.client({
      current_frame = {
        id = 1,
      },
      requests = {
        scopes = mocks.scopes({
          scopes = { [1] = {} },
        }),
        evaluate = mocks.evaluate({
          expressions = {
            a = "'a value'",
            ["b - 1"] = { result = "1", type = "number" },
            c = { result = "{ d = 1 }", type = "table", variablesReference = 1 },
          },
        }),
        variables = mocks.variables({
          variables = {
            [1] = {
              {
                name = "d",
                value = "1",
                type = "number",
                variablesReference = 0,
              },
            },
          },
        }),
      },
    })
    client.request.scopes({ frameId = 1 })
    watches = Watches(client)
    buf = watches.buffer()
    watches.render()
  end)
  after_each(function()
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    watches = nil
  end)
  describe("with no expressions", function()
    a.it("renders no expressions lines", function()
      local lines = async.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.same({ "No Expressions", "" }, lines)
    end)
    a.it("renders lines after expression update", function()
      local highlights = tests.util.get_highlights(buf)
      assert.same({ { "DapUIWatchesEmpty", 0, 0, 0, 14 } }, highlights)
    end)
  end)

  a.it("renders lines with expressions", function()
    watches.add("a")
    watches.add("b - 1")
    watches.add("c")
    async.sleep(10)
    local lines = async.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.same(
      { " a = 'a value'", " b - 1 number = 1", " c table = { d = 1 }", "" },
      lines
    )
  end)

  a.it("renders highlights with expressions", function()
    watches.add("a")
    watches.add("b - 1")
    watches.add("c")
    async.sleep(10)
    local highlights = tests.util.get_highlights(buf)
    assert.same({
      { "DapUIWatchesValue", 0, 0, 0, 3 },
      { "DapUIModifiedValue", 0, 8, 0, 17 },
      { "DapUIWatchesValue", 1, 0, 1, 3 },
      { "DapUIType", 1, 10, 1, 16 },
      { "DapUIModifiedValue", 1, 19, 1, 20 },
      { "DapUIWatchesValue", 2, 0, 2, 3 },
      { "DapUIType", 2, 6, 2, 11 },
      { "DapUIModifiedValue", 2, 14, 2, 23 },
    }, highlights)
  end)

  describe("with expanded variables", function()
    a.it("renders expanded lines", function()
      watches.add("c")
      watches.toggle_expand(1)
      async.sleep(10)

      local lines = async.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.same({ " c table = { d = 1 }", "   d number = 1", "" }, lines)
    end)
    a.it("renders expanded highlights", function()
      watches.add("c")
      watches.toggle_expand(1)
      async.sleep(10)

      local highlights = tests.util.get_highlights(buf)
      assert.same({
        { "DapUIWatchesValue", 0, 0, 0, 3 },
        { "DapUIType", 0, 6, 0, 11 },
        { "DapUIModifiedValue", 0, 14, 0, 23 },
        { "DapUIDecoration", 1, 1, 1, 2 },
        { "DapUIVariable", 1, 3, 1, 4 },
        { "DapUIType", 1, 5, 1, 11 },
        { "DapUIValue", 1, 14, 1, 15 },
      }, highlights)
    end)
  end)
end)
