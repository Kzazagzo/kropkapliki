local M = {}
local StateManager = require("core.state")

local ROOT_MARKERS = {
	".git",
	"package.json",
	"Cargo.toml",
	"go.mod",
	"pom.xml",
	"settings.gradle.kts",
	"settings.gradle",
	"build.gradle.kts",
	"build.gradle",
	"pyproject.toml",
	".nvim-project",
}

local state = StateManager.create({
	name = "projects",
	driver = "file",
	default = { list = {} },
})

function M.add(path)
	path = path or vim.fn.getcwd()
	local data = state:read()
	for _, p in ipairs(data.list) do
		if p.path == path then
			return
		end
	end
	table.insert(data.list, 1, {
		path = path,
		name = vim.fn.fnamemodify(path, ":t"),
	})
	state:write(data)
end

function M.remove(path)
	local data = state:read()
	data.list = vim.tbl_filter(function(p)
		return p.path ~= path
	end, data.list)
	state:write(data)
end

function M.rename(path, new_name)
	local data = state:read()
	for _, p in ipairs(data.list) do
		if p.path == path then
			p.name = new_name
			break
		end
	end
	state:write(data)
end

function M.list()
	return state:read().list
end

function M.find_root(path)
	path = path or vim.fn.expand("%:p:h")
	local found = vim.fs.find(ROOT_MARKERS, {
		path = path,
		upward = true,
		limit = 1,
	})
	if #found > 0 then
		return vim.fs.dirname(found[1])
	end
	return nil
end

function M.is_project(path)
	return M.find_root(path) ~= nil
end

function M.switch(path)
	local session = require("core.session")
	session.save(vim.fn.getcwd())

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
			vim.api.nvim_buf_delete(buf, { force = false })
		end
	end

	vim.cmd("cd " .. vim.fn.fnameescape(path))
	M.add(path)

	local ok, harpoon = pcall(require, "harpoon")
	if ok then
		harpoon:sync()
	end

	if not require("core.session").restore(path) then
		vim.notify("New project: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
	end
end

local group = vim.api.nvim_create_augroup("ProjectAutoDetect", { clear = true })

vim.api.nvim_create_autocmd("DirChanged", {
	group = group,
	callback = function()
		local root = M.find_root(vim.fn.getcwd())
		if root and root ~= vim.fn.getcwd() then
			vim.cmd("cd " .. vim.fn.fnameescape(root))
			M.add(root)
		end
	end,
})

return M
