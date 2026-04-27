return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {
		labels = "asdfghjklqwertyuiopzxcvbnm",
		search = {
			mode = "fuzzy",
		},
		modes = {
			char = {
				enabled = false,
				jump_labels = true,
				multi_line = true,
			},
		},
	},
	keys = {
		{
			"<leader><leader>s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash (EasyMotion s)",
		},
		{
			"<leader><leader>w",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({
					search = { mode = "search", max_length = 0 },
					label = { after = { 0, 0 } },
					pattern = [[\b\w\w+\b]],
				})
			end,
			desc = "Hop to Word",
		},

		{
			"<leader><leader>f",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({ continue = true, search = { forward = true, wrap = false, multi_line = false } })
			end,
			desc = "Hop forward char",
		},
		{
			"<leader><leader>F",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump({
					continue = true,
					search = { forward = false, wrap = false, multi_line = false },
				})
			end,
			desc = "Hop backward char",
		},

		{
			"<leader><leader>S",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
	},
}
