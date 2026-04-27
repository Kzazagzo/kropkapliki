return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local original_echo = vim.api.nvim_echo
		vim.api.nvim_echo = function(chunks, history, opts)
			original_echo(chunks, history, opts)
			local is_error = false
			local parts = {}
			for _, c in ipairs(chunks) do
				parts[#parts + 1] = c[1]
				if c[2] and c[2]:find("Error") then
					is_error = true
				end
			end
			if is_error then
				vim.schedule(function()
					vim.notify(table.concat(parts, ""), vim.log.levels.ERROR)
				end)
			end
		end

		require("nvim-treesitter").setup({})

		require("nvim-treesitter").install({
			"java",
			"kotlin",
			"rust",
			"lua",
			"vim",
			"vimdoc",
			"query",
			"json",
			"go",
			"gomod",
			"gosum",
			"gotmpl",
			"bash",
			"markdown",
			"markdown_inline",
			"python",
			"nix",
			"yaml",
			"proto",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function(ev)
				pcall(vim.treesitter.start, ev.buf)
			end,
		})
	end,
}
