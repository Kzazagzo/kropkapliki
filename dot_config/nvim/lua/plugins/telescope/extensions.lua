local M = {}

function M.get()
	local lga_actions = require("telescope-live-grep-args.actions")

	local config = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
		live_grep_args = {
			auto_quoting = true,
			mappings = {
				i = { ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --iglob " }) },
			},
		},
		["ui-select"] = { require("telescope.themes").get_dropdown({ layout_config = { width = 0.6, height = 0.5 } }) },
		undo = {},
	}

	local load = { "fzf", "ui-select", "live_grep_args", "undo" }

	return config, load
end

return M
