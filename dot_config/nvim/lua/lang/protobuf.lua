return require("core.lang").setup({
	servers = { buf_ls = {} },
	tools = { "buf" },
	formatters_by_ft = { proto = { "buf" } },
	linters = { proto = { "buf_lint" } },
})
