local map = vim.keymap.set

local function action(name, opts)
  return function()
    require("vscode").action(name, opts)
  end
end

-- UI
map("n", "<leader>e", action("workbench.view.explorer"), { desc = "Toggle explorer" })
map("n", "<leader>?", action("workbench.action.showCommands"), { desc = "Command palette" })

-- Terminal
map("n", "<leader>t", action("workbench.action.terminal.toggleTerminal"), { desc = "Toggle terminal" })

-- Search
map("n", "<leader><space>", action("workbench.action.quickOpen"), { desc = "Find files" })
map("n", "<leader>fb", action("workbench.action.showAllEditors"), { desc = "Find buffers" })
map("n", "<leader>fk", action("workbench.action.openGlobalKeybindings"), { desc = "Find keymaps" })
map("n", "<leader>/", action("workbench.action.findInFiles"), { desc = "Live grep" })
map("n", "<leader>fz", action("actions.find"), { desc = "Fuzzy search in buffer" })
map("n", "<leader>fd", action("workbench.actions.view.problems"), { desc = "Find diagnostics" })

-- Buffers
map("n", "<leader>bd", action("workbench.action.closeActiveEditor"), { desc = "Delete Buffer" })

-- LSP
map("n", "gd", action("editor.action.revealDefinition"), { desc = "Goto Definition" })
map("n", "gD", action("editor.action.revealDeclaration"), { desc = "Goto Declaration" })
map("n", "gr", action("editor.action.goToReferences"), { desc = "References", nowait = true })
map("n", "gI", action("editor.action.goToImplementation"), { desc = "Goto Implementation" })
map("n", "gt", action("editor.action.goToTypeDefinition"), { desc = "Goto Type Definition" })
map("n", "gai", action("editor.showIncomingCalls"), { desc = "C[a]lls Incoming" })
map("n", "gao", action("editor.showOutgoingCalls"), { desc = "C[a]lls Outgoing" })
map("n", "<leader>fs", action("workbench.action.gotoSymbol"), { desc = "LSP Symbols" })
map("n", "<leader>fS", action("workbench.action.showAllSymbols"), { desc = "LSP Workspace Symbols" })
map({ "n", "x", "v" }, "<leader>ca", action("editor.action.quickFix"), { desc = "Code Action" })
map({ "n", "v" }, "<leader>cd", action("editor.action.showHover"), { desc = "Show diagnostics" })
map("n", "<leader>ct", action("workbench.actions.view.problems"), { desc = "Open problems" })
