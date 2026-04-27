return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = "Harpoon",
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({
			settings = {
				save_on_toggle = true,
				sync_on_ui_close = true,
				key = function()
					return vim.loop.cwd()
				end,
			},
		})

		local extensions = require("harpoon.extensions")
		harpoon:extend(extensions.builtins.highlight_current_file())

		harpoon:extend({
			UI_CREATE = function(cx)
				vim.keymap.set("n", "<C-v>", function()
					harpoon.ui:select_menu_item({ vsplit = true })
				end, { buffer = cx.bufnr })

				vim.keymap.set("n", "<C-x>", function()
					harpoon.ui:select_menu_item({ split = true })
				end, { buffer = cx.bufnr })
			end,
		})

		vim.api.nvim_create_user_command("Harpoon", function(opts)
			local cmd = opts.fargs[1]
			local arg = opts.fargs[2]
			local idx = tonumber(arg)

			if cmd == "add" then
				local item = arg or vim.api.nvim_buf_get_name(0)
				harpoon:list():add({ value = item, context = { row = 1, col = 0 } })
				vim.api.nvim_exec_autocmds("User", { pattern = "HarpoonListUpdated" })
			elseif cmd == "menu" then
				harpoon.ui:toggle_quick_menu(harpoon:list())
			elseif cmd == "select" then
				if idx then
					harpoon:list():select(idx)
				end
			elseif cmd == "clear" then
				harpoon:list():clear()
			end
		end, {
			nargs = "+",
			complete = function()
				return { "add", "set", "menu", "clear", "select" }
			end,
		})

		vim.api.nvim_exec_autocmds("User", { pattern = "HarpoonListLoaded" })
	end,
}
