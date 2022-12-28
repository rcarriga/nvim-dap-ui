local M = {}

-- { { 1, 0, 0, {
--       end_col = 6,
--       end_right_gravity = false,
--       end_row = 0,
--       hl_eol = false,
--       hl_group = "DapUIScope",
--       priority = 4096,
--       right_gravity = true
--     } }, { 2, 1, 1, {

---@class dapui.tests.util.ExtmarkDetails
---@field end_col number
---@field end_right_gravity boolean
---@field end_row number
---@field hl_eol boolean
---@field hl_group string
---@field priority number
---@field right_gravity boolean

---@param extmarks ((integer|dapui.tests.util.ExtmarkDetails)[])[]
function M.convert_extmarks(extmarks)
  local formatted = {}
  for _, extmark in ipairs(extmarks) do
    local _, start_row, start_col, details = unpack(extmark)
    table.insert(formatted, {
      details.hl_group,
      start_row,
      start_col,
      extmark[2],
      extmark[3],
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
