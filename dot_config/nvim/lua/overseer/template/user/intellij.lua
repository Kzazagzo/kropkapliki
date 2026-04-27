local idea = require("core.idea_run")

return {
	name = "IntelliJ run configurations",
	condition = {
		callback = function(search)
			return vim.fn.isdirectory(search.dir .. "/.run") == 1
				or vim.fn.isdirectory(search.dir .. "/.idea/runConfigurations") == 1
		end,
	},
	generator = function(search, cb)
		local tasks = {}
		for _, conf in ipairs(idea.load(search.dir)) do
			tasks[#tasks + 1] = {
				name = "IJ: " .. conf.name,
				builder = function()
					return {
						cmd = conf.cmd,
						cwd = conf.cwd,
						env = conf.env,
						components = { "default" },
					}
				end,
			}
		end
		cb(tasks)
	end,
}
