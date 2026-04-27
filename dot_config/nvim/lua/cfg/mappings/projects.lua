local map = vim.keymap.set

map("n", "<leader>fp", function()
	local project = require("core.project")
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local function make_finder()
		return finders.new_table({
			results = project.list(),
			entry_maker = function(entry)
				local short = vim.fn.fnamemodify(entry.path, ":~")
				return {
					value = entry,
					display = string.format("%-25s %s", entry.name, short),
					ordinal = entry.name .. " " .. entry.path,
				}
			end,
		})
	end

	local picker
	picker = pickers.new({}, {
		prompt_title = "Projects",
		finder = make_finder(),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map_)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				project.switch(action_state.get_selected_entry().value.path)
			end)

			map_("i", "<C-r>", function()
				local sel = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				vim.ui.input({
					prompt = "Rename project: ",
					default = sel.value.name,
				}, function(input)
					if input and input ~= "" then
						project.rename(sel.value.path, input)
					end
				end)
			end)

			map_("i", "<C-d>", function()
				local sel = action_state.get_selected_entry()
				project.remove(sel.value.path)
				picker:refresh(make_finder())
			end)

			map_("i", "<C-S-d>", function()
				local sel = action_state.get_selected_entry()
				local path = sel.value.path
				actions.close(prompt_bufnr)
				vim.ui.select({ "Yes, delete it", "No" }, {
					prompt = "DELETE " .. path .. " from disk?",
				}, function(choice)
					if choice ~= "Yes, delete it" then
						return
					end
					local result = vim.fn.system("rm -rf " .. vim.fn.shellescape(path))
					if vim.v.shell_error ~= 0 then
						vim.notify("rm -rf failed: " .. result, vim.log.levels.ERROR)
						return
					end
					project.remove(path)
					require("core.session").delete(path)
					vim.notify("Deleted: " .. path, vim.log.levels.INFO)
				end)
			end)

			return true
		end,
	})
	picker:find()
end, { desc = "Projects: picker" })

map("n", "<leader>pa", function()
	require("core.project").add(vim.fn.getcwd())
	vim.notify("Added: " .. vim.fn.getcwd())
end, { desc = "Projects: add cwd" })
