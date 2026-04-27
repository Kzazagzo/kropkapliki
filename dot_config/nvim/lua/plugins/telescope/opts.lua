local M = {}

function M.get(actions, custom_actions)
	return {
		defaults = {
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--hidden",
				"--trim",
			},
			file_ignore_patterns = {
				"%.git/",
				"node_modules/",
				"%.npm/",
				"__pycache__/",
				"target/",
				"dist/",
				"%.pdf",
				"%.jpg",
				"%.png",
				"%.zip",
				"%.exe",
				"%.so",
				"%.dll",
			},
			mappings = {
				i = {
					["<C-j>"] = actions.move_selection_next,
					["<C-k>"] = actions.move_selection_previous,
					["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					["<Esc>"] = actions.close,
					["<CR>"] = custom_actions.select_one_or_multi,

					["<C-g>"] = custom_actions.switch_picker("live_grep"),
					["<C-f>"] = custom_actions.switch_picker("find_files"),

					["<C-Down>"] = actions.preview_scrolling_down,
					["<C-Up>"] = actions.preview_scrolling_up,
					["<A-a>"] = custom_actions.add_to_harpoon,
				},
				n = { ["q"] = actions.close },
			},
		},
		pickers = {
			find_files = {
				find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
			},
			buffers = {
				initial_mode = "normal",
				mappings = { n = { ["d"] = actions.delete_buffer } },
			},
		},
	}
end

return M
