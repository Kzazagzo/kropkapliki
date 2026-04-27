local M = {}

function M.get()
	local fused_borders = {
		prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
		results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
		preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	}

	return {
		defaults = {
			prompt_prefix = "   ",
			selection_caret = " ❯ ",
			entry_prefix = "   ",
			multi_icon = "  ",

			path_display = { "filename_first" },
			dynamic_preview_title = true,

			prompt_title = false,
			results_title = false,
			preview_title = false,

			sorting_strategy = "ascending",
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					preview_width = 0.55,
					results_width = 0.8,
				},
				width = 0.87,
				height = 0.80,
				preview_cutoff = 120,
			},

			borderchars = fused_borders,
		},

		pickers = {

			find_files = {
				prompt_prefix = "   ",
			},

			git_files = {
				prompt_prefix = " 󰊢  ",
				show_untracked = true,
			},

			buffers = {
				prompt_prefix = " 󰸩  ",
				theme = "dropdown",
				previewer = false,
				layout_config = {
					width = 0.4,
					height = 15,
				},
			},

			live_grep = {
				prompt_prefix = " 󰱽  ",
				theme = "ivy",
				layout_config = {
					height = 0.4,
					preview_width = 0.6,
				},
			},

			oldfiles = {
				prompt_prefix = "   ",
				theme = "dropdown",
				previewer = false,
			},

			help_tags = {
				prompt_prefix = " 󰞋  ",
			},
		},
	}
end

return M

