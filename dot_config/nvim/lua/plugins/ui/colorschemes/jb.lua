local M = {}

function M.setup()
	local ok, jb = pcall(require, "jb")
	if ok then
		jb.setup({ transparent = true })
	end
end

return M

