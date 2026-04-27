return require("core.lang").setup({
	servers = {
		vtsls = {
			settings = {
				typescript = {
					suggest = {
						autoImports = true,
						includeCompletionsForModuleExports = true,
						includeCompletionsForImportStatements = true,
					},
					inlayHints = {
						parameterNames = { enabled = "all" },
						variableTypes = { enabled = true },
						propertyDeclarationTypes = { enabled = true },
						functionLikeReturnTypes = { enabled = true },
					},
					preferences = { importModuleSpecifier = "relative" },
				},
			},
		},
		angularls = {
			root_markers = { "angular.json", "nx.json", "ng-package.json", "tsconfig.json" },
		},
		cssls = {
			filetypes = { "css", "scss", "less" },
			settings = {
				css = { validate = true, lint = { unknownAtRules = "ignore" } },
				scss = { validate = true, lint = { unknownAtRules = "ignore" } },
				less = { validate = true },
			},
		},
		eslint = { settings = { workingDirectories = { mode = "auto" } } },
		emmet_language_server = { filetypes = { "html", "htmlangular", "scss", "css" } },
	},
	tools = {
		"angular-language-server",
		"vtsls",
		"css-lsp",
		"eslint-lsp",
		"emmet-language-server",
		"prettier",
		"stylelint",
		"oxlint",
	},
	formatters_by_ft = {
		typescript = { "prettier" },
		html = { "prettier" },
		htmlangular = { "prettier" },
		scss = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
	},
	linters = {
		typescript = { "oxlint" },
		css = { "stylelint" },
		scss = { "stylelint" },
	},
	treesitter = { "typescript", "html", "css", "scss", "angular", "regex" },
	extra = {
		{
			"joeveiga/ng.nvim",
			ft = { "typescript", "html", "htmlangular" },
			config = function()
				local ng = require("ng")
				local map = vim.keymap.set
				local o = { noremap = true, silent = true }
				map("n", "<leader>at", function()
					ng.goto_template_for_component({ reuse_window = true })
				end, o)
				map("n", "<leader>ac", ng.goto_component_with_template_file, o)
				map("n", "<leader>aT", ng.get_template_tcb, o)
			end,
		},
		{
			"matthiasweiss/angular-quickswitch.nvim",
			opts = {},
			keys = {
				{ "<leader>aw", "<cmd>NgQuickSwitchToggle<cr>", desc = "Angular: toggle ts↔html / file↔spec" },
				{ "<leader>aS", "<cmd>NgQuickSwitchStyles<cr>", desc = "Angular: Style" },
				{ "<leader>ae", "<cmd>NgQuickSwitchSpec<cr>", desc = "Angular: Spec" },
			},
		},
	},
})
