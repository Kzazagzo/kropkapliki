local M = {}

function M.setup(spec)
	local out = {}

	if spec.servers then
		table.insert(out, {
			"neovim/nvim-lspconfig",
			opts = function(_, opts)
				opts.servers = opts.servers or {}
				for name, cfg in pairs(spec.servers) do
					opts.servers[name] = vim.tbl_deep_extend("force", opts.servers[name] or {}, cfg)
				end
			end,
		})
	end

	if spec.tools then
		table.insert(out, {
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = function(_, opts)
				opts.ensure_installed = opts.ensure_installed or {}
				vim.list_extend(opts.ensure_installed, spec.tools)
			end,
		})
	end

	if spec.formatters_by_ft or spec.formatters then
		table.insert(out, {
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = spec.formatters_by_ft,
				formatters = spec.formatters,
			},
		})
	end

	if spec.linters then
		table.insert(out, {
			"mfussenegger/nvim-lint",
			opts = { linters_by_ft = spec.linters },
		})
	end

	if spec.treesitter then
		table.insert(out, {
			"nvim-treesitter/nvim-treesitter",
			opts = function()
				require("nvim-treesitter").install(spec.treesitter)
			end,
		})
	end

	if spec.plugins then
		table.insert(out, { "b0o/schemastore.nvim" })
	end

	if spec.extra then
		vim.list_extend(out, spec.extra)
	end

	return out
end

return M
