local M = {}

local control_hl_groups = {
  "DapUINormal",
  "DapUIPlayPause",
  "DapUIRestart",
  "DapUIStop",
  "DapUIUnavailable",
  "DapUIStepOver",
  "DapUIStepInto",
  "DapUIStepBack",
  "DapUIStepOut",
}

function M.setup()
  vim.cmd([[
  hi default link DapUINormal Normal
  hi default link DapUIVariable Normal
  hi default DapUIScope guifg=#00F1F5
  hi default DapUIType guifg=#D484FF
  hi default link DapUIValue Normal
  hi default DapUIModifiedValue guifg=#00F1F5 gui=bold
  hi default DapUIDecoration guifg=#00F1F5
  hi default DapUIThread guifg=#A9FF68
  hi default DapUIStoppedThread guifg=#00f1f5
  hi default link DapUIFrameName Normal
  hi default DapUISource guifg=#D484FF
  hi default DapUILineNumber guifg=#00f1f5
  hi default link DapUIFloatNormal NormalFloat
  hi default DapUIFloatBorder guifg=#00F1F5
  hi default DapUIWatchesEmpty guifg=#F70067
  hi default DapUIWatchesValue guifg=#A9FF68
  hi default DapUIWatchesError guifg=#F70067
  hi default DapUIBreakpointsPath guifg=#00F1F5
  hi default DapUIBreakpointsInfo guifg=#A9FF68
  hi default DapUIBreakpointsCurrentLine guifg=#A9FF68 gui=bold
  hi default link DapUIBreakpointsLine DapUILineNumber
  hi default DapUIBreakpointsDisabledLine guifg=#424242
  hi default link DapUICurrentFrameName DapUIBreakpointsCurrentLine
  hi default DapUIStepOver guifg=#00f1f5
  hi default DapUIStepInto guifg=#00f1f5
  hi default DapUIStepBack guifg=#00f1f5
  hi default DapUIStepOut guifg=#00f1f5
  hi default DapUIStop guifg=#F70067
  hi default DapUIPlayPause guifg=#A9FF68
  hi default DapUIRestart guifg=#A9FF68
  hi default DapUIUnavailable guifg=#424242
  hi default DapUIWinSelect ctermfg=Cyan guifg=#00f1f5 gui=bold
  hi default link DapUIEndofBuffer EndofBuffer
  ]])

  -- Generate *NC variants of the control highlight groups
  if vim.fn.has("nvim-0.8") == 1 then
    local bg, bgNC
    local exists, hl = pcall(vim.api.nvim_get_hl_by_name, "WinBar", true)
    if exists then
      bg = hl.background
    end
    exists, hl = pcall(vim.api.nvim_get_hl_by_name, "WinBarNC", true)
    if exists then
      bgNC = hl.background
    end

    for _, hl_group in pairs(control_hl_groups) do
      local gui = vim.api.nvim_get_hl_by_name(hl_group, true)
      if not gui[true] then -- https://github.com/rcarriga/nvim-dap-ui/issues/233
        if gui.background ~= bg then
          gui.bg = bg
          vim.api.nvim_set_hl(0, hl_group, gui)
        end
        gui.bg = bgNC
        vim.api.nvim_set_hl(0, hl_group .. "NC", gui)
      end
    end
  else
    for _, hl_group in pairs(control_hl_groups) do
      vim.cmd(string.format("hi default link %sNC %s", hl_group, hl_group))
    end
  end
end

vim.cmd([[
  augroup DAPUIRefreshHighlights
    autocmd!
    autocmd ColorScheme * lua require('dapui.config.highlights').setup()
  augroup END
]])

return M
