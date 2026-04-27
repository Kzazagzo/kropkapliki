local api = require("plugins.ui.statusline.api")

return api.create_bubble({
	render = function()
		local ok, harpoon = pcall(require, "harpoon")
		if not ok then
			return ""
		end

		local list = harpoon:list()
		local root = list.config:get_root_dir()
		local current_file = vim.api.nvim_buf_get_name(0)
		local items = list.items

		local slots = {}
		for i = 1, 4 do
			local item = items[i]
			if item then
				local full_path = root .. "/" .. item.value
				if vim.fs.normalize(full_path) == vim.fs.normalize(current_file) then
					table.insert(slots, "●")
				else
					table.insert(slots, tostring(i))
				end
			else
				table.insert(slots, "_")
			end
		end
		return table.concat(slots, " ")
	end,

	cond = function()
		local ok, harpoon = pcall(require, "harpoon")
		return ok and harpoon:list():length() >= 2
	end,

	level = 1,
})
