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
  hi default link DapUINormal                  Normal
  hi default link DapUIVariable                Normal
  hi default link DapUIScope                   Identifier
  hi default link DapUIType                    Type
  hi default link DapUIValue                   Normal
  hi default link DapUIModifiedValue           Function
  hi default link DapUIDecoration              Identifier
  hi default link DapUIThread                  Identifier
  hi default link DapUIStoppedThread           Function
  hi default link DapUIFrameName               Normal
  hi default link DapUISource                  Define
  hi default link DapUILineNumber              LineNr
  hi default link DapUIFloatNormal             NormalFloat
  hi default link DapUIFloatBorder             Identifier
  hi default link DapUIWatchesEmpty            PreProc
  hi default link DapUIWatchesValue            Statement
  hi default link DapUIWatchesError            PreProc
  hi default link DapUIBreakpointsPath         Identifier
  hi default link DapUIBreakpointsInfo         Statement
  hi default link DapUIBreakpointsCurrentLine  CursorLineNr
  hi default link DapUIBreakpointsLine         DapUILineNumber
  hi default link DapUIBreakpointsDisabledLine Comment
  hi default link DapUICurrentFrameName        DapUIBreakpointsCurrentLine
  hi default link DapUIStepOver                Label
  hi default link DapUIStepInto                Label
  hi default link DapUIStepBack                Label
  hi default link DapUIStepOut                 Label
  hi default link DapUIStop                    PreProc
  hi default link DapUIPlayPause               Repeat
  hi default link DapUIRestart                 Repeat
  hi default link DapUIUnavailable             Comment
  hi default link DapUIWinSelect               Special
  hi default link DapUIEndofBuffer             EndofBuffer
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
