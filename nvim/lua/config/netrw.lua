-- Left-hand project drawer. :Lexplore keeps this window open and
-- opens files in the window to its right.
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 20
vim.g.netrw_keepdir = 0
vim.g.netrw_hide = 0
vim.g.netrw_list_hide = ""
vim.g.netrw_bufsettings = "noma nomod nonu nornu nowrap ro nobl"

local sidebar_width = 32

local function open_sidebar()
  local dir = nil
  if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
    dir = vim.fn.argv(0)
    vim.cmd("enew")
  end

  if dir then
    vim.cmd("Lexplore " .. vim.fn.fnameescape(dir))
  else
    vim.cmd("Lexplore")
  end

  vim.cmd("wincmd p")
end

vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = open_sidebar,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.opt_local.winfixwidth = true
    vim.cmd("vertical resize " .. sidebar_width)
  end,
})

-- Closing the last editing window should leave Neovim, not the tree.
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function()
    vim.schedule(function()
      local wins = vim.api.nvim_list_wins()
      if #wins == 1 and vim.bo[vim.api.nvim_win_get_buf(wins[1])].filetype == "netrw" then
        vim.cmd("quit")
      end
    end)
  end,
})
