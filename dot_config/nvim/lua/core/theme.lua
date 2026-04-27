local M = {}
local StateManager = require("core.state")

local config = {
	fallback = "jb",
}

local state = StateManager.create({
	name = "theme",
	driver = "file",
	default = { colorscheme = config.fallback },
})

M.refresh_callbacks = {}

function M.get_current()
	return state:read().colorscheme
end

function M.set_and_save(name)
	if name == "" or name == nil then
		return
	end

	state:update("colorscheme", name)

	for cb_name, cb in pairs(M.refresh_callbacks) do
		local ok, err = pcall(cb)
		if not ok then
			vim.notify(string.format("Theme callback '%s' failed: %s", cb_name, err), vim.log.levels.WARN)
		end
	end
end

function M.register_refresh(name, cb)
	M.refresh_callbacks[name] = cb
end

local group = vim.api.nvim_create_augroup("ThemeEngine", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = function(args)
		if vim.g.is_previewing_theme then
			return
		end
		M.set_and_save(args.match)
	end,
})

return M
