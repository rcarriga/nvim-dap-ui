local M = {}

M.mocks = require("dapui.tests.mocks")

M.namespace = require("dapui.render.canvas").namespace

M.bootstrap = function()
  assert:add_formatter(vim.inspect)

  A = function(...)
    print(vim.inspect(...))
  end
end

M.util = require("dapui.tests.util")

return M
