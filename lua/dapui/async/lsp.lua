local tasks = require("dapui.async.tasks")
local control = require("dapui.async.control")

local dapui = { async = {} }

---@class dapui.async.lsp
dapui.async.lsp = {}

local Error = function(err, args)
  local err_tbl = vim.tbl_extend("keep", err, args or {})
  err_tbl.traceback = debug.traceback("", 2)
  return setmetatable(err_tbl, {
    __tostring = function()
      local message = ("LSP Error: %s"):format(err)
      for name, value in pairs(args or {}) do
        message = message
          .. ("\n%s: %s"):format(name, type(value) ~= "table" and value or vim.inspect(value))
      end
      message = message .. "\n" .. err_tbl.traceback
      return message
    end,
  })
end

---@class dapui.async.lsp.Client
---@field request dapui.async.lsp.RequestClient
---@field notify dapui.async.lsp.NotifyClient

---Create an async client for the given client id
---@param client_id integer
---@return dapui.async.lsp.Client
function dapui.async.lsp.client(client_id)
  local async = require("dapui.async")
  local internal_client =
    assert(vim.lsp.get_client_by_id(client_id), ("Client not found with ID %s"):format(client_id))

  local async_request = tasks.wrap(function(method, params, bufnr, request_id_future, cb)
    local success, req_id = internal_client.request(method, params, cb, bufnr)
    if not success then
      if request_id_future then
        request_id_future.set_error("Request failed")
      end
      error(("Failed to send request. Client %s has shut down"):format(client_id))
    end
    if request_id_future then
      request_id_future.set(req_id)
    end
  end, 5)

  ---@param name string
  local convert_method = function(name)
    return name:gsub("__", "$/"):gsub("_", "/")
  end

  return {
    notify = setmetatable({}, {
      __index = function(_, method)
        method = convert_method(method)
        return function(params)
          return internal_client.notify(method, params)
        end
      end,
    }),
    request = setmetatable({}, {
      __index = function(_, method)
        method = convert_method(method)
        ---@param opts? dapui.async.lsp.RequestOpts
        return function(bufnr, params, opts)
          opts = opts or {}
          local err, result

          if opts.timeout then
            local req_future = control.future()
            err, result = async.first({
              function()
                async.sleep(opts.timeout)
                local req_id = req_future.wait()
                async.run(function()
                  async_request("$/cancelRequest", { requestId = req_id }, bufnr)
                end)
                return { message = "Request timed out" }
              end,
              function()
                return async_request(method, params, bufnr, req_future)
              end,
            })
          else
            err, result = async_request(method, params, bufnr)
          end

          if err then
            error(Error(err, { method = method, params = params, bufnr = bufnr }))
          end
          return result
        end
      end,
    }),
  }
end

return dapui.async.lsp
