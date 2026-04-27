return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		vim.g.terminal_color_2 = "#6AAB73"
		vim.g.terminal_color_10 = "#6AAB73"
		vim.g.terminal_color_3 = "#CF8E6D"
		vim.g.terminal_color_11 = "#CF8E6D"
		vim.g.terminal_color_8 = "#7A7E85"

		local config_opts = {
			theme = "doom",
			config = {
				header = {},
				center = {
					{ icon = "󰈞  ", desc = "Find File          ", key = "f", action = "Telescope find_files" },
					{ icon = "  ", desc = "Recent Files       ", key = "r", action = "Telescope oldfiles" },
					{ icon = "  ", desc = "New File           ", key = "n", action = "enew" },
					{ icon = "󰒲  ", desc = "Lazy               ", key = "l", action = "Lazy" },
					{ icon = "  ", desc = "Quit               ", key = "q", action = "qa" },
				},
				footer = {},
			},
		}

		if vim.fn.executable("rbonsai") == 1 then
			config_opts.preview = {
				command = "rbonsai -l -i -t 0.2 -w 5 -L 25 -M 2 -b 2",
				file_path = "",
				file_height = 15,
				file_width = 60,
			}
		end

		require("dashboard").setup(config_opts)
	end,
}
