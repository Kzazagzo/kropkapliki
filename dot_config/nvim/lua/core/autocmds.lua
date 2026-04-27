local function augroup(name)
	return vim.api.nvim_create_augroup("core_" .. name, { clear = true })
end
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
	group = augroup("HighlightYank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
	desc = "Highlight yank",
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = last_cursor_group,
	callback = function(args)
		local exclude_ft = { "gitcommit", "gitrebase", "commit", "rebase", "svn", "hgcommit" }
		local ft = vim.bo[args.buf].filetype

		if vim.tbl_contains(exclude_ft, ft) or vim.b[args.buf].last_pos_set then
			return
		end
		vim.b[args.buf].last_pos_set = true

		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local lcount = vim.api.nvim_buf_line_count(args.buf)

		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
			vim.cmd("normal! zz")
		end
	end,
	desc = "Restore last cursor position and center screen",
})

autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

autocmd("BufWritePre", {
	group = augroup("trim_whitespace"),
	pattern = "*",
	callback = function(event)
		if vim.bo[event.buf].filetype == "markdown" then
			return
		end
		local save_cursor = vim.api.nvim_win_get_cursor(0)
		vim.cmd([[keeppatterns %s/\s\+$//e]])
		vim.api.nvim_win_set_cursor(0, save_cursor)
	end,
})

autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
		"trouble",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

autocmd({ "InsertEnter", "InsertLeave" }, {
	group = augroup("dynamic_numbers"),
	callback = function(event)
		if vim.wo.number then
			vim.wo.relativenumber = event.event == "InsertLeave"
		end
	end,
})

function _G.jvm_foldexpr()
	local line = vim.fn.getline(vim.v.lnum)
	if line:match("^%s*import%s") then
		return 1
	end
	return vim.treesitter.foldexpr()
end

autocmd("FileType", {
	group = augroup("jvm_import_fold"),
	pattern = { "java", "kotlin", "groovy", "scala" },
	callback = function(event)
		vim.opt_local.foldexpr = "v:lua.jvm_foldexpr()"
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(event.buf) or vim.b[event.buf].imports_folded then
				return
			end
			for lnum, text in ipairs(vim.api.nvim_buf_get_lines(event.buf, 0, 200, false)) do
				if text:match("^%s*import%s") then
					vim.b[event.buf].imports_folded = true
					pcall(vim.cmd, ("silent! %dfoldclose"):format(lnum))
					return
				end
			end
		end)
	end,
})

autocmd("TermOpen", {
	group = augroup("clean_terminal"),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.cmd("startinsert")
	end,
})

autocmd("BufReadPre", {
	group = augroup("large_file"),
	callback = function(event)
		local file = event.match
		local stat = vim.uv.fs_stat(file)
		if stat and stat.size > 1024 * 1024 then
			vim.b[event.buf].large_file = true
			vim.opt_local.foldmethod = "manual"
			vim.opt_local.spell = false
			vim.opt_local.swapfile = false
			vim.opt_local.undofile = false
			vim.notify("Large file detected. Some features disabled for performance.", vim.log.levels.WARN)
		end
	end,
})

autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
	group = augroup("save_view"),
	callback = function(event)
		if vim.b[event.buf].large_file then
			return
		end
		if vim.bo[event.buf].buftype == "" and vim.bo[event.buf].filetype ~= "" then
			vim.cmd("silent! mkview")
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		vim.notify("saved", vim.log.levels.INFO)
	end,
})

autocmd("BufWinEnter", {
	group = augroup("load_view"),
	callback = function(event)
		if vim.b[event.buf].large_file then
			return
		end
		if vim.bo[event.buf].buftype == "" and vim.bo[event.buf].filetype ~= "" then
			vim.cmd("silent! loadview")
		end
	end,
})

-- TODO: this leaks domain but idfs for now
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ui_clean_status", { clear = true }),
	pattern = { "oil", "telescope", "yazi", "lazy", "mason", "checkhealth" },
	callback = function()
		vim.opt_local.laststatus = 0
		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = 0,
			once = true,
			callback = function()
				vim.opt.laststatus = 3
			end,
		})
	end,
})
