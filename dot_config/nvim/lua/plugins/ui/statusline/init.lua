return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	config = function()
		local bubbles = {
			action = require("plugins.ui.statusline.bubbles.action"),
			git = require("plugins.ui.statusline.bubbles.git"),
			permissions = require("plugins.ui.statusline.bubbles.permissions"),
			diagnostics = require("plugins.ui.statusline.bubbles.diagnostics"),
		}

		local function apply_truncation(component)
			local original_cond = component.cond
			local level_raw = component._level

			component.cond = function()
				local width = vim.api.nvim_win_get_width(0)
				local level = type(level_raw) == "function" and level_raw() or level_raw

				local is_visible = true
				if width < 50 then
					is_visible = level >= 9
				elseif width < 80 then
					is_visible = level >= 7
				elseif width < 110 then
					is_visible = level >= 4
				end

				if not is_visible then
					return false
				end
				return original_cond == nil or original_cond()
			end
			return component
		end

		for _, b in pairs(bubbles) do
			apply_truncation(b)
		end

		local transparent_theme = {
			normal = {
				a = { bg = "NONE", fg = "NONE" },
				b = { bg = "NONE", fg = "NONE" },
				c = { bg = "NONE", fg = "NONE" },
				x = { bg = "NONE", fg = "NONE" },
				y = { bg = "NONE", fg = "NONE" },
				z = { bg = "NONE", fg = "NONE" },
			},
		}

		require("lualine").setup({
			options = {
				theme = transparent_theme,
				component_separators = "  ",
				section_separators = { left = "  ", right = "  " },
				globalstatus = true,
				ignore_focus = { "NvimTree", "lazy", "mason", "oil", "telescope" },
			},
			sections = {
				lualine_a = {},
				lualine_b = { bubbles.action },
				lualine_c = { bubbles.git },
				lualine_x = {},
				lualine_y = { bubbles.permissions },
				lualine_z = { bubbles.diagnostics },
			},
		})

		local function ensure_transparency()
			local hl_groups = {
				"StatusLine",
				"StatusLineNC",
				"lualine_a_normal",
				"lualine_b_normal",
				"lualine_c_normal",
				"lualine_x_normal",
				"lualine_y_normal",
				"lualine_z_normal",
				"lualine_c_insert",
				"lualine_c_visual",
				"lualine_c_command",
				"BubbleLevel1",
			}
			for _, group in ipairs(hl_groups) do
				vim.api.nvim_set_hl(0, group, { bg = "NONE" })
			end
		end

		ensure_transparency()

		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "FocusGained" }, {
			callback = function()
				vim.defer_fn(ensure_transparency, 1)
			end,
		})
	end,
}
