local dapui = {}

dapui.async = setmetatable(require("dapui.async.base"), {
  __index = function(_, k)
    return require("dapui.async." .. k)
  end,
})

return dapui.async
