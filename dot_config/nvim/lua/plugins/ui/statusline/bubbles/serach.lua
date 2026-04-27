local api = require("plugins.ui.statusline.api")

return api.create_bubble({
	render = function()
		local query = vim.fn.getreg("/")
		if query == "" then
			return ""
		end

		query = query:gsub([[\v]], "")

		local search = vim.fn.searchcount({ maxcount = 999, timeout = 10 })
		if search.total == 0 then
			return ""
		end

		return string.format("  %s [%d/%d]", query, search.current, search.total)
	end,
	cond = function()
		return vim.v.hlsearch == 1
	end,
	color = function()
		return "Directory"
	end,
	level = 2,
})
