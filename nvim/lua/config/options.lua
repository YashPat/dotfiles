local opt = vim.opt

opt.number = true
opt.relativenumber = true
-- Click, drag-select, and scroll in normal, visual, insert, and command mode.
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
-- Off so highlight groups use Kitty's ANSI colors instead of fixed hex.
opt.termguicolors = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.wrap = true
opt.confirm = true
opt.inccommand = "split"
