return require("core.lang").setup({
	tools = { "palantir-java-format" },
	formatters_by_ft = { java = { "palantir-java-format" } },
	extra = {
		{
			"mfussenegger/nvim-jdtls",
			ft = { "java" },
			dependencies = { "saghen/blink.cmp" },
			config = function()
				local jdtls = require("jdtls")

				local function attach_jdtls()
					local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
					local root_dir = jdtls.setup.find_root(root_markers)
					if not root_dir or root_dir == "" then
						return
					end

					local project_name = vim.fs.basename(root_dir)
					local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"

					local lombok_jar = vim.fn.expand(vim.fn.stdpath("data") .. "/mason/share/jdtls/lombok.jar")

					local config = {
						cmd = {
							vim.fn.exepath("jdtls"),
							string.format("--jvm-arg=-javaagent:%s", lombok_jar),
							"-data",
							workspace_dir,
						},
						root_dir = root_dir,
						settings = {
							java = {
								signatureHelp = { enabled = true },
								contentProvider = { preferred = "fernflower" },
								completion = {
									favoriteStaticMembers = {
										"org.hamcrest.MatcherAssert.assertThat",
										"org.hamcrest.Matchers.*",
										"org.junit.jupiter.api.Assertions.*",
										"java.util.Objects.requireNonNull",
										"org.mockito.Mockito.*",
									},
								},
								sources = {
									organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
								},
								codeGeneration = {
									toString = {
										template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
									},
									useBlocks = true,
								},
								inlayHints = { parameterNames = { enabled = "all" } },
							},
						},
						init_options = {
							bundles = {},
						},

						capabilities = require("blink.cmp").get_lsp_capabilities(),
					}

					config.on_attach = function(client, bufnr)
						require("cfg.mappings.lsp").attach(bufnr, client.id)

						local map = function(mode, lhs, rhs, desc)
							vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Java: " .. desc })
						end

						map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
						map("n", "gr", vim.lsp.buf.references, "Go to References")

						map("n", "<leader>co", jdtls.organize_imports, "Organize Imports")
						map("n", "<leader>rv", jdtls.extract_variable, "Extract Variable")
						map(
							"v",
							"<leader>rv",
							[[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]],
							"Extract Variable"
						)
						map("n", "<leader>rc", jdtls.extract_constant, "Extract Constant")
						map(
							"v",
							"<leader>rm",
							[[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
							"Extract Method"
						)
						map("n", "gs", jdtls.super_implementation, "Go to Super")
					end

					jdtls.start_or_attach(config)
				end

				vim.api.nvim_create_autocmd("FileType", {
					pattern = "java",
					callback = attach_jdtls,
				})

				local java_lang = {}
				for name in
					([[Object String StringBuilder StringBuffer CharSequence Comparable Cloneable Runnable Thread
				Boolean Byte Character Short Integer Long Float Double Number Math
				Class Enum Record Iterable System Process ProcessBuilder ClassLoader Package Module
				Throwable Exception RuntimeException Error
				IllegalArgumentException IllegalStateException NullPointerException UnsupportedOperationException
				IndexOutOfBoundsException ArrayIndexOutOfBoundsException ClassCastException NumberFormatException
				ArithmeticException InterruptedException StackOverflowError OutOfMemoryError AssertionError
				Void Deprecated Override SuppressWarnings FunctionalInterface SafeVarargs]]):gmatch("%S+")
				do
					java_lang[name] = true
				end

				local cache = {}
				local function origins(buf)
					local tick = vim.b[buf].changedtick
					local c = cache[buf]
					if c and c.tick == tick then
						return c.map
					end
					local map, root = {}, nil
					for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 200, false)) do
						local pkg = line:match("^%s*package%s+([%w_.]+)")
						if pkg then
							root = pkg:match("^(%w+%.%w+)") or pkg
						end
						local imp = line:match("^%s*import%s+static%s+([%w_.]+)")
							or line:match("^%s*import%s+([%w_.]+)")
						if imp then
							local name = imp:match("([%w_]+)$")
							local group = "@lsp.java.lib"
							if imp:match("^java%.") or imp:match("^javax%.") or imp:match("^jdk%.") then
								group = "@lsp.java.jdk"
							elseif root and imp:sub(1, #root) == root then
								group = "@lsp.java.own"
							end
							map[name] = group
						end
					end
					cache[buf] = { tick = tick, map = map }
					return map
				end

				vim.api.nvim_create_autocmd("LspTokenUpdate", {
					pattern = "*.java",
					callback = function(args)
						local token = args.data.token

						if token.type == "variable" or token.type == "property" then
							if not token.modifiers.readonly then
								vim.lsp.semantic_tokens.highlight_token(
									token,
									args.buf,
									args.data.client_id,
									"@lsp.java.mutable"
								)
							end
							return
						end

						if token.type ~= "class" and token.type ~= "interface" and token.type ~= "enum" then
							return
						end
						local name = vim.api.nvim_buf_get_text(
							args.buf,
							token.line,
							token.start_col,
							token.line,
							token.end_col,
							{}
						)[1]
						local group = origins(args.buf)[name] or (java_lang[name] and "@lsp.java.jdk")
						if group then
							vim.lsp.semantic_tokens.highlight_token(token, args.buf, args.data.client_id, group)
						end
					end,
				})

				local function link()
					vim.api.nvim_set_hl(0, "@lsp.java.jdk", { fg = "#6ca6a0" })
					vim.api.nvim_set_hl(0, "@lsp.java.lib", { fg = "#9a86b8" })
					vim.api.nvim_set_hl(0, "@lsp.java.mutable", { underline = true })
				end
				link()
				vim.api.nvim_create_autocmd("ColorScheme", { callback = link })

				if vim.bo.filetype == "java" then
					attach_jdtls()
				end
			end,
		},
	},
})
