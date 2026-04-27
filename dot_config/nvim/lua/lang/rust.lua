return require("core.lang").setup({
	servers = {
		rust_analyzer = {
			settings = {
				["rust-analyzer"] = {
					cargo = { allFeatures = true, loadOutDirsFromCheck = true, runBuildScripts = true },
					checkOnSave = { allFeatures = true, command = "clippy", extraArgs = { "--no-deps" } },
					procMacro = {
						enable = true,
						ignored = {
							["async-trait"] = { "async_trait" },
							["napi-derive"] = { "napi" },
							["async-recursion"] = { "async_recursion" },
						},
					},
					inlayHints = {
						bindingModeHints = { enable = false },
						chainingHints = { enable = true },
						closingBraceHints = { enable = true, minLines = 25 },
						closureReturnTypeHints = { enable = "never" },
						lifetimeElisionHints = { enable = "never" },
						parameterHints = { enable = true },
						typeHints = { enable = true },
					},
				},
			},
		},
	},
	tools = { "rust-analyzer", "codelldb" },
	formatters_by_ft = { rust = { "rustfmt" } },
})
