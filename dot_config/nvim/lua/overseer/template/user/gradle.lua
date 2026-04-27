local gradle = require("core.gradle")

local cache = {}

local INTERESTING = { "[Rr]un$", "^test$", "^build$", "^check$", "^assemble$", "^installDist$" }

local function interesting(name)
	local short = name:match("([^:]+)$")
	for _, pat in ipairs(INTERESTING) do
		if short:find(pat) then
			return true
		end
	end
	return false
end

local function list_tasks(cmd, root, cb)
	if cache[root] then
		return cb(cache[root])
	end
	vim.system({ cmd, "-q", "tasks", "--all" }, { cwd = root, text = true }, function(res)
		local tasks = {}
		for line in (res.stdout or ""):gmatch("[^\n]+") do
			local name = line:match("^([%w:%-_]+) %- ") or line:match("^([%w:%-_]+)%s*$")
			if name and interesting(name) then
				tasks[#tasks + 1] = name
			end
		end
		table.sort(tasks)
		cache[root] = tasks
		vim.schedule(function()
			cb(tasks)
		end)
	end)
end

return {
	name = "gradle",
	condition = {
		callback = function(search)
			return gradle.root(search.dir) ~= nil
		end,
	},
	generator = function(search, cb)
		local cmd, root = gradle.cmd(search.dir)
		list_tasks(cmd, root, function(tasks)
			local out = {}
			for _, task in ipairs(tasks) do
				out[#out + 1] = {
					name = "gradle " .. task,
					builder = function()
						return { cmd = { cmd, task }, cwd = root, components = { "default" } }
					end,
				}
			end
			cb(out)
		end)
	end,
}
