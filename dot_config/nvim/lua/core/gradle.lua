local M = {}

local MARKERS = { "gradlew", "settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts" }

function M.root(start)
	return vim.fs.root(start or 0, MARKERS)
end

function M.cmd(start)
	local root = M.root(start)
	local wrapper = root and root .. "/gradlew"
	if wrapper and vim.fn.executable(wrapper) == 1 then
		return wrapper, root
	end
	return "gradle", root
end

return M
