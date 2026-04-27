local api = require("plugins.ui.statusline.api")

local function count_listed_buffers()
	local count = 0

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
			count = count + 1
		end
	end

	return count
end

return api.create_bubble({
	render = function()
		return count_listed_buffers() .. " 󰈚"
	end,
	cond = function()
		return count_listed_buffers() > 1
	end,
	level = 2,
})
