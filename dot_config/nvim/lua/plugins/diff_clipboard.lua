return {
	"diff_clipboard",
	dir = vim.fn.stdpath("config") .. "/lua/plugins",
	lazy = false,
	config = function()
		local function diff_with_clipboard()
			local src_buf = vim.api.nvim_get_current_buf()
			local ft = vim.bo[src_buf].filetype

			local clip = vim.fn.getreg("+")
			if clip == "" then
				vim.notify("Clipboard empty", vim.log.levels.WARN)
				return
			end

			vim.cmd("vsplit")
			vim.cmd("enew")
			local scratch = vim.api.nvim_get_current_buf()
			vim.bo[scratch].buftype = "nofile"
			vim.bo[scratch].bufhidden = "wipe"
			vim.bo[scratch].swapfile = false
			vim.bo[scratch].filetype = ft
			vim.api.nvim_buf_set_name(scratch, "[clipboard]")
			vim.api.nvim_buf_set_lines(scratch, 0, -1, false, vim.split(clip, "\n", { plain = true }))

			vim.cmd("diffthis")
			vim.cmd("wincmd p")
			vim.cmd("diffthis")

			vim.keymap.set("n", "q", function()
				vim.cmd("diffoff!")
				vim.api.nvim_buf_delete(scratch, { force = true })
			end, { buffer = scratch, desc = "Close clipboard diff" })
		end

		vim.api.nvim_create_user_command("DiffClipboard", diff_with_clipboard, {})
		vim.keymap.set("n", "<C-S-p>", diff_with_clipboard, { desc = "Diff with clipboard" })
	end,
}
