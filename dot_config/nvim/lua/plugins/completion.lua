return {
	{
		"saghen/blink.cmp",
		lazy = false,
		version = "*",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"L3MON4D3/LuaSnip",
		},
		opts = {
			keymap = { preset = "super-tab" },
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = {
						score_offset = 100,
						transform_items = function(_, items)
							if vim.tbl_contains({ "css", "scss", "less" }, vim.bo.filetype) then
								local Kind = require("blink.cmp.types").CompletionItemKind
								return vim.tbl_filter(function(item)
									return item.kind ~= Kind.Function and item.kind ~= Kind.Snippet
								end, items)
							end
							return items
						end,
					},
					snippets = { score_offset = 50 },
					buffer = { score_offset = -10 },
				},
			},
			signature = { enabled = true },
			completion = {
				list = {
					selection = { preselect = false, auto_insert = false },
				},
				ghost_text = { enabled = false },
				accept = {
					auto_brackets = { enabled = true },
				},
				menu = {
					border = "rounded",
					draw = {
						treesitter = { "lsp" },
						columns = {
							{ "kind_icon", gap = 1 },
							{ "label", "label_description", gap = 1 },
							{ "kind" },
						},
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 100,
					window = { border = "rounded" },
				},
			},
		},
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "InsertEnter",
		opts = {
			bind = true,
			floating_window = true,
			hint_enable = true,
			hint_prefix = "󰏫 ",
			handler_opts = { border = "rounded" },
		},
	},
}
