return {
	"nvim-telescope/telescope.nvim",
	cmd = { "Telescope" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-live-grep-args.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-telescope/telescope-smart-history.nvim",
		"debugloop/telescope-undo.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		local ctrl = require("plugins.telescope.actions").get(actions)
		local core_opts = require("plugins.telescope.opts").get(actions, ctrl)
		local ext_config, ext_load = require("plugins.telescope.extensions").get()
		local ui_opts = require("plugins.telescope.ui").get()

		local final_opts = vim.tbl_deep_extend("force", core_opts, ui_opts)
		final_opts.extensions = ext_config

		telescope.setup(final_opts)

		for _, ext in ipairs(ext_load) do
			pcall(telescope.load_extension, ext)
		end
	end,
}
