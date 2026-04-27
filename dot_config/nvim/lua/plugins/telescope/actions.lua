local M = {}

function M.get(actions)
	local action_state = require("telescope.actions.state")

	return {
		select_one_or_multi = function(prompt_bufnr)
			local picker = action_state.get_current_picker(prompt_bufnr)
			local multi = picker:get_multi_selection()

			if not vim.tbl_isempty(multi) then
				actions.close(prompt_bufnr)
				for _, j in pairs(multi) do
					if j.path ~= nil then
						vim.cmd(string.format("edit %s", j.path))
					end
				end
			else
				actions.select_default(prompt_bufnr)
			end
		end,

		switch_picker = function(picker_name)
			return function(prompt_bufnr)
				local text = action_state.get_current_picker(prompt_bufnr):_get_prompt()
				actions.close(prompt_bufnr)
				require("telescope.builtin")[picker_name]({ default_text = text })
			end
		end,

		add_to_harpoon = function(prompt_bufnr)
			local selection = action_state.get_selected_entry()
			local path = selection.path or selection.filename or selection.value
			vim.cmd("Harpoon add " .. path)
		end,
	}
end

return M
