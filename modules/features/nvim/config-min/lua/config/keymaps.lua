local map = vim.keymap.set
vim.g.mapleader = " "

-- Better nav
map({ "n", "v", "x" }, ";", ":")
map({ "n", "v", "x" }, "<leader><leader>", "<leader>ff", { remap = true, desc = "open files" })
map("i", "jk", "<Esc>")

-- Windows
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<CR>")
map("n", "<S-l>", "<cmd>bnext<CR>")
map("n", "<leader>bd", "<cmd>bdelete<CR>")

-- Quick save
map({ "i", "n", "v" }, "<C-s>", "<cmd>w<CR>")

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
	vim.cmd("noh")
	return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })
