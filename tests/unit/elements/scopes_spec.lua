local async = require("dapui.async")
local a = async.tests
local Scopes = require("dapui.elements.scopes")
local tests = require("dapui.tests")
tests.bootstrap()
local mocks = tests.mocks

describe("scopes element", function()
  local client, scopes, buf
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
    scopes.render()
    buf = scopes.buffer()
  end)
  after_each(function()
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    scopes = nil
  end)
  a.it("renders initial lines", function()
    local lines = async.api.nvim_buf_get_lines(buf, 0, -1, false)
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
    local extmarks =
      async.api.nvim_buf_get_extmarks(buf, tests.namespace, 0, -1, { details = true })
    local formatted = tests.util.convert_extmarks(extmarks)
    assert.same({
      { "DapUIScope", 0, 0, 0, 0 },
      { "DapUIDecoration", 1, 1, 1, 1 },
      { "DapUIVariable", 1, 3, 1, 3 },
      { "DapUIType", 1, 5, 1, 5 },
      { "DapUIValue", 1, 14, 1, 14 },
      { "DapUIDecoration", 2, 1, 2, 1 },
      { "DapUIVariable", 2, 5, 2, 5 },
      { "DapUIType", 2, 7, 2, 7 },
      { "DapUIValue", 2, 16, 2, 16 },
      { "DapUIScope", 4, 0, 4, 0 },
      { "DapUIDecoration", 5, 1, 5, 1 },
      { "DapUIVariable", 5, 3, 5, 3 },
      { "DapUIType", 5, 11, 5, 11 },
      { "DapUIValue", 5, 21, 5, 21 },
    }, formatted)
  end)

  describe("with expanded variables", function()
    a.it("renders expanded lines", function()
      local keymaps = tests.util.get_mappings(scopes.buffer())
      keymaps["<CR>"](3)
      local lines = async.api.nvim_buf_get_lines(buf, 0, -1, false)
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
      local extmarks =
        async.api.nvim_buf_get_extmarks(buf, tests.namespace, 0, -1, { details = true })
      local formatted = tests.util.convert_extmarks(extmarks)
      assert.same({
        { "DapUIScope", 0, 0, 0, 0 },
        { "DapUIDecoration", 1, 1, 1, 1 },
        { "DapUIVariable", 1, 3, 1, 3 },
        { "DapUIType", 1, 5, 1, 5 },
        { "DapUIValue", 1, 14, 1, 14 },
        { "DapUIDecoration", 2, 1, 2, 1 },
        { "DapUIVariable", 2, 5, 2, 5 },
        { "DapUIType", 2, 7, 2, 7 },
        { "DapUIValue", 2, 16, 2, 16 },
        { "DapUIDecoration", 3, 2, 3, 2 },
        { "DapUIVariable", 3, 4, 3, 4 },
        { "DapUIType", 3, 6, 3, 6 },
        { "DapUIValue", 3, 15, 3, 15 },
        { "DapUIScope", 5, 0, 5, 0 },
        { "DapUIDecoration", 6, 1, 6, 1 },
        { "DapUIVariable", 6, 3, 6, 3 },
        { "DapUIType", 6, 11, 6, 11 },
        { "DapUIValue", 6, 21, 6, 21 },
      }, formatted)
    end)
  end)
end)
