local M = {}
local uv = vim.uv or vim.loop

local ShadaAdapter = {}
ShadaAdapter.__index = ShadaAdapter

function ShadaAdapter.new(name, default)
	local self = setmetatable({}, ShadaAdapter)
	self.var_name = "STATE_" .. name:upper()
	self.default = default or {}
	return self
end

function ShadaAdapter:read()
	local data = vim.g[self.var_name]
	if type(data) ~= "table" then
		return vim.deepcopy(self.default)
	end
	return vim.tbl_deep_extend("force", self.default, data)
end

function ShadaAdapter:write(data)
	vim.g[self.var_name] = data
end

function ShadaAdapter:update(key, value)
	local current = self:read()
	current[key] = value
	self:write(current)
end

function ShadaAdapter:clear()
	vim.g[self.var_name] = nil
end

local FileAdapter = {}
FileAdapter.__index = FileAdapter

function FileAdapter.new(name, default)
	local self = setmetatable({}, FileAdapter)
	self.path = vim.fn.stdpath("state") .. "/" .. name .. ".json"
	self.default = default or {}
	return self
end

function FileAdapter:read()
	local f = io.open(self.path, "r")
	if not f then
		return vim.deepcopy(self.default)
	end

	local content = f:read("*all")
	f:close()

	if content == "" then
		return vim.deepcopy(self.default)
	end

	local ok, data = pcall(vim.json.decode, content)
	if not ok then
		vim.notify("State decode error [" .. self.path .. "]", vim.log.levels.ERROR)
		return vim.deepcopy(self.default)
	end

	return vim.tbl_deep_extend("force", self.default, data or {})
end

function FileAdapter:write(data)
	local json_str = vim.json.encode(data)

	local f = io.open(self.path, "w")
	if not f then
		vim.notify("State write error: " .. self.path, vim.log.levels.ERROR)
		return
	end
	f:write(json_str)
	f:close()
end

function FileAdapter:update(key, value)
	local current = self:read()
	current[key] = value
	self:write(current)
end

function FileAdapter:clear()
	vim.fn.delete(self.path)
end

function M.create(opts)
	if not opts or not opts.name then
		error("StateManager: 'name' is required to create a state instance")
	end

	local driver = opts.driver or "file"
	local default = opts.default or {}

	if driver == "shada" then
		return ShadaAdapter.new(opts.name, default)
	elseif driver == "file" then
		return FileAdapter.new(opts.name, default)
	else
		error("StateManager: Unknown driver '" .. driver .. "'")
	end
end

return M
