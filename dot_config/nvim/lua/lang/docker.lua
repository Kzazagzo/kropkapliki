return require("core.lang").setup({
	plugins = true,
	servers = {
		dockerls = {},
		yamlls = {
			settings = {
				yaml = {
					schemas = (function()
						local ok, ss = pcall(require, "schemastore")
						if not ok then
							return {}
						end
						local schemas = ss.yaml.schemas()
						schemas["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] =
							{
								"docker-compose*.yml",
								"docker-compose*.yaml",
								"compose*.yml",
								"compose*.yaml",
								"docker-compose*.j2",
								"compose*.j2",
							}
						return schemas
					end)(),
					validate = true,
					completion = true,
					hover = true,
				},
			},
			filetypes = { "yaml", "yaml.docker-compose", "yaml.docker-compose.j2" },
		},
	},
	tools = {
		"dockerfile-language-server",
		"docker-compose-language-service",
		"hadolint",
		"yaml-language-server",
	},
	linters = { dockerfile = { "hadolint" } },
})
