local api = require("plugins.ui.statusline.api")

local state = { recording_register = nil }

vim.api.nvim_create_autocmd("RecordingEnter", {
	callback = function()
		state.recording_register = vim.fn.reg_recording()
		require("lualine").refresh()
	end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
	callback = function()
		state.recording_register = nil
		require("lualine").refresh()
	end,
})

return api.create_bubble({
	render = function()
		return " REC @" .. state.recording_register
	end,
	cond = function()
		return state.recording_register ~= nil
	end,
	color = function()
		return "WarningMsg"
	end,
	level = 7,
})
