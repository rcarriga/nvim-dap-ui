local async = require("dapui.async")
local a = async.tests
local tests = require("dapui.tests")
tests.bootstrap()

describe("lsp client", function()
  a.it("sends request and returns result", function()
    local expected_result = { "test" }
    local expected_params = { a = "b" }
    vim.lsp.get_client_by_id = function(id)
      return {
        request = function(method, params, callback, bufnr)
          assert.equals("textDocument/diagnostic", method)
          assert.equals(0, bufnr)
          assert.same(params, params)
          callback(nil, expected_result)
        end,
      }
    end

    local client = async.lsp.client(1)

    local result = client.request.textDocument_diagnostic(0, expected_params, { timeout = 1000 })
    assert.same(expected_result, result)
  end)

  a.it("raises error on request", function()
    local expected_params = { a = "b" }
    vim.lsp.get_client_by_id = function(id)
      return {
        request = function(method, params, callback, bufnr)
          callback({ message = "error" }, nil)
        end,
      }
    end

    local client = async.lsp.client(1)

    local success, err = pcall(client.request.textDocument_diagnostic, 0, expected_params)
    assert.False(success)
    assert.same(err.message, "error")
    assert.same(err.params, expected_params)
    assert.same(err.method, "textDocument/diagnostic")
    assert.same(err.bufnr, 0)
  end)

  a.it("raises error on timeout", function()
    vim.lsp.get_client_by_id = function(id)
      return {
        request = function(method, params, callback, bufnr)
          vim.defer_fn(function()
            callback(nil, {})
          end, 100)
        end,
      }
    end

    local client = async.lsp.client(1)

    local success, err =
      pcall(client.request.textDocument_diagnostic, 0, expected_params, { timeout = 10 })
    assert.False(success)
    assert.same(err.message, "Request timed out")
  end)
end)
