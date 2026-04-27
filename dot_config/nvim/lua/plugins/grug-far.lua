return {
	"MagicDuck/grug-far.nvim",
	cmd = "GrugFar",
	keys = {
		{
			"<leader>fr",
			function()
				require("grug-far").open({ transient = true })
			end,
			desc = "Search & Replace",
		},
	},
	config = function()
		vim.api.nvim_create_user_command("GrugFarFloat", function()
			local w = math.floor(vim.o.columns * 0.8)
			local h = math.floor(vim.o.lines * 0.8)
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				width = w,
				height = h,
				col = math.floor((vim.o.columns - w) / 2),
				row = math.floor((vim.o.lines - h) / 2),
				style = "minimal",
				border = "rounded",
			})
		end, {})

		require("grug-far").setup({
			windowCreationCommand = "GrugFarFloat",
			resultsHighlight = true,
			inputsHighlight = true,
			showCompactInputs = true,
			helpLine = { enabled = true },
			keymaps = {
				close = { n = "q", i = "<C-c>" },
				replace = { n = "<C-r>" },
			},
		})

		local function fix_hl()
			local hl = vim.api.nvim_set_hl
			hl(0, "GrugFarResultsMatch", { bg = "NONE", fg = "NONE", underline = true, sp = "Yellow" })
			hl(0, "GrugFarResultsMatchAdded", { link = "DiffAdd" })
			hl(0, "GrugFarResultsMatchRemoved", { link = "DiffDelete" })
			hl(0, "GrugFarInputLabel", { link = "Function" })
			hl(0, "GrugFarResultsPath", { link = "Comment" })
		end
		fix_hl()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = fix_hl })

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "grug-far",
			callback = function(evt)
				local buf = evt.buf
				local get = function()
					return require("grug-far").get_instance(buf)
				end
				vim.keymap.set("n", "<Esc>", function()
					get():close()
				end, { buffer = buf })
				vim.keymap.set({ "n", "i" }, "<Down>", function()
					get():goto_next_input()
				end, { buffer = buf })
				vim.keymap.set({ "n", "i" }, "<Up>", function()
					get():goto_prev_input()
				end, { buffer = buf })
			end,
		})
	end,
}
