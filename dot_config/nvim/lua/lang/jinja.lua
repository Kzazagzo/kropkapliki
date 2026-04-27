return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "jinja2" })
			end
		end,
	},

	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				jinja_lsp = {
					filetypes = {
						"jinja",
						"yaml.jinja",
						"yaml.docker-compose.jinja",
						"html.jinja",
						"bash.jinja",
						"toml.jinja",
						"xml.jinja",
					},
				},
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.filetype.add({
				extension = {
					jinja = "jinja",
					jinja2 = "jinja",
				},
				pattern = {
					["%.?([^%.]+)%.jinja2"] = function(path, bufnr, ext)
						return ext .. ".jinja"
					end,
				},
			})
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"jinja-lsp",
			})
		end,
	},
}
