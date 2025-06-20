-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

map("n", "<C-q>", "<cmd>qa<cr>", { noremap = true, silent = true })
map("n", "ç", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", { noremap = true, silent = true })
map("i", "<S-Tab>", "<Tab>", { noremap = true, silent = true })
map("n", "<leader>ce", ":EditCodeBlock<CR>:LspRestart<CR>", { noremap = true, silent = true, desc = "Edit Code Block" })

map("n", "<leader>gd", function()
  LazyVim.terminal.open({ "lazydocker" }, { esc_esc = false, ctrl_hjkl = false })
end, { desc = "Lazydocker" })

map("i", "jf", function()
  return vim.fn["codeium#Accept"]()
end, { expr = true, silent = true })

map("n", "q", function()
  if #vim.api.nvim_list_bufs() > 1 then
    vim.cmd("bd")
  else
    vim.cmd("qa") -- Quit all if it's the last buffer
  end
end, { noremap = true, silent = true, desc = "Close buffer or quit Neovim" })
