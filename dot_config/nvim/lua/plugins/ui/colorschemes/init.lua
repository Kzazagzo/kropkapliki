return {
	"colorschemes_engine",
	dir = vim.fn.stdpath("config") .. "/lua/plugins/ui/colorschemes",
	lazy = false,
	priority = 1000,
	dependencies = {
		"nickkadutskyi/jb.nvim",
	},
	config = function()
		local theme_engine = require("core.theme")
		local current = theme_engine.get_current()
		local config_module = "plugins.ui.colorschemes." .. current
		local ok, theme_config = pcall(require, config_module)

		if ok and type(theme_config) == "table" and theme_config.setup then
			local setup_ok, err = pcall(theme_config.setup)
			if not setup_ok then
				vim.notify("Theme setup error [" .. current .. "]: " .. err, vim.log.levels.ERROR)
			end
		end

		local cmd_ok, _ = pcall(vim.cmd.colorscheme, current)
		if not cmd_ok then
			vim.notify("Theme not found: " .. current .. ". Loading default fallback.", vim.log.levels.WARN)
			vim.cmd.colorscheme("default")
		end
	end,
}
