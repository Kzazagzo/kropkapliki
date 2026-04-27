local api = require("plugins.ui.statusline.api")

return api.create_bubble({
	render = function()
		local filepath = vim.fn.expand("%:p")
		if filepath == "" or vim.bo.buftype ~= "" then
			return ""
		end

		local is_writable = vim.fn.filewritable(filepath)
		local exists = vim.uv.fs_stat(filepath) ~= nil

		if exists and is_writable == 0 then
			return "󰌾 SUDO"
		end

		if vim.bo.readonly then
			return "󰌾 RO"
		end

		return ""
	end,
	cond = function()
		local filepath = vim.fn.expand("%:p")
		if filepath == "" or vim.bo.buftype ~= "" then
			return false
		end

		local is_writable = vim.fn.filewritable(filepath)
		local exists = vim.uv.fs_stat(filepath) ~= nil

		return (exists and is_writable == 0) or vim.bo.readonly
	end,
	color = function()
		local filepath = vim.fn.expand("%:p")
		local is_writable = vim.fn.filewritable(filepath)
		return is_writable == 0 and "ErrorMsg" or "WarningMsg"
	end,
	level = 8,
})
