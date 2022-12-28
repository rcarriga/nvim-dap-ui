local async = require("dapui.async")
local a = async.tests
local Stacks = require("dapui.elements.stacks")
local tests = require("dapui.tests")
tests.bootstrap()
local mocks = tests.mocks

describe("stacks element", function()
  local client, stacks, buf
  a.before_each(function()
    client = mocks.client({
      current_frame = {
        id = 1,
      },
      requests = {
        threads = mocks.threads({
          threads = {
            {
              id = 1,
              name = "Thread 1",
            },
            {
              id = 2,
              name = "Thread 2",
            },
          },
        }),
        stackTrace = mocks.stack_traces({
          stack_traces = {
            [1] = {
              {
                id = 1,
                name = "stack_frame_1",
                source = {
                  name = "file_1",
                },
                line = 1,
              },
              {
                id = 2,
                name = "stack_frame_2",
                source = {
                  name = "file_2",
                },
                line = 2,
                presentationHint = "subtle",
              },
            },
            [2] = {
              {
                id = 3,
                name = "stack_frame_3",
                source = {
                  name = "file_3",
                },
                line = 3,
              },
              {
                id = 4,
                name = "stack_frame_4",
                source = {
                  name = "file_4",
                },
                line = 4,
              },
            },
          },
        }),
      },
    })
    stacks = Stacks(client)
    stacks.render()
    buf = stacks.buffer()
  end)
  after_each(function()
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    stacks = nil
  end)
  a.it("renders initial lines", function()
    local lines = async.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert.same({
      "Thread 1:",
      " stack_frame_1 file_1:1",
      "",
      "Thread 2:",
      " stack_frame_3 file_3:3",
      " stack_frame_4 file_4:4",
      "",
      "",
    }, lines)
  end)

  a.it("renders initial highlights", function()
    local extmarks =
      async.api.nvim_buf_get_extmarks(buf, tests.namespace, 0, -1, { details = true })
    local formatted = tests.util.convert_extmarks(extmarks)
    assert.same({
      { "DapUIThread", 0, 0, 0, 0 },
      { "DapUICurrentFrameName", 1, 4, 1, 4 },
      { "DapUISource", 1, 18, 1, 18 },
      { "DapUILineNumber", 1, 25, 1, 25 },
      { "DapUIThread", 3, 0, 3, 0 },
      { "DapUIFrameName", 4, 1, 4, 1 },
      { "DapUISource", 4, 15, 4, 15 },
      { "DapUILineNumber", 4, 22, 4, 22 },
      { "DapUIFrameName", 5, 1, 5, 1 },
      { "DapUISource", 5, 15, 5, 15 },
      { "DapUILineNumber", 5, 22, 5, 22 },
    }, formatted)
  end)

  describe("with subtle frames shown", function()
    a.it("renders expanded lines", function()
      local keymaps = tests.util.get_mappings(stacks.buffer())
      keymaps["t"](1)
      local lines = async.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.same({
        "Thread 1:",
        " stack_frame_1 file_1:1",
        " stack_frame_2 file_2:2",
        "",
        "Thread 2:",
        " stack_frame_3 file_3:3",
        " stack_frame_4 file_4:4",
        "",
        "",
      }, lines)
    end)
    a.it("renders expanded highlights", function()
      local keymaps = tests.util.get_mappings(stacks.buffer())
      keymaps["t"](1)
      local extmarks =
        async.api.nvim_buf_get_extmarks(buf, tests.namespace, 0, -1, { details = true })
      local formatted = tests.util.convert_extmarks(extmarks)
      assert.same({
        { "DapUIThread", 0, 0, 0, 0 },
        { "DapUICurrentFrameName", 1, 4, 1, 4 },
        { "DapUISource", 1, 18, 1, 18 },
        { "DapUILineNumber", 1, 25, 1, 25 },
        { "DapUIFrameName", 2, 1, 2, 1 },
        { "DapUISource", 2, 15, 2, 15 },
        { "DapUILineNumber", 2, 22, 2, 22 },
        { "DapUIThread", 4, 0, 4, 0 },
        { "DapUIFrameName", 5, 1, 5, 1 },
        { "DapUISource", 5, 15, 5, 15 },
        { "DapUILineNumber", 5, 22, 5, 22 },
        { "DapUIFrameName", 6, 1, 6, 1 },
        { "DapUISource", 6, 15, 6, 15 },
        { "DapUILineNumber", 6, 22, 6, 22 },
      }, formatted)
    end)
  end)
end)
