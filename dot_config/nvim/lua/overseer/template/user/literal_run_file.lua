local cmds = {
	go = { "go", "run", "$file" },
	python = { "python", "$file" },
	lua = { "lua", "$file" },
	sh = { "bash", "$file" },
	rust = { "cargo", "run" },
}

return {
	name = "run file",
	builder = function()
		local file = vim.fn.expand("%:p")
		local cmd = vim.tbl_map(function(part)
			return part == "$file" and file or part
		end, cmds[vim.bo.filetype])
		return { cmd = cmd, components = { "default" } }
	end,
	condition = {
		callback = function()
			return cmds[vim.bo.filetype] ~= nil
		end,
	},
}
