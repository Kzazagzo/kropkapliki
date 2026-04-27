local utils = require("plugins.ui.system_ui.utils")
local M = {}

local strategies = {
	quickshell = function()
		local data = utils.read_json("~/.local/state/nvim/colors.json")
		if data and data.background then
			return data
		end
		return nil
	end,

	pywal = function()
		local data = utils.read_json("~/.cache/wal/colors.json")
		if not (data and data.special and data.colors) then
			return nil
		end

		local bg = data.special.background
		local fg = data.special.foreground
		return {
			background = bg,
			on_background = fg,
			primary = data.colors.color4,
			on_primary = bg,
			secondary = data.colors.color5,
			tertiary = data.colors.color3,
			error = data.colors.color1,
			outline = data.colors.color8,
			outline_variant = data.colors.color8,
			surface_container = utils.blend(data.colors.color4, bg, 0.05),
			surface_container_low = bg,
			surface_container_high = utils.blend(data.colors.color4, bg, 0.1),
			surface_container_highest = utils.blend(data.colors.color4, bg, 0.2),
			surface_variant = data.colors.color8,
			on_surface = fg,
			secondary_container = data.colors.color2,
			on_secondary_container = bg,
			tertiary_container = utils.blend(data.colors.color3, bg, 0.1),
			on_tertiary_container = fg,
		}
	end,

	fallback = function()
		local bg = "#282828"
		local fg = "#dfbf8e"
		return {
			background = bg,
			on_background = fg,
			primary = "#a9b665",
			on_primary = bg,
			secondary = "#7caea3",
			tertiary = "#d8a657",
			error = "#ea6962",
			outline = "#504945",
			outline_variant = "#665c54",
			surface_container_low = "#282828",
			surface_container = "#32302f",
			surface_container_high = "#3c3836",
			surface_container_highest = "#504945",
			surface_variant = "#3c3836",
			on_surface = fg,
			on_surface_variant = "#a89984",
			secondary_container = "#4f5b58",
			on_secondary_container = "#a7c080",
			tertiary_container = "#5a524c",
			on_tertiary_container = "#d8a657",
			inverse_primary = "#89b482",
		}
	end,
}

function M.resolve()
	for _, strategy in ipairs({ strategies.quickshell, strategies.pywal, strategies.fallback }) do
		local p = strategy()
		if p then
			return p
		end
	end
	return nil
end

return M
