local api = require("plugins.ui.statusline.api")

local sync_state = { ahead = 0, behind = 0, is_git = false }

local function update_git_sync()
	vim.system({ "git", "rev-list", "--count", "--left-right", "@{upstream}...HEAD" }, { text = true }, function(obj)
		if obj.code == 0 then
			local ahead, behind = obj.stdout:match("(%d+)%s+(%d+)")
			if ahead and behind then
				sync_state.ahead = tonumber(ahead)
				sync_state.behind = tonumber(behind)
				sync_state.is_git = true
			end
		else
			sync_state.is_git = false
		end
	end)
end

vim.api.nvim_create_autocmd({ "FocusGained", "BufWritePost", "VimEnter" }, {
	callback = update_git_sync,
})

local function get_special_state()
	if vim.fn.search([[^\(<<<<<<<\|======= \||||||||\|>>>>>>>\)]], "nw") ~= 0 then
		return "CONFLICTS", "ErrorMsg", 9
	end

	local git_dir = vim.b.git_dir or vim.fn.system("git rev-parse --git-dir 2>/dev/null"):gsub("%s+", "")
	if git_dir == "" then
		return nil
	end
	vim.b.git_dir = git_dir

	if vim.uv.fs_stat(git_dir .. "/MERGE_HEAD") then
		return "MERGING", "WarningMsg", 8
	end
	if vim.uv.fs_stat(git_dir .. "/REBASE_CONFIRM") or vim.uv.fs_stat(git_dir .. "/rebase-apply") then
		return "REBASE", "WarningMsg", 8
	end
	if vim.uv.fs_stat(git_dir .. "/CHERRY_PICK_HEAD") then
		return "CHERRY-PICK", "WarningMsg", 8
	end

	return nil
end

return api.create_bubble({
	render = function()
		local special, _, _ = get_special_state()
		if special then
			return "󰊢 " .. special
		end

		local parts = {}
		if sync_state.ahead > 0 then
			table.insert(parts, "↑" .. sync_state.ahead)
		end
		if sync_state.behind > 0 then
			table.insert(parts, "↓" .. sync_state.behind)
		end
		return "󰊤 " .. table.concat(parts, " ")
	end,

	cond = function()
		local special = get_special_state()
		local has_sync = sync_state.is_git and (sync_state.ahead > 0 or sync_state.behind > 0)
		return special ~= nil or has_sync
	end,

	color = function()
		local _, color_group, _ = get_special_state()
		return color_group or "String"
	end,

	level = function()
		local _, _, lvl = get_special_state()
		if lvl then
			return lvl
		end

		if sync_state.ahead > 5 or sync_state.behind > 5 then
			return 4
		end
		return 3
	end,
})
