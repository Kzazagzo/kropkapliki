return require("core.lang").setup({
	servers = {
		gopls = {
			filetypes = { "go", "gomod", "gowork", "gotmpl", "gohtmltmpl" },
			mason = false,
			settings = {
				gopls = {
					analyses = {
						fieldalignment = false,
						nilness = true,
						shadow = true,
						unusedparams = true,
						unusedwrite = true,
						useany = true,
					},
					codelenses = {
						gc_details = true,
						generate = true,
						regenerate_cgo = true,
						test = true,
						tidy = true,
						upgrade_dependency = true,
						vendor = true,
					},
					completeUnimported = true,
					gofumpt = true,
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
					staticcheck = true,
					usePlaceholders = true,
				},
			},
		},
	},
	formatters_by_ft = { go = { "goimports", "gofumpt" } },
	linters = { go = { "golangcilint" } },
	extra = {
		{
			"ray-x/go.nvim",
			ft = { "go", "gomod", "gowork", "gotmpl", "gohtmltmpl" },
			dependencies = {
				"ray-x/guihua.lua",
				"neovim/nvim-lspconfig",
				"nvim-treesitter/nvim-treesitter",
				"mfussenegger/nvim-dap",
				"rcarriga/nvim-dap-ui",
				"theHamsta/nvim-dap-virtual-text",
			},
			opts = {
				ai = { enable = false },
				dap_debug = true,
				dap_debug_gui = true,
				dap_debug_keymap = true,
				dap_debug_vt = true,
				gofmt = "gofumpt",
				goimports = "gopls",
				lsp_cfg = false,
				lsp_document_formatting = false,
				lsp_gofumpt = true,
				lsp_keymaps = false,
				luasnip = true,
				run_in_floaterm = true,
				test_runner = "go",
			},
			config = function(_, opts)
				require("go").setup(opts)
			end,
		},
	},
})
