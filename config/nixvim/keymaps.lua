local map = vim.keymap.set

-- Window and visual navigation
for _, letter in ipairs({ "h", "j", "k", "l" }) do
  map("n", string.format("<C-%s>", letter), string.format("<C-w>%s", letter))
  map({ "n", "v" }, letter, "g" .. letter)
end

-- UI
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neotree" })

-- LSP
map({ "n", "v" }, "<leader>cd", vim.diagnostic.open_float)
map("n", "<leader>cr", "<cmd>Lspsaga rename<cr>")
map("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>")

-- Terminal
map("t", "<ESC>", [[<C-\><C-n>]])
map("n", "<leader>t", "<cmd>terminal<cr>")

-- Search
map("n", "<leader><space>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })
map("n", "<leader>/", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Resume search" })
map("n", "<leader>fm", "<cmd>Telescope man_pages<cr>", { desc = "Find man pages" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Fuzzy search in buffer" })

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
