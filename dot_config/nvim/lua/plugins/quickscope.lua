return {
	"unblevable/quick-scope",
	event = "VeryLazy",
	init = function()
		vim.g.qs_highlight_on_key = 1

		local group = vim.api.nvim_create_augroup("QuickScopeTheme", { clear = true })
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			group = group,
			callback = function()
				local ok, providers = pcall(require, "plugins.ui.system_ui.providers")
				if ok then
					local c = providers.resolve()
					if c then
						vim.api.nvim_set_hl(0, "QuickScopePrimary", { fg = c.primary, underline = true, bold = true })
						vim.api.nvim_set_hl(0, "QuickScopeSecondary", { fg = c.tertiary, underline = true })
					end
				end
			end,
		})
	end,
}
