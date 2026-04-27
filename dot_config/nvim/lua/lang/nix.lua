return require("core.lang").setup({
	servers = {
		nixd = {
			mason = false,
			settings = { nixd = { formatting = { command = { "nixfmt" } } } },
		},
	},
	formatters_by_ft = { nix = { "nixfmt" } },
	formatters = { nixfmt = { command = "nixfmt" } },
	linters = { nix = { "statix", "deadnix" } },
})
