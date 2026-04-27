return {
	"system_ui",
	dir = vim.fn.stdpath("config") .. "/lua/plugins/ui/system_ui",
	lazy = false,
	priority = 999,
	config = function()
		local theme_engine = require("core.theme")
		local providers = require("plugins.ui.system_ui.providers")
		local highlighter = require("plugins.ui.system_ui.highlighter")

		local function trigger_sync()
			local palette = providers.resolve()
			if palette then
				highlighter.apply(palette)
			end
		end

		theme_engine.register_refresh("system_material_ui", trigger_sync)
		trigger_sync()

		local uv = vim.uv or vim.loop
		local path = vim.fn.expand("~/.local/state/nvim/colors.json")

		if vim.uv.fs_stat(path) then
			local handle = uv.new_fs_event()
			uv.fs_event_start(
				handle,
				path,
				{},
				vim.schedule_wrap(function(err, filename, events)
					if not err then
						trigger_sync()
					end
				end)
			)
		end
		local group = vim.api.nvim_create_augroup("SystemUISync", { clear = true })

		vim.api.nvim_create_autocmd("VimEnter", {
			group = group,
			callback = function()
				vim.schedule(trigger_sync)
			end,
		})

		vim.api.nvim_create_autocmd("FocusGained", {
			group = group,
			callback = trigger_sync,
		})
	end,
}
