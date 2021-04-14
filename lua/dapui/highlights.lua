local M = {}

function M.setup()
  vim.cmd("hi default link DapUIVariable Normal")
  vim.cmd("hi default DapUIScope guifg=#00F1F5")
  vim.cmd("hi default DapUIType guifg=#D484FF")
  vim.cmd("hi default DapUIDecoration guifg=#00F1F5")
  vim.cmd("hi default DapUIThread guifg=#A9FF68")
  vim.cmd("hi default DapUIStoppedThread guifg=#00f1f5")
  vim.cmd("hi default link DapUIFrameName Normal")
  vim.cmd("hi default DapUIFrameSource guifg=#D484FF")
  vim.cmd("hi default DapUILineNumber guifg=#00f1f5")
  vim.cmd("hi default DapUIFloatBorder guifg=#00F1F5")
  vim.cmd("hi default DapUIWatchesHeader guifg=#00F1F5")
  vim.cmd("hi default DapUIWatchesEmpty guifg=#F70067")
  vim.cmd("hi default DapUIWatchesValue guifg=#A9FF68")
  vim.cmd("hi default DapUIWatchesError guifg=#F70067")
  vim.cmd("hi default DapUIWatchesFrame guifg=#D484FF")
end

return M
