local nio = require("nio")
local a = nio.tests
local Scopes = require("dapui.elements.scopes")
local tests = require("dapui.tests")
tests.bootstrap()
local mocks = tests.mocks

describe("scopes element", function()
  ---@type dapui.DAPClient
  local client
  local scopes, buf
  a.before_each(function()
    client = mocks.client({
      current_frame = {
        id = 1,
      },
      requests = {
        scopes = mocks.scopes({
          scopes = {
            [1] = {
              {
                name = "Locals",
                variablesReference = 1,
              },
              {
                name = "Globals",
                variablesReference = 2,
              },
            },
          },
        }),
        variables = mocks.variables({
          variables = {
            [1] = {
              {
                name = "a",
                value = "1",
                type = "number",
                variablesReference = 0,
              },
              {
                name = "b",
                value = "2",
                type = "number",
                variablesReference = 3,
              },
            },
            [2] = {
              {
                name = "CONST_A",
                value = "true",
                type = "boolean",
                variablesReference = 0,
              },
            },
            [3] = {
              {
                name = "c",
                value = "'3'",
                type = "string",
                variablesReference = 0,
              },
            },
          },
        }),
      },
    })
    scopes = Scopes(client)
    buf = scopes.buffer()
    client.request.scopes({ frameId = 1 })
  end)
  after_each(function()
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    scopes = nil
  end)
  a.it("renders initial lines", function()
    local lines = nio.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.same({
      "Locals:",
      "   a number = 1",
      "  b number = 2",
      "",
      "Globals:",
      "   CONST_A boolean = true",
    }, lines)
  end)

  a.it("renders initial highlights", function()
    local formatted = tests.util.get_highlights(buf)
    assert.same({
      { "DapUIScope", 0, 0, 0, 6 },
      { "DapUIDecoration", 1, 1, 1, 2 },
      { "DapUIVariable", 1, 3, 1, 4 },
      { "DapUIType", 1, 5, 1, 11 },
      { "DapUIValue", 1, 14, 1, 15 },
      { "DapUIDecoration", 2, 1, 2, 4 },
      { "DapUIVariable", 2, 5, 2, 6 },
      { "DapUIType", 2, 7, 2, 13 },
      { "DapUIValue", 2, 16, 2, 17 },
      { "DapUIScope", 4, 0, 4, 7 },
      { "DapUIDecoration", 5, 1, 5, 2 },
      { "DapUIVariable", 5, 3, 5, 10 },
      { "DapUIType", 5, 11, 5, 18 },
      { "DapUIValue", 5, 21, 5, 25 },
    }, formatted)
  end)

  describe("with expanded variables", function()
    a.it("renders expanded lines", function()
      local keymaps = tests.util.get_mappings(scopes.buffer())
      keymaps["<CR>"](3)
      nio.sleep(10)
      local lines = nio.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.same({
        "Locals:",
        "   a number = 1",
        "  b number = 2",
        "    c string = '3'",
        "",
        "Globals:",
        "   CONST_A boolean = true",
      }, lines)
    end)
    a.it("renders expanded highlights", function()
      local keymaps = tests.util.get_mappings(scopes.buffer())
      keymaps["<CR>"](3)
      nio.sleep(10)
      local formatted = tests.util.get_highlights(buf)
      assert.same({
        { "DapUIScope", 0, 0, 0, 6 },
        { "DapUIDecoration", 1, 1, 1, 2 },
        { "DapUIVariable", 1, 3, 1, 4 },
        { "DapUIType", 1, 5, 1, 11 },
        { "DapUIValue", 1, 14, 1, 15 },
        { "DapUIDecoration", 2, 1, 2, 4 },
        { "DapUIVariable", 2, 5, 2, 6 },
        { "DapUIType", 2, 7, 2, 13 },
        { "DapUIValue", 2, 16, 2, 17 },
        { "DapUIDecoration", 3, 2, 3, 3 },
        { "DapUIVariable", 3, 4, 3, 5 },
        { "DapUIType", 3, 6, 3, 12 },
        { "DapUIValue", 3, 15, 3, 18 },
        { "DapUIScope", 5, 0, 5, 7 },
        { "DapUIDecoration", 6, 1, 6, 2 },
        { "DapUIVariable", 6, 3, 6, 10 },
        { "DapUIType", 6, 11, 6, 18 },
        { "DapUIValue", 6, 21, 6, 25 },
      }, formatted)
    end)
  end)
end)
