local nio = require("nio")
local namespace = require("dapui.render.canvas").namespace

local M = {}

function M.get_highlights(bufnr)
  local formatted = {}
  local extmarks = nio.api.nvim_buf_get_extmarks(bufnr, namespace, 0, -1, { details = true })
  for _, extmark in ipairs(extmarks) do
    local _, start_row, start_col, details = unpack(extmark)
    table.insert(formatted, {
      details.hl_group,
      start_row,
      start_col,
      details.end_row,
      details.end_col,
    })
  end
  return formatted
end

---@class dapui.tests.util.Mapping
---@field buffer integer
---@field callback? function
---@field expr integer
---@field lhs string
---@field lhsraw string
---@field lnum integer
---@field mode string
---@field noremap integer
---@field nowait integer
---@field script integer
---@field sid integer
---@field silent integer

---@param buf integer
---@return table<string, function> Per-key mappings in the buffer
function M.get_mappings(buf)
  ---@type dapui.tests.util.Mapping[]
  local raw_mappings = vim.api.nvim_buf_get_keymap(buf, "n")
  local mappings = {}
  for _, mapping in ipairs(raw_mappings) do
    mappings[mapping.lhs] = mapping.callback
  end
  return mappings
end

return M
