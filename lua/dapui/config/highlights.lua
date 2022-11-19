local M = {}

local control_hl_groups = {
  "DapUIPlayPause", "DapUIRestart", "DapUIStop", "DapUIUnavailable",
  "DapUIStepOver", "DapUIStepInto", "DapUIStepBack", "DapUIStepOut",
}

---Applies the background color from the template highlight group to all
---control icon highlight groups.
---@return nil
local function patch_background()
  -- API function 'nvim_get_hl_by_name' and the ability to pass a table to
  -- 'vim.cmd' only exist for >= 0.8
  if not vim.fn.has("nvim-0.8") then return end

  for _, suffix in pairs({"", "NC"}) do
  	local template_group = string.format("WinBar%s", suffix)
    local exists, hl = pcall(vim.api.nvim_get_hl_by_name, template_group, true)

    if exists then
      local guibg = hl.background and string.format("guibg=#%06x", hl.background) or "guibg=NONE"

      for _, hl_group in ipairs(control_hl_groups) do
        vim.cmd {
          cmd = "highlight",
          args = {string.format("%s%s", hl_group, suffix), guibg}
        }
      end
    end
  end
end

function M.setup()
  vim.cmd("hi default link DapUIVariable Normal")
  vim.cmd("hi default DapUIScope guifg=#00F1F5")
  vim.cmd("hi default DapUIType guifg=#D484FF")
  vim.cmd("hi default link DapUIValue Normal")
  vim.cmd("hi default DapUIModifiedValue guifg=#00F1F5 gui=bold")
  vim.cmd("hi default DapUIDecoration guifg=#00F1F5")
  vim.cmd("hi default DapUIThread guifg=#A9FF68")
  vim.cmd("hi default DapUIStoppedThread guifg=#00f1f5")
  vim.cmd("hi default link DapUIFrameName Normal")
  vim.cmd("hi default DapUISource guifg=#D484FF")
  vim.cmd("hi default DapUILineNumber guifg=#00f1f5")
  vim.cmd("hi default link DapUIFloatNormal NormalFloat")
  vim.cmd("hi default DapUIFloatBorder guifg=#00F1F5")
  vim.cmd("hi default DapUIWatchesEmpty guifg=#F70067")
  vim.cmd("hi default DapUIWatchesValue guifg=#A9FF68")
  vim.cmd("hi default DapUIWatchesError guifg=#F70067")
  vim.cmd("hi default DapUIBreakpointsPath guifg=#00F1F5")
  vim.cmd("hi default DapUIBreakpointsInfo guifg=#A9FF68")
  vim.cmd("hi default DapUIBreakpointsCurrentLine guifg=#A9FF68 gui=bold")
  vim.cmd("hi default link DapUIBreakpointsLine DapUILineNumber")
  vim.cmd("hi default DapUIBreakpointsDisabledLine guifg=#424242")
  vim.cmd("hi default link DapUICurrentFrameName DapUIBreakpointsCurrentLine")
  vim.cmd("hi default DapUIStepOver guifg=#00f1f5")
  vim.cmd("hi default DapUIStepInto guifg=#00f1f5")
  vim.cmd("hi default DapUIStepBack guifg=#00f1f5")
  vim.cmd("hi default DapUIStepOut guifg=#00f1f5")
  vim.cmd("hi default DapUIStop guifg=#F70067")
  vim.cmd("hi default DapUIPlayPause guifg=#A9FF68")
  vim.cmd("hi default DapUIRestart guifg=#A9FF68")
  vim.cmd("hi default DapUIUnavailable guifg=#424242")

  -- Generate *NC variants of the control highlight groups
  if vim.fn.has("nvim-0.8") then
  	for _, hl_group in pairs(control_hl_groups) do
      local guifg = vim.api.nvim_get_hl_by_name(hl_group, true).foreground
      vim.cmd {
      	cmd = "highlight",
      	args = {
          "default",
          string.format("%sNC", hl_group),
          string.format("guifg=#%06x", guifg)}
      }
  	end
  	patch_background()
  end
end


vim.cmd([[
  augroup DAPUIRefreshHighlights
    autocmd!
    autocmd ColorScheme * lua require('dapui.config.highlights').setup()
  augroup END
]])

return M
