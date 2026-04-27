local map = vim.keymap.set

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files (Telescope)" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers (Telescope)" })
map("n", "<leader>fg", "<cmd>Telescope live_grep_args<cr>", { desc = "Find in text (Telescope)" })
map("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs (Telescope)" })
map("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "Undo Tree (Telescope)" })
map("n", "<leader>r", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files" })

map("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "Yazi (Terminal FM)" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Edit folder (Oil)" })

map("n", "<A-a>", "<cmd>Harpoon add<cr>", { desc = "Add to Harpoon" })
map("n", "<leader>h", "<cmd>Harpoon menu<cr>", { desc = "Harpoon menu" })
map("n", "<A-1>", "<cmd>Harpoon select 1<cr>", { desc = "Harpoon: Go to 1" })
map("n", "<A-2>", "<cmd>Harpoon select 2<cr>", { desc = "Harpoon: Go to 2" })
map("n", "<A-3>", "<cmd>Harpoon select 3<cr>", { desc = "Harpoon: Go to 3" })
map("n", "<A-4>", "<cmd>Harpoon select 4<cr>", { desc = "Harpoon: Go to 4" })

vim.keymap.set({ "n", "i", "v" }, "<C-M-l>", "<cmd>Pretty<cr>", { desc = "Pretty" })

map("n", "<leader>t", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble Diagnostics" })

map("n", "<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Command history" })
map("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Commands" })

map("n", "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal (float)" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=60<cr>", { desc = "Terminal (vsplit)" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal size=15<cr>", { desc = "Terminal (hsplit)" })

map({ "n", "i", "v" }, "<A-CR>", vim.lsp.buf.code_action, { desc = "Code Action" })
