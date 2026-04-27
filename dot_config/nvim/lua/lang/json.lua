return require("core.lang").setup({
	plugins = true,
	servers = {
		jsonls = {
			settings = {
				json = {
					schemas = (function()
						local ok, ss = pcall(require, "schemastore")
						return ok and ss.json.schemas() or {}
					end)(),
					validate = { enable = true },
				},
			},
		},
	},
	tools = { "json-lsp" },
})
