require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Move between nvim splits and tmux panes (vim-tmux-navigator)
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Window/pane left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Window/pane down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Window/pane up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Window/pane right" })

map("n", "<leader>gd", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git preview hunk diff" })
map("n", "<leader>gbh", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Git reset hunk" })
map("n", "<leader>gbl", "<cmd>Gitsigns blame<CR>", { desc = "Git blame" })

map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "LSP diagnostic open float" })

map("n", "<leader>fm", function()
  require("conform").format { async = true, lsp_format = "fallback" }
end, { desc = "Format file" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
