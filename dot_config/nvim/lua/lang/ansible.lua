return require("core.lang").setup({
	plugins = true,
	servers = {
		ansiblels = {
			settings = {
				yaml = {
					schemas = (function()
						local ok, ss = pcall(require, "schemastore")
						return ok and ss.yaml.schemas() or {}
					end)(),
					validate = true,
					completion = true,
					hover = true,
				},
				ansible = {
					ansible = { path = "ansible" },
					executionEnvironment = { enabled = false },
					python = { interpreterPath = "python3" },
					validation = { enabled = true, lint = { enabled = true, path = "ansible-lint" } },
				},
			},
			filetypes = { "yaml.ansible" },
		},
	},
	tools = { "ansible-language-server", "ansible-lint" },
	linters = { ["yaml.ansible"] = { "ansible_lint" } },
})
