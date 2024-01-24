-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Use map to aliases `vim.keymap.set`
local keymap = vim.keymap.set

-- Use opts for mapping
local opts = { noremap = true, silent = true }

-- Change into normal mode
keymap("i", "jj", "<Esc>")
keymap("i", "kk", "<Esc>")
keymap("i", "jk", "<Esc>")
keymap("i", "kj", "<Esc>")

-- Move text up and down
keymap("x", "J", ":m '>+1<CR>gv=gv", opts)
keymap("x", "K", ":m '<-2<CR>gv=gv", opts)
keymap("x", "<M-j>", ":m '>+1<CR>gv=gv", opts)
keymap("x", "<M-k>", ":m '<-2<CR>gv=gv", opts)

-- Resize window using meta or <option> arrow keys
keymap("n", "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap("n", "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap("n", "<A-Left>", "<cmd>vertical resize +2<cr>", { desc = "Decrease window width" })
keymap("n", "<A-Right>", "<cmd>vertical resize -2<cr>", { desc = "Increase window width" })
