local map = vim.keymap.set

-- Window and visual navigation
for _, letter in ipairs({ "h", "j", "k", "l" }) do
  map("n", string.format("<C-%s>", letter), string.format("<C-w>%s", letter))
end

map({ "n", "v" }, "j", "gj")
map({ "n", "v" }, "k", "gk")

-- UI
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neotree" })

-- LSP
map({ "n", "v" }, "<leader>cd", vim.diagnostic.open_float)

-- Terminal
map("t", "<ESC>", [[<C-\><C-n>]])
map("n", "<leader>t", "<cmd>terminal<cr>")

-- Search
map("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Find files" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Find buffers" })
map("n", "<leader>fk", function() Snacks.picker.keymaps() end, { desc = "Find keymaps" })
map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Live grep" })
map("n", "<leader>fr", function() Snacks.picker.resume() end, { desc = "Resume search" })
map("n", "<leader>fm", function() Snacks.picker.man() end, { desc = "Find man pages" })
map("n", "<leader>fz", function() Snacks.picker.grep_buffers() end, { desc = "Fuzzy search in buffer" })
map("n", "<leader>fd", function() Snacks.picker.diagnostics() end, { desc = "Find diagnostics" })

map("n", "<leader>?", "<cmd>WhichKey<cr>")

local luasnip = require("luasnip")
-- Luasnip
map("i", "<C-k>", luasnip.expand)
map("i", "<C-j>", function() luasnip().jump(1) end)
map("i", "<C-l>", function() luasnip.jump(-1) end)

-- Leap
map({ "n", "x", "o" }, "s", "<Plug>(leap)")
map("n", "S", "<Plug>(leap-from-window)")

-- Jujutsu
local cmd = require("jj.cmd")
local annotate = require("jj.annotate")
map("n", "<leader>jd", cmd.describe, { desc = "JJ describe" })
map("n", "<leader>jl", cmd.log, { desc = "JJ log" })
map("n", "<leader>ja", annotate.file, { desc = "JJ annotate file" })
map("n", "<leader>jA", annotate.line, { desc = "JJ annotate line" })
map("n", "<leader>jd", cmd.describe, { desc = "JJ describe" })
map("n", "<leader>jn", cmd.describe, { desc = "JJ new" })

-- Buffers
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })

-- LSP
map("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Goto Definition" })
map("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Goto Declaration" })
map("n", "gr", function() Snacks.picker.lsp_references() end, { desc = "References", nowait = true })
map("n", "gI", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
map("n", "gy", function() Snacks.picker.lsp_implementations() end, { desc = "Goto T[y]pe Definition" })
map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("n", "gai", function() Snacks.picker.lsp_incoming_calls() end, { desc = "C[a]lls Incoming" })
map("n", "gao", function() Snacks.picker.lsp_incoming_calls() end, { desc = "C[a]lls Outgoing" })
map("n", "<leader>fs", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols" })
map("n", "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens" })
map("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh Codelens" })
map("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format" })

map({ "n", "i" }, "<c-t>", function() require("trouble").toggle() end, { desc = "Toggle Trouble" })
