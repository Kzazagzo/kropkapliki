return require("core.lang").setup({
	servers = {
		basedpyright = {
			settings = {
				basedpyright = {
					analysis = {
						typeCheckingMode = "standard",
						autoImportCompletions = true,
						useLibraryCodeForTypes = true,
						venvPath = ".",
						venv = ".venv",
					},
				},
			},
		},
	},
	tools = { "basedpyright", "ruff" },
	formatters_by_ft = { python = { "ruff_format", "ruff_organize_imports" } },
	formatters = {
		ruff_format = { command = "ruff", args = { "format", "--stdin-filename", "$FILENAME", "-" }, stdin = true },
		ruff_organize_imports = {
			command = "ruff",
			args = { "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "-" },
			stdin = true,
		},
	},
	linters = { python = { "ruff" } },
})
