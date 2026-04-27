local api = require("plugins.ui.statusline.api")

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function get_lsp_progress()
	local lsp_status = vim.lsp.status()
	if not lsp_status or lsp_status == "" then
		return ""
	end
	local frame = math.floor(vim.uv.hrtime() / 1e8) % #spinner_frames + 1
	return spinner_frames[frame]
end

local function get_diagnostics()
	local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	local warns = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	local parts = {}
	if errors > 0 then
		table.insert(parts, " " .. errors)
	end
	if warns > 0 then
		table.insert(parts, " " .. warns)
	end
	return table.concat(parts, " ")
end

local function get_unmanaged_icon()
	local ft = vim.bo.filetype
	if vim.bo.buftype ~= "" or ft == "" then
		return ""
	end

	local ok, lazy_config = pcall(require, "lazy.core.config")
	if not ok then
		return ""
	end

	local has_automation = false

	local conform = lazy_config.plugins["conform.nvim"]
	if conform and conform.opts and conform.opts.formatters_by_ft then
		if conform.opts.formatters_by_ft[ft] then
			has_automation = true
		end
	end

	local lint = lazy_config.plugins["nvim-lint"]
	if lint and lint.opts and lint.opts.linters_by_ft then
		if lint.opts.linters_by_ft[ft] then
			has_automation = true
		end
	end

	return (not has_automation) and "󱚡 " or ""
end

return api.create_bubble({
	render = function()
		local progress = get_lsp_progress()
		local diags = get_diagnostics()
		local unmanaged = get_unmanaged_icon()

		local elements = {}
		if progress ~= "" then
			table.insert(elements, progress)
		end
		if unmanaged ~= "" then
			table.insert(elements, unmanaged)
		end
		if diags ~= "" then
			table.insert(elements, diags)
		end

		return table.concat(elements, " ")
	end,
	cond = function()
		return get_lsp_progress() ~= "" or get_diagnostics() ~= "" or get_unmanaged_icon() ~= ""
	end,
	level = function()
		if #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }) > 0 then
			return 8
		end
		if #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }) > 0 then
			return 5
		end
		if get_unmanaged_icon() ~= "" then
			return 4
		end
		return 2
	end,
})
