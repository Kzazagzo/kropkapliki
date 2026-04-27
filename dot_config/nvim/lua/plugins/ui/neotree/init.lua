return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	-- enabled = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<C-1>", "<cmd>Neotree toggle<cr>", desc = "Neo-tree (Toggle)" },
	},
	config = function()
		local neotree = require("neo-tree")
		local handlers = require("plugins.neotree.events")
		local core_opts = require("plugins.neotree.opts").get()
		local ui_opts = require("plugins.neotree.ui").get()

		local final_opts = vim.tbl_deep_extend("force", core_opts, ui_opts)
		final_opts.event_handlers = {
			{
				event = "file_added",
				handler = function(file_path)
					handlers.on_file_added(file_path)
				end,
			},
		}

		neotree.setup(final_opts)
	end,
}
