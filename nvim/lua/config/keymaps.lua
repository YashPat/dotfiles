local map = vim.keymap.set

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Stay in the middle of the screen while moving through search hits.
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Move lines in visual mode.
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Window navigation.
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

local function save()
  if vim.bo.buftype ~= "" then
    return
  end
  vim.cmd("silent write")
end

-- Ctrl-S in normal, insert, and visual mode. The shell must not swallow Ctrl-S
-- (see `stty -ixon` in zshrc).
map({ "n", "i", "x" }, "<C-s>", save, { desc = "Save" })

-- Write a named, modified file buffer. Skips terminals, help, and untitled buffers.
local function autosave(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modified then
    return
  end
  if vim.api.nvim_buf_get_name(buf) == "" then
    return
  end
  vim.api.nvim_buf_call(buf, function()
    vim.cmd("silent! update")
  end)
end

local autosave_timer = vim.uv.new_timer()
local autosave_group = vim.api.nvim_create_augroup("user_autosave", { clear = true })

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
  group = autosave_group,
  callback = function(event)
    autosave_timer:stop()
    autosave_timer:start(1000, 0, vim.schedule_wrap(function()
      autosave(event.buf)
    end))
  end,
})

vim.api.nvim_create_autocmd("FocusLost", {
  group = autosave_group,
  callback = function(event)
    autosave_timer:stop()
    autosave(event.buf)
  end,
})

-- Leader
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>e", "<cmd>Lexplore<CR>", { desc = "File tree" })

map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_keys", { clear = true }),
  callback = function(event)
    local buf = event.buf
    local function bmap(lhs, rhs, desc)
      map("n", lhs, rhs, { buffer = buf, desc = desc })
    end

    bmap("gd", vim.lsp.buf.definition, "Go to definition")
    bmap("gr", vim.lsp.buf.references, "References")
    bmap("K", vim.lsp.buf.hover, "Hover")
    bmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("<leader>cr", vim.lsp.buf.rename, "Rename")
    bmap("<leader>cf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format")
    bmap("[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Previous diagnostic")
    bmap("]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Next diagnostic")
  end,
})
