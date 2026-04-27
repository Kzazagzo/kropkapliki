local ICON_TAKE_RIGHT = "» "
local ICON_TAKE_LEFT = " «"
local ICON_APPEND_L = "↳ "
local ICON_APPEND_R = " ↲"
local ICON_DROP_L = "✖ " 
local ICON_DROP_R = " ✖" 

local TAKE, DROP, APPEND = 1, 0, 2

local layout_state = {}

local block_cache = {}

local changes_cache = {}

local pending_cache = {}

local function session_of(tabpage)
	local ok, lifecycle = pcall(require, "codediff.ui.lifecycle")
	if not ok then
		return nil
	end
	local session = lifecycle.get_session(tabpage)
	if not session or not session.result_bufnr or not session.conflict_blocks then
		return nil
	end
	if not vim.api.nvim_buf_is_valid(session.result_bufnr) then
		return nil
	end
	return session
end

local function blocks_of(session)
	local buf = session.result_bufnr
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	local hit = block_cache[buf]
	if hit and hit.tick == tick then
		return hit.list
	end

	local tracking = require("codediff.ui.conflict.tracking")
	local list = {}
	for _, block in ipairs(session.conflict_blocks) do
		local mark = block.extmark_id
			and vim.api.nvim_buf_get_extmark_by_id(buf, tracking.tracking_ns, block.extmark_id, { details = true })
		if mark and mark[1] and mark[3] and mark[3].end_row then
			local first = mark[1] + 1
			list[#list + 1] = {
				block = block,
				active = tracking.is_block_active(session, block),
				first = first,
				last = math.max(mark[3].end_row, first), 
				row = mark[1], 
				row_end = mark[3].end_row,
			}
		end
	end

	block_cache[buf] = { tick = tick, list = list }
	return list
end

local function block_at(session, side, lnum, active_only)
	local key = side == 1 and "output1_range" or "output2_range"
	for _, entry in ipairs(blocks_of(session)) do
		local matches
		if side == 3 then
			matches = lnum >= entry.first and lnum <= entry.last
		else
			local r = entry.block[key]
			matches = r and lnum >= r.start_line and lnum < r.end_line
		end
		if matches and (entry.active or not active_only) then
			return entry
		end
	end
	return nil
end

local function unresolved(session)
	local n = 0
	for _, entry in ipairs(blocks_of(session)) do
		if entry.active then
			n = n + 1
		end
	end
	return n
end


local HUNK_NS = vim.api.nvim_create_namespace("codediff-merge-hunks")

local function diff_lines(a, b)
	return vim.text.diff(
		table.concat(a, "\n") .. "\n",
		table.concat(b, "\n") .. "\n",
		{ result_type = "indices" }
	) or {}
end

local function side_changes(base, side_lines, blocks, side)
	local out = {}
	for _, h in ipairs(diff_lines(base, side_lines)) do
		local start_a, count_a, start_b, count_b = h[1], h[2], h[3], h[4]
		local first = count_a > 0 and start_a or (start_a + 1)

		local clear = true
		for _, block in ipairs(blocks) do
			local bs, be = block.base_range.start_line, block.base_range.end_line
			local touches
			if count_a == 0 then
				touches = first >= bs and first <= be
			else
				touches = first < be and (first + count_a) > bs
			end
			if touches then
				clear = false
				break
			end
		end

		if clear then
			local lines = {}
			for n = start_b, start_b + count_b - 1 do
				lines[#lines + 1] = side_lines[n]
			end
			out[#out + 1] = {
				side = side,
				first = first,
				count = count_a,
				lines = lines,
				pane_first = count_b > 0 and start_b or math.max(start_b, 1),
				pane_last = count_b > 0 and (start_b + count_b - 1) or math.max(start_b, 1),
			}
		end
	end
	return out
end

local function changes_of(session)
	local buf = session.result_bufnr
	if changes_cache[buf] ~= nil then
		return changes_cache[buf] or {}
	end

	local base = session.result_base_lines
	local blocks = session.conflict_blocks
	local usable = base and #base > 0 and #blocks > 0
	if usable and not vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), base) then
		usable = false 
	end
	if not usable then
		changes_cache[buf] = false
		return {}
	end

	local list = {}
	for side = 1, 2 do
		local pane = side == 1 and session.original_bufnr or session.modified_bufnr
		if pane and vim.api.nvim_buf_is_valid(pane) then
			vim.list_extend(
				list,
				side_changes(base, vim.api.nvim_buf_get_lines(pane, 0, -1, false), blocks, side)
			)
		end
	end

	for _, change in ipairs(list) do
		change.mark = vim.api.nvim_buf_set_extmark(buf, HUNK_NS, change.first - 1, 0, {
			end_row = change.first - 1 + change.count,
			end_col = 0,
			right_gravity = true,
			end_right_gravity = change.count == 0,
		})
	end

	changes_cache[buf] = list
	return list
end

local function pending_of(session)
	local buf = session.result_bufnr
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	local hit = pending_cache[buf]
	if hit and hit.tick == tick then
		return hit.list
	end

	local list = {}
	for _, change in ipairs(changes_of(session)) do
		local m = vim.api.nvim_buf_get_extmark_by_id(buf, HUNK_NS, change.mark, { details = true })
		if m and m[1] and m[3] and m[3].end_row then
			local row = math.min(m[1], m[3].end_row)
			local rows = math.abs(m[3].end_row - m[1])
			local got = vim.api.nvim_buf_get_lines(buf, row, row + rows, false)
			if not vim.deep_equal(got, change.lines) then
				list[#list + 1] = vim.tbl_extend("force", change, { row = row, rows = rows })
			end
		end
	end

	pending_cache[buf] = { tick = tick, list = list }
	return list
end

local function change_at(session, side, lnum, left_side)
	for _, change in ipairs(pending_of(session)) do
		if side == 3 then
			local first = change.row + 1
			local last = math.max(change.row + change.rows, first)
			if change.side == left_side and lnum >= first and lnum <= last then
				return change
			end
		elseif change.side == side and lnum >= change.pane_first and lnum <= change.pane_last then
			return change
		end
	end
	return nil
end

local function apply_change(session, change)
	local buf = session.result_bufnr
	local tracking = require("codediff.ui.conflict.tracking")

	local marks = {}
	for _, block in ipairs(session.conflict_blocks) do
		if block.extmark_id then
			local m = vim.api.nvim_buf_get_extmark_by_id(buf, tracking.tracking_ns, block.extmark_id, { details = true })
			if m and m[1] and m[3] and m[3].end_row then
				marks[block.extmark_id] = { m[1], m[3].end_row }
			end
		end
	end

	vim.api.nvim_buf_set_lines(buf, change.row, change.row + change.rows, false, change.lines)

	local delta = #change.lines - change.rows
	local count = vim.api.nvim_buf_line_count(buf)
	for id, m in pairs(marks) do
		local first = math.min(math.max(m[1] >= change.row and m[1] + delta or m[1], 0), math.max(count - 1, 0))
		local last = m[2] >= change.row and m[2] + delta or m[2]
		vim.api.nvim_buf_set_extmark(buf, tracking.tracking_ns, first, 0, {
			id = id,
			end_row = math.min(math.max(last, first), count),
			end_col = 0,
			right_gravity = false,
			end_right_gravity = true,
		})
	end

	vim.api.nvim_buf_set_extmark(buf, HUNK_NS, change.row, 0, {
		id = change.mark,
		end_row = math.min(change.row + #change.lines, count),
		end_col = 0,
		right_gravity = true,
		end_right_gravity = false,
	})

	require("codediff.ui.conflict.signs").refresh_all_conflict_signs(session)
	require("codediff.ui.auto_refresh").refresh_result_now(buf)
end

local function appendable(session, side, entry)
	if not entry or entry.active then
		return nil
	end

	local buf = side == 1 and session.original_bufnr or session.modified_bufnr
	local range = side == 1 and entry.block.output1_range or entry.block.output2_range
	if not buf or not range or not vim.api.nvim_buf_is_valid(buf) then
		return nil
	end

	local lines = require("codediff.ui.conflict.tracking").get_lines_for_range(buf, range.start_line, range.end_line)
	if #lines == 0 then
		return nil 
	end

	local got = vim.api.nvim_buf_get_lines(session.result_bufnr, entry.row, entry.row_end, false)
	for at = 0, #got - #lines do
		local same = true
		for i = 1, #lines do
			if got[at + i] ~= lines[i] then
				same = false
				break
			end
		end
		if same then
			return nil
		end
	end

	return lines
end


function _G.CodediffGutterIcon(tabpage, side, kind, icon)
	local blank = (" "):rep(vim.fn.strdisplaywidth(icon))
	if vim.v.virtnum ~= 0 then
		return blank
	end
	local session = session_of(tabpage)
	if not session then
		return blank
	end
	local left_side = (layout_state[tabpage] or {}).left_side
	local act_side = side == 3 and left_side or side
	local ok, found = pcall(function()
		if kind == APPEND then
			return act_side ~= nil and appendable(session, act_side, block_at(session, side, vim.v.lnum, false)) ~= nil
		end
		if block_at(session, side, vim.v.lnum, kind ~= DROP) then
			return true
		end
		return kind == TAKE and change_at(session, side, vim.v.lnum, left_side) ~= nil
	end)
	return (ok and found) and icon or blank
end

local function at_mouse()
	local pos = vim.fn.getmousepos()
	if not pos or pos.winid == 0 or not vim.api.nvim_win_is_valid(pos.winid) then
		return nil
	end

	local tabpage = vim.api.nvim_win_get_tabpage(pos.winid)
	local session = session_of(tabpage)
	if not session then
		return nil
	end

	local bufnr = vim.api.nvim_win_get_buf(pos.winid)
	local side = (bufnr == session.original_bufnr and 1)
		or (bufnr == session.modified_bufnr and 2)
		or (bufnr == session.result_bufnr and 3)
		or nil
	if not side then
		return nil
	end
	return tabpage, session, side, pos.line
end

local function park_in(session, side, block)
	local win = side == 1 and session.original_win or session.modified_win
	local r = side == 1 and block.output1_range or block.output2_range
	if win and vim.api.nvim_win_is_valid(win) and r and r.end_line > r.start_line then
		vim.api.nvim_set_current_win(win)
		vim.api.nvim_win_set_cursor(win, { r.start_line, 0 })
		return true
	end
	return false
end

local function park_cursor(session, block)
	return park_in(session, 1, block) or park_in(session, 2, block)
end

function _G.CodediffGutterTake()
	local tabpage, session, side, lnum = at_mouse()
	if not tabpage then
		return
	end

	local act_side = side
	if side == 3 then
		act_side = (layout_state[tabpage] or {}).left_side
	end

	local change = change_at(session, side, lnum, act_side)
	if change then
		apply_change(session, change)
		return
	end

	if not act_side then
		return
	end

	local conflict = require("codediff.ui.conflict")
	local prev = vim.api.nvim_get_current_win()

	if side == 3 then
		vim.api.nvim_set_current_win(session.result_win)
		vim.api.nvim_win_set_cursor(session.result_win, { lnum, 0 })
		pcall(act_side == 1 and conflict.diffget_incoming or conflict.diffget_current, tabpage)
	else
		local win = side == 1 and session.original_win or session.modified_win
		if win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_current_win(win)
			vim.api.nvim_win_set_cursor(win, { lnum, 0 })
			pcall(side == 1 and conflict.accept_incoming or conflict.accept_current, tabpage)
		end
	end

	if vim.api.nvim_win_is_valid(prev) then
		vim.api.nvim_set_current_win(prev)
	end
end

function _G.CodediffGutterAppend()
	local tabpage, session, side, lnum = at_mouse()
	if not tabpage then
		return
	end

	local act_side = side
	if side == 3 then
		act_side = (layout_state[tabpage] or {}).left_side
	end

	local entry = act_side and block_at(session, side, lnum, false)
	local lines = entry and appendable(session, act_side, entry)
	if not lines then
		return
	end

	vim.api.nvim_buf_set_lines(session.result_bufnr, entry.row_end, entry.row_end, false, lines)
	require("codediff.ui.conflict.signs").refresh_all_conflict_signs(session)
	require("codediff.ui.auto_refresh").refresh_result_now(session.result_bufnr)
end

function _G.CodediffGutterDrop()
	local tabpage, session, side, lnum = at_mouse()
	if not tabpage then
		return
	end

	local entry = block_at(session, side, lnum, false)
	if not entry then
		return
	end

	local prev = vim.api.nvim_get_current_win()
	if park_cursor(session, entry.block) then
		pcall(require("codediff.ui.conflict").discard, tabpage)
	end
	if vim.api.nvim_win_is_valid(prev) then
		vim.api.nvim_set_current_win(prev)
	end
end

local function finish()
	local tabpage = vim.api.nvim_get_current_tabpage()
	local session = session_of(tabpage)
	if not session then
		vim.notify("[codediff] Brak aktywnego widoku merge", vim.log.levels.WARN)
		return
	end

	local left = unresolved(session)
	if left > 0 then
		vim.notify(("[codediff] Zostało %d nierozwiązanych konfliktów"):format(left), vim.log.levels.WARN)
		return
	end

	local pending = #pending_of(session)
	if pending > 0 then
		vim.notify(
			("[codediff] Zostało %d nienałożonych zmian bezkonfliktowych — zapis je skasuje"):format(pending),
			vim.log.levels.WARN
		)
		return
	end

	vim.api.nvim_buf_call(session.result_bufnr, function()
		vim.cmd("silent write")
	end)
	vim.cmd("tabclose")
	vim.notify("[codediff] Zapisane i zamknięte", vim.log.levels.INFO)
end

local function quit_diff()
	local lifecycle = require("codediff.ui.lifecycle")
	local tabpage = vim.api.nvim_get_current_tabpage()
	if not lifecycle.get_session(tabpage) then
		vim.notify("[codediff] Brak aktywnego diffa w tej karcie", vim.log.levels.WARN)
		return
	end
	if not lifecycle.confirm_close_with_unsaved(tabpage) then
		return
	end
	if #vim.api.nvim_list_tabpages() == 1 then
		lifecycle.cleanup_for_quit(tabpage)
		vim.cmd("qall")
	else
		vim.cmd("tabclose")
	end
end


local function apply(tabpage)
	if not vim.api.nvim_tabpage_is_valid(tabpage) then
		return
	end

	local session = session_of(tabpage)
	if not session or not session.result_win or not vim.api.nvim_win_is_valid(session.result_win) then
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
			if vim.w[win].codediff_gutter then
				vim.wo[win].statuscolumn = ""
				vim.w[win].codediff_gutter = nil
			end
		end
		return
	end

	local function col(win)
		return win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_position(win)[2] or nil
	end

	local result_col = col(session.result_win)
	local orig_col, mod_col = col(session.original_win), col(session.modified_win)
	if not result_col or not orig_col or not mod_col then
		return
	end

	local left_side = orig_col < mod_col and 1 or 2
	local left_win = left_side == 1 and session.original_win or session.modified_win
	local right_win = left_side == 1 and session.modified_win or session.original_win

	layout_state[tabpage] = { left_side = left_side }

	local function button(fn, hl, side, kind, icon)
		return ("%%@v:lua.%s@%%#%s#%%{v:lua.CodediffGutterIcon(%d,%d,%d,'%s')}%%*%%X"):format(
			fn,
			hl,
			tabpage,
			side,
			kind,
			icon
		)
	end
	local function take(side, icon)
		return button("CodediffGutterTake", "CodeDiffGutterTake", side, TAKE, icon)
	end
	local function append(side, icon)
		return button("CodediffGutterAppend", "CodeDiffGutterAppend", side, APPEND, icon)
	end
	local function drop(side, icon)
		return button("CodediffGutterDrop", "CodeDiffGutterDrop", side, DROP, icon)
	end
	local function set(win, value)
		if not win or not vim.api.nvim_win_is_valid(win) then
			return
		end
		vim.wo[win].statuscolumn = value
		vim.w[win].codediff_gutter = value ~= "" or nil

		local profile_key = (win == session.original_win and "original")
			or (win == session.modified_win and "modified")
		local profiles = session.window_profiles
		if profile_key and profiles and profiles[profile_key] then
			profiles[profile_key].statuscolumn = value
		end
	end

	if col(left_win) < result_col and col(right_win) > result_col then
		set(left_win, "")
		set(
			session.result_win,
			"%s" .. drop(3, ICON_DROP_L) .. append(3, ICON_APPEND_L) .. take(3, ICON_TAKE_RIGHT) .. "%l "
		)
	else
		set(session.result_win, "")
		set(
			left_win,
			"%s%l " .. take(left_side, ICON_TAKE_RIGHT) .. append(left_side, ICON_APPEND_R) .. drop(left_side, ICON_DROP_R)
		)
	end
	local r = 3 - left_side
	set(right_win, "%s%l " .. take(r, ICON_TAKE_LEFT) .. append(r, ICON_APPEND_R) .. drop(r, ICON_DROP_R))
end


local CONFLICT_LABEL = {
	UU = "obie zmodyfikowane",
	AA = "obie dodały",
	DD = "obie usunęły",
	AU = "my dodaliśmy",
	UA = "oni dodali",
	DU = "my usunęliśmy",
	UD = "oni usunęli",
}

local function conflict_picker()
	local root = vim.trim(vim.fn.system({ "git", "rev-parse", "--show-toplevel" }))
	if vim.v.shell_error ~= 0 or root == "" then
		vim.notify("[codediff] Poza repozytorium git", vim.log.levels.WARN)
		return
	end

	local items, width = {}, 0
	for _, line in ipairs(vim.fn.systemlist({ "git", "-C", root, "status", "--porcelain" })) do
		local label = CONFLICT_LABEL[line:sub(1, 2)]
		if label then
			local rel = line:sub(4)
			items[#items + 1] = { path = root .. "/" .. rel, rel = rel, label = label }
			width = math.max(width, vim.fn.strdisplaywidth(label))
		end
	end
	if #items == 0 then
		vim.notify("[codediff] Brak nierozwiązanych konfliktów", vim.log.levels.INFO)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local displayer = require("telescope.pickers.entry_display").create({
		separator = "  ",
		items = { { width = width }, { remaining = true } },
	})

	pickers
		.new({}, {
			prompt_prefix = " 󰞇  ",
			finder = finders.new_table({
				results = items,
				entry_maker = function(item)
					return {
						value = item,
						path = item.path,
						ordinal = item.rel,
						display = function(entry)
							return displayer({ { entry.value.label, "Comment" }, entry.value.rel })
						end,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.file_previewer({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if entry then
						vim.cmd("CodeDiff merge " .. vim.fn.fnameescape(entry.value.path))
					end
				end)
				return true
			end,
		})
		:find()
end

return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	keys = {
		{ "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Git Diff Explorer (IntelliJ style)" },
		{ "<leader>gh", "<cmd>CodeDiff history<cr>", desc = "Git History" },
		{ "<leader>fm", conflict_picker, desc = "Konflikty merge (Telescope)" },
		{
			"<leader>gf",
			function()
				local path = vim.fn.expand("%:p")
				if path == "" then
					vim.notify("[codediff] Bufor bez pliku", vim.log.levels.WARN)
					return
				end
				if #vim.fn.systemlist({ "git", "ls-files", "-u", "--", path }) == 0 then
					vim.notify("[codediff] Ten plik nie jest w konflikcie", vim.log.levels.WARN)
					return
				end
				vim.cmd("CodeDiff merge " .. vim.fn.fnameescape(path))
			end,
			desc = "Merge conflict (bieżący plik)",
		},
	},
	opts = {
		diff = {
			layout = "inline",
			jump_to_first_change = true,
			conflict_result_position = "center",
		},
		explorer = {
			width = 30,
			view_mode = "tree",
		},
		keymaps = {
			view = {
				quit = "q",
				toggle_layout = "t",
			},
		},
	},
	config = function(_, opts)
		require("codediff").setup(opts)

		vim.api.nvim_set_hl(0, "CodeDiffGutterTake", { link = "DiagnosticOk", default = true })
		vim.api.nvim_set_hl(0, "CodeDiffGutterAppend", { link = "DiagnosticWarn", default = true })
		vim.api.nvim_set_hl(0, "CodeDiffGutterDrop", { link = "DiagnosticError", default = true })

		vim.api.nvim_create_user_command("Qm", quit_diff, { desc = "Zamknij diff/merge bez zapisu" })
		vim.cmd([[cnoreabbrev <expr> qm (getcmdtype() ==# ':' && getcmdline() ==# 'qm') ? 'Qm' : 'qm']])

		local group = vim.api.nvim_create_augroup("CodeDiffGutterButtons", { clear = true })

		vim.api.nvim_create_autocmd({ "WinEnter", "WinNew", "BufWinEnter", "TabEnter" }, {
			group = group,
			callback = function()
				apply(vim.api.nvim_get_current_tabpage())
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
			callback = function(ev)
				local tabpage = (ev.data and ev.data.tabpage) or vim.api.nvim_get_current_tabpage()
				for _, delay in ipairs({ 200, 600 }) do
					vim.defer_fn(function()
						apply(tabpage)
						local session = session_of(tabpage)
						if session then
							require("codediff.ui.lifecycle").set_tab_keymap(tabpage, "n", "<leader>cq", finish, {
								desc = "Zapisz wynik merge i zamknij",
							})
						end
					end, delay)
				end
			end,
		})

		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "CodeDiffClose",
			callback = function()
				layout_state, block_cache = {}, {}
				changes_cache, pending_cache = {}, {}
			end,
		})

		vim.api.nvim_create_user_command("CodeDiffSelfTest", function()
			local base = { "a", "b", "c", "d" }
			local blocks = { { base_range = { start_line = 2, end_line = 3 } } }
			local got = side_changes(base, { "a", "OURS", "c", "D-MERGED" }, blocks, 2)
			assert(#got == 1, "zmiana w regionie konfliktu ma zniknąć, bezkonfliktowa zostać")
			assert(got[1].first == 4 and got[1].count == 1, "pozycja w BASE")
			assert(vim.deep_equal(got[1].lines, { "D-MERGED" }) and got[1].side == 2, "treść i strona")
			assert(got[1].pane_first == 4 and got[1].pane_last == 4, "pozycja w panelu")

			local del = side_changes(base, { "a", "b", "c" }, {}, 1)
			assert(#del == 1 and #del[1].lines == 0, "delecja")
			assert(del[1].pane_first >= 1 and del[1].pane_last >= 1, "delecja ma klikalny wiersz w panelu")

			assert(#side_changes(base, { "a", "X", "c", "d" }, blocks, 1) == 0, "sam konflikt => nic")
			vim.notify("[codediff] self-test OK", vim.log.levels.INFO)
		end, { desc = "Sprawdź wyłuskiwanie zmian bezkonfliktowych" })
	end,
}
