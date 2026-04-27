local map = vim.keymap.set

map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-Down>", "<Esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-Up>", "<Esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

map("x", "p", '"_dP', { desc = "Paste without yanking replaced text" })
map({ "n", "v" }, "d", '"_d', { desc = "Delete without yanking" })
map("n", "dd", '"_dd', { desc = "Delete line without yanking" })
map("n", "D", '"_D', { desc = "Delete to end of line without yanking" })
map({ "n", "v" }, "c", '"_c', { desc = "Change without yanking" })
map("n", "cc", '"_cc', { desc = "Change line without yanking" })
map("n", "C", '"_C', { desc = "Change to end of line without yanking" })
map({ "n", "v" }, "x", "d", { desc = "Cut (yank + delete)" })
map("n", "X", "D", { desc = "Cut to EOL" })

map("n", "<leader>vs", "<cmd>vsplit<CR>", { desc = "Vertical Split" })
map("n", "<leader>hs", "<cmd>split<CR>", { desc = "Horizontal Split" })
map("n", "<leader><Left>", "<C-w>h", { desc = "Go to left window" })
map("n", "<leader><Down>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<leader><Up>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<leader><Right>", "<C-w>l", { desc = "Go to right window" })
map("n", "<leader>ww", "<C-w>w", { desc = "Cycle windows" })

map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { silent = true })
map({ "n", "i", "v" }, "<C-z>", "<cmd>undo<cr>", { noremap = true, silent = true })
map({ "n", "i", "v" }, "<C-S-z>", "<cmd>redo<cr>", { noremap = true, silent = true })
map({ "n", "i", "v" }, "<C-y>", "<cmd>redo<cr>", { noremap = true, silent = true })

map({ "n", "v" }, "<X1Mouse>", "<C-o>", { desc = "Jump back (mouse)" })
map({ "n", "v" }, "<X2Mouse>", "<C-i>", { desc = "Jump forward (mouse)" })
map("i", "<X1Mouse>", "<C-\\><C-n><C-o>", { desc = "Jump back (mouse)" })
map("i", "<X2Mouse>", "<C-\\><C-n><C-i>", { desc = "Jump forward (mouse)" })
