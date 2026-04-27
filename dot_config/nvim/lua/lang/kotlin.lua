return {
	{
		"AlexandrosAlexiou/kotlin.nvim",
		ft = { "kotlin" },
		dependencies = {
			"mason-org/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			root_markers = {
				"settings.gradle.kts",
				"settings.gradle",
				"build.gradle.kts",
				"build.gradle",
				"pom.xml",
				"gradlew",
				".git",
			},
			jre_path = nil,
			jvm_args = { "-Xmx4g" },
			inlay_hints = { enabled = true },
		},
		config = function(_, opts)
			require("kotlin").setup(opts)
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "kotlin-lsp" })
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		opts = function()
			require("nvim-treesitter").install({ "kotlin" })
		end,
	},
}
