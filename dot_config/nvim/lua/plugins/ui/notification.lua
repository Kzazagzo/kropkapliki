return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
				opts = {
					position = { row = "30%", col = "50%" },
					size = { width = 60 },
				},
			},
			messages = {
				enabled = true,
				view = "notify",
				view_error = "notify",
				view_warn = "notify",
			},
			popupmenu = {
				enabled = true,
				backend = "nui",
			},
			notify = {
				enabled = true,
				view = "notify",
			},
			lsp = {
				progress = { enabled = false },
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			presets = {
				bottom_search = true,
			},
			commands = {
				errors = {
					view = "split",
					opts = { enter = true, format = "details" },
					filter = {
						any = {
							{ error = true },
							{ event = "notify", kind = "error" },
							{ event = "notify", kind = "warn" },
						},
					},
					filter_opts = { reverse = true },
				},
			},
			routes = {
				{
					filter = { event = "msg_show", kind = "emsg" },
					view = "notify",
				},
			},
		},
		keys = {
			{
				"<leader>:",
				"<cmd>Telescope command_history<cr>",
				desc = "Command history",
			},
			{
				"<leader>fc",
				"<cmd>Telescope commands<cr>",
				desc = "Commands",
			},
			{ "<leader>n", "<cmd>Noice errors<cr>", desc = "Error history" },
		},
	},
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			progress = {
				suppress_on_insert = true,
				display = {
					done_ttl = 1,
					skip_history = true,
				},
			},
			notification = {
				override_vim_notify = false,
				window = {
					winblend = 0,
					border = "none",
					align = "bottom",
				},
			},
		},
	},
}
