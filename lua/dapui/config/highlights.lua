local M = {}

local control_hl_groups = {
  'DapUIPlayPause', 'DapUIRestart', 'DapUIStop', 'DapUIUnavailable',
  'DapUIStepOver', 'DapUIStepInto', 'DapUIStepBack', 'DapUIStepOut',
}

---Applies the background color from the template highlight group to all
---control icon highlight groups.
---@param template_group string  Name of highlight group
---@return nil
function M.patch_background(template_group)
  local guibg = vim.api.nvim_get_hl_by_name(template_group, true).background
  for _, hl_group in ipairs(control_hl_groups) do
    vim.cmd {
      cmd = "highlight",
      args = {hl_group, guibg and string.format("guibg=#%06x", guibg) or "guibg=NONE"}
    }
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

  M.patch_background("WinBar")
end


vim.cmd([[
  augroup DAPUIRefreshHighlights
    autocmd!
    autocmd ColorScheme * lua require('dapui.config.highlights').setup()
    autocmd WinEnter *dap-repl* lua require('dapui.config.highlights').patch_background('WinBar')
    autocmd WinLeave *dap-repl* lua require('dapui.config.highlights').patch_background('WinBarNC')
  augroup END
]])

return M
