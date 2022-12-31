local M = {}

M.mocks = require("dapui.tests.mocks")

M.namespace = require("dapui.render.canvas").namespace

M.bootstrap = function()
  assert:add_formatter(vim.inspect)

  A = function(...)
    local obj = select("#", ...) == 1 and select(1, ...) or { ... }
    local s = type(obj) == "string" and obj or vim.inspect(obj)
    vim.schedule(function()
      print(s)
    end)
  end
end

M.util = require("dapui.tests.util")

return M
