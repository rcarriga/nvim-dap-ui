local tasks = require("dapui.async.tasks")

local dapui = { async = {} }

---@text
--- Async versions of vim.ui functions.
---@class dapui.async.ui
dapui.async.ui = {}

---@async
---@param args dapui.async.ui.InputArgs
function dapui.async.ui.input(args) end

---@class dapui.async.ui.InputArgs
---@field prompt string|nil Text of the prompt
---@field default string|nil Default reply to the input
---@field completion string|nil Specifies type of completion supported for input. Supported types are the same that can be supplied to a user-defined command using the "-complete=" argument. See |:command-completion|
---@field highlight function Function that will be used for highlighting user inputs.

---@async
---@param items any[]
---@param args dapui.async.ui.SelectArgs
function dapui.async.ui.select(items, args) end

---@class dapui.async.ui.SelectArgs
---@field prompt string|nil Text of the prompt. Defaults to `Select one of:`
---@field format_item function|nil Function to format an individual item from `items`. Defaults to `tostring`.
---@field kind string|nil Arbitrary hint string indicating the item shape. Plugins reimplementing `vim.ui.select` may wish to use this to infer the structure or semantics of `items`, or the context in which select() was called.

dapui.async.ui = {
  ---@nodoc
  select = tasks.wrap(vim.ui.select, 3),
  ---@nodoc
  input = tasks.wrap(vim.ui.input, 2),
}

return dapui.async.ui
