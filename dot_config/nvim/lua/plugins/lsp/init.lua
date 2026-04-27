return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		dependencies = {
			{ "williamboman/mason.nvim", cmd = "Mason", opts = {} },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		opts = {
			servers = {},
			setup = {},
		},
		config = function(_, opts)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local has_blink, blink = pcall(require, "blink.cmp")
			if has_blink then
				capabilities = blink.get_lsp_capabilities(capabilities)
			end
			local servers = opts.servers
			local ensure_installed = {}
			local configured_servers = {}

			for server_name, server_opts in pairs(servers or {}) do
				if server_opts.mason ~= false then
					ensure_installed[#ensure_installed + 1] = server_name
				end

				if server_name ~= "jdtls" then
					local server_config = vim.tbl_deep_extend("force", {}, server_opts or {})
					server_config.mason = nil
					server_config.capabilities =
						vim.tbl_deep_extend("force", {}, capabilities, server_config.capabilities or {})

					local handled = opts.setup[server_name] and opts.setup[server_name](server_name, server_config)
					if not handled then
						if vim.lsp.config and vim.lsp.enable then
							vim.lsp.config(server_name, server_config)
							configured_servers[#configured_servers + 1] = server_name
						else
							require("lspconfig")[server_name].setup(server_config)
						end
					end
				end
			end

			require("mason-lspconfig").setup({
				ensure_installed = ensure_installed,
				automatic_enable = false,
			})

			if vim.lsp.enable then
				pcall(vim.lsp.enable, "kotlin_language_server", false)
			end

			vim.api.nvim_create_user_command("LspInfo", function()
				vim.cmd("checkhealth vim.lsp")
			end, { desc = "Show LSP status" })

			for _, server_name in ipairs(configured_servers) do
				vim.lsp.enable(server_name)
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(event)
					require("cfg.mappings.lsp").attach(event.buf, event.data.client_id)

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
					end

					if client and client:supports_method("textDocument/documentHighlight") then
						local group = vim.api.nvim_create_augroup("UserLspHighlight" .. event.buf, { clear = true })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							group = group,
							buffer = event.buf,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							group = group,
							buffer = event.buf,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {},
			auto_update = false,
			run_on_start = true,
		},
	},
}
