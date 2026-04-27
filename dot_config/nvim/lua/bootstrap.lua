local M = {}

local function ensure_lazy_installed()
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not vim.uv.fs_stat(lazypath) then
		vim.notify("Installing lazy.nvim...", vim.log.levels.INFO)
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable",
			lazypath,
		})
	end
	vim.opt.rtp:prepend(lazypath)
end

function M.setup()
	ensure_lazy_installed()

	require("lazy").setup({
		spec = {
			{ import = "plugins" },
			{ import = "plugins.ui" },
			{ import = "plugins.lsp" },
			{ import = "lang" },
		},
		defaults = {
			lazy = true,
		},
		install = {
			colorscheme = { "jb", "habamax" },
		},
		performance = {
			rtp = {
				disabled_plugins = {
					"gzip",
					"matchit",
					"matchparen",
					"netrwPlugin",
					"tarPlugin",
					"tohtml",
					"tutor",
					"zipPlugin",
				},
			},
		},
	})
end

M.setup()

return M
