-- Keymaps shared between plain neovim and vscode-neovim.
local map = vim.keymap.set

-- Window and visual navigation
for _, letter in ipairs({ "h", "j", "k", "l" }) do
  map("n", string.format("<C-%s>", letter), string.format("<C-w>%s", letter), { remap = true })
end

map({ "n", "v" }, "j", "gj")
map({ "n", "v" }, "k", "gk")

-- Leap
map({ "n", "x", "o" }, "s", "<Plug>(leap)")
map("n", "S", "<Plug>(leap-from-window)")

-- LSP
-- resolve functions late, vscode replaces them
map("n", "gK", function() vim.lsp.buf.signature_help() end, { desc = "Signature Help" })
map("i", "<c-k>", function() vim.lsp.buf.signature_help() end, { desc = "Signature Help" })
map("n", "K", function() vim.lsp.buf.hover() end, { desc = "Hover" })
map("n", "<leader>cr", function() vim.lsp.buf.rename() end, { desc = "Rename" })
map("n", "<leader>cf", function() vim.lsp.buf.format() end, { desc = "Format" })
