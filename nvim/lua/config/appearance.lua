-- Transparent window, syntax from Kitty's 16 colors. A theme reload in
-- Kitty changes these colors with the terminal. Color 8 is unused: some
-- themes set it to black, which hides comments.
local M = {}

local clear = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "SignColumn",
  "StatusLine",
  "StatusLineNC",
  "WinSeparator",
  "VertSplit",
  "EndOfBuffer",
  "FoldColumn",
  "FloatBorder",
}

local colors = {
  LineNr = 6,
  NonText = 6,
  Comment = 6,
  Constant = 5,
  String = 2,
  Character = 2,
  Number = 3,
  Boolean = 5,
  Float = 3,
  Function = 4,
  Statement = 5,
  Conditional = 5,
  Repeat = 5,
  Operator = 6,
  Keyword = 5,
  Exception = 1,
  PreProc = 1,
  Type = 3,
  Special = 6,
  Directory = 4,
  Title = 4,
  Error = 1,
  DiagnosticError = 1,
  DiagnosticWarn = 3,
  DiagnosticInfo = 4,
  DiagnosticHint = 6,
  DiffAdd = 2,
  DiffChange = 3,
  DiffDelete = 1,
  GitSignsAdd = 2,
  GitSignsChange = 3,
  GitSignsDelete = 1,
  NetrwDir = 4,
  NetrwClassify = 6,
}

local function apply()
  local none = { bg = "NONE", ctermbg = "NONE" }
  for _, name in ipairs(clear) do
    vim.api.nvim_set_hl(0, name, none)
  end

  for name, ctermfg in pairs(colors) do
    vim.api.nvim_set_hl(0, name, { ctermfg = ctermfg, bg = "NONE", ctermbg = "NONE" })
  end

  vim.api.nvim_set_hl(0, "Comment", { ctermfg = 6, italic = true, bg = "NONE", ctermbg = "NONE" })
  vim.api.nvim_set_hl(0, "Visual", { reverse = true })
  vim.api.nvim_set_hl(0, "Search", { reverse = true })
  vim.api.nvim_set_hl(0, "IncSearch", { reverse = true })
  vim.api.nvim_set_hl(0, "CurSearch", { reverse = true })
  vim.api.nvim_set_hl(0, "Pmenu", { reverse = true })
  vim.api.nvim_set_hl(0, "PmenuSel", { ctermfg = 0, ctermbg = 6 })
  vim.api.nvim_set_hl(0, "MatchParen", { ctermfg = 6, bold = true, bg = "NONE", ctermbg = "NONE" })
end

function M.setup()
  vim.cmd.colorscheme("default")
  apply()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      vim.schedule(apply)
    end,
  })
end

return M
