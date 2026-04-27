return {
	"stevearc/overseer.nvim",
	cmd = { "OverseerRun", "OverseerToggle", "OverseerRestartLast", "OverseerQuickAction" },
	keys = {
		{ "<F5>", "<cmd>OverseerRestartLast<cr>", desc = "Run last task" },
		{ "<leader><leader>", "<cmd>OverseerRun<cr>", mode = "n", desc = "Run anything" },
		{ "<F6>", "<cmd>OverseerToggle<cr>", desc = "Task list" },
	},
	opts = {
		task_list = {
			direction = "bottom",
			min_height = 15,
			bindings = { ["<Esc>"] = "Close", ["q"] = "Close" },
		},
		component_aliases = {
			default = {
				"on_exit_set_status",
				"on_complete_notify",
				{ "open_output", on_start = "always", on_complete = "never", direction = "dock", focus = false },
			},
		},
		templates = { "builtin", "user.run_file", "user.gradle", "user.intellij" },
	},
}
