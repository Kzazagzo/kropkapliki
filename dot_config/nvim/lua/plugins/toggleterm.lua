return {
	"akinsho/toggleterm.nvim",
	version = "*",
	cmd = { "ToggleTerm" },
	opts = {
		shell = function()
			return vim.fn.executable("fish") == 1 and "fish" or vim.o.shell
		end,
		direction = "float",
		hide_numbers = true,
		start_in_insert = true,
		persist_mode = true,
		close_on_exit = false,
		auto_scroll = true,
		float_opts = {
			border = "rounded",
			winblend = 10,
		},
		on_open = function(term)
			vim.cmd("startinsert!")
			vim.keymap.set("t", "<Esc>", function()
				term:close()
			end, { buffer = term.bufnr })
			vim.keymap.set("t", "<F1>", function()
				vim.cmd("wincmd p")
			end, { buffer = term.bufnr })
		end,
	},
	init = function()
		vim.keymap.set("n", "<F1>", function()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.bo[buf].buftype == "terminal" then
					vim.api.nvim_set_current_win(win)
					vim.cmd("startinsert!")
					return
				end
			end
			vim.cmd("ToggleTerm")
		end, { desc = "Focus terminal" })

		local state = require("core.state").create({
			name = "terminal_session",
			driver = "file",
			default = {},
		})
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				local ok, toggleterm = pcall(require, "toggleterm.terminal")
				if not ok then
					return
				end
				local cwd = vim.fn.getcwd()
				local terms = toggleterm.get_all(true)
				local entry = { open = false, direction = "float" }
				for _, t in ipairs(terms) do
					if t:is_open() then
						entry = { open = true, direction = t.direction }
						break
					end
				end
				local data = state:read()
				data[cwd] = entry
				state:write(data)
			end,
		})
		vim.api.nvim_create_autocmd("DirChanged", {
			callback = function()
				local cwd = vim.fn.getcwd()
				local data = state:read()
				local entry = data[cwd]
				if entry and entry.open then
					vim.schedule(function()
						vim.cmd("ToggleTerm direction=" .. entry.direction)
					end)
				end
			end,
		})
	end,
}
