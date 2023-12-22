local lazypath = vim.fn.stdpath("data") .. "/lazy"
vim.notify = print
vim.opt.rtp:append(".")
vim.opt.rtp:append(lazypath .. "/nvim-dap")
vim.opt.rtp:append(lazypath .. "/nvim-nio")

local home = os.getenv("HOME")
vim.opt.rtp:append(home .. "/Dev/nvim-nio")

vim.opt.swapfile = false
vim.cmd("runtime! plugin/plenary.vim")
A = function(...)
  print(vim.inspect(...))
end
