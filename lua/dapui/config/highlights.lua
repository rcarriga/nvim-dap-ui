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

  ---gets the argument highlight group information, using the newer `nvim_get_hl` if available
  ---@param highlight string highlight group
  ---@return table hl highlight information
  local function get_highlight(highlight)
    local ok, hl
    if vim.fn.has("nvim-0.9") == 1 then
      ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = highlight })
      if not ok then -- highlight group is invalid
        return vim.empty_dict()
      end
    else
      ok, hl = pcall(vim.api.nvim_get_hl_by_name, highlight, true)
      if not ok or hl[true] then -- highlight group is invalid or cleared
        return vim.empty_dict()
      end
      -- change `nvim_get_hl_by_name` output into `nvim_get_hl` output format
      hl.bg = hl.background
      hl.fg = hl.foreground
    end
    return hl
  end

  -- Generate *NC variants of the control highlight groups
  if vim.fn.has("nvim-0.8") == 1 then
    local bg = get_highlight("WinBar").bg
    local bgNC = get_highlight("WinBarNC").bg

    for _, hl_group in pairs(control_hl_groups) do
      local gui = get_highlight(hl_group)
      -- if highlight group is cleared or invalid, skip
      if not vim.tbl_isempty(gui) then
        gui.default = true
        if gui.bg ~= bg then
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
