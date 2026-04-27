return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local yazi = require("yazi")

		yazi.setup({
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
			set_keymappings_function = function(yazi_buffer_id)
				vim.keymap.set("t", "<Esc>", function()
					local job_id = vim.b[yazi_buffer_id].terminal_job_id
					if job_id then
						vim.api.nvim_chan_send(job_id, "q")
					end
				end, { buffer = yazi_buffer_id, desc = "Yazi: Close" })
			end,
			floating_window_scaling_factor = 0.9,
			yazi_floating_window_winblend = 10,
		})

		vim.keymap.set("t", "<M-a>", function()
			local context = yazi.active_contexts:peek()

			if context and context.ya_process and context.ya_process.hovered_url then
				local hovered_file = context.ya_process.hovered_url
				vim.cmd("Harpoon add " .. hovered_file)
			end
		end, { desc = "Yazi: Harpoon hovered file" })
	end,
}
