return require("core.lang").setup({
	servers = {
		lua_ls = {
			settings = {
				Lua = {
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
					diagnostics = { globals = { "vim" } },
				},
			},
		},
	},
	tools = { "stylua", "selene" },
	formatters_by_ft = { lua = { "stylua" } },
	linters = { lua = { "selene" } },
})
