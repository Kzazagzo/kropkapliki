local M = {}
local uv = vim.uv or vim.loop

local session_dir = vim.fn.stdpath("state") .. "/sessions"

local function ensure_dir()
	if not uv.fs_stat(session_dir) then
		vim.fn.mkdir(session_dir, "p")
	end
end

local function path_to_name(path)
	return path:gsub("[/\\]", "%%") .. ".vim"
end

function M.save(path)
	ensure_dir()
	path = path or vim.fn.getcwd()
	local file = session_dir .. "/" .. path_to_name(path)
	vim.cmd("mksession! " .. vim.fn.fnameescape(file))
end

function M.restore(path)
	ensure_dir()
	path = path or vim.fn.getcwd()
	local file = session_dir .. "/" .. path_to_name(path)
	if not uv.fs_stat(file) then
		return false
	end
	local ok, err = pcall(vim.cmd, "source " .. vim.fn.fnameescape(file))
	if not ok then
		vim.notify("Session restore failed: " .. err, vim.log.levels.WARN)
		return false
	end
	return true
end

function M.delete(path)
	local file = session_dir .. "/" .. path_to_name(path)
	if uv.fs_stat(file) then
		vim.fn.delete(file)
	end
end

function M.exists(path)
	local file = session_dir .. "/" .. path_to_name(path)
	return uv.fs_stat(file) ~= nil
end

local group = vim.api.nvim_create_augroup("SessionAutoSave", { clear = true })
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = group,
	callback = function()
		local project = require("core.project")
		if project.is_project(vim.fn.getcwd()) then
			M.save(vim.fn.getcwd())
		end
	end,
})

return M
