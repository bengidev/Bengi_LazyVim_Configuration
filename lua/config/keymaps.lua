-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Use map to aliases `vim.keymap.set`
local map = vim.keymap.set

-- Change into normal mode
map("i", "jj", "<Esc>")
map("i", "kk", "<Esc>")
map("i", "jk", "<Esc>")
map("i", "kj", "<Esc>")
