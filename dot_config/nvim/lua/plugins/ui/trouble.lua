return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "Trouble",
	opts = {
		modes = {
			diagnostics = {
				auto_close = true,
				filter = {
					any = {
						buf = 0,
						{
							severity = vim.diagnostic.severity.ERROR,
							min_severity = vim.diagnostic.severity.WARN,
						},
					},
				},
			},
		},
	},
}
