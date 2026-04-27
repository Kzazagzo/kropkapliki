return require("core.lang").setup({
	servers = {
		groovyls = {
			filetypes = { "groovy" },
			settings = { groovy = { classpath = {} } },
		},
	},
	tools = { "groovy-language-server" },
})
