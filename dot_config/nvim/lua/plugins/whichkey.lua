return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
	end,
	opts = {
		preset = "modern",

		win = {
			border = "rounded",
			padding = { 1, 2 },
			wo = { winblend = 0 },
		},

		icons = {
			breadcrumb = "»",
			separator = "➜",
			group = "+",
			rules = false,
			colors = true,
		},

		spec = {
			{ "<leader>c", group = "󰘦 Code (LSP)", mode = { "n", "v" } },
			{ "<leader>f", group = " Find (Telescope)", mode = "n" },
			{ "<leader>w", group = " Windows", mode = "n" },
			{ "<leader>d", group = "󰆐 Cut / Delete", mode = { "n", "v" } },
			{ "<leader>n", group = "Messages", mode = "n" },
		},
	},
}
