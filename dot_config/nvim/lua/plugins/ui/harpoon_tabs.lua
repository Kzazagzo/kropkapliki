local SLOTS = 4

local HL_INACTIVE = "BubbleLevel2"
local HL_ACTIVE = "BubbleLevel6"
local HL_EMPTY = "BubbleLevel1"
local HL_BUFFERS = "BubbleLevel2"

local focused = {
	winid = nil,
	bufnr = nil,
}

local function display_width(text)
	return vim.fn.strdisplaywidth(text)
end

local function spaces(width)
	return string.rep(" ", math.max(width, 0))
end

local function pad_right(segment, width, current_width)
	return segment .. "%#" .. HL_EMPTY .. "#" .. spaces(width - current_width)
end

local function pad_center(segment, width, current_width)
	local remaining = math.max(width - current_width, 0)
	local left = math.floor(remaining / 2)
	local right = remaining - left

	return "%#" .. HL_EMPTY .. "#" .. spaces(left) .. segment .. "%#" .. HL_EMPTY .. "#" .. spaces(right)
end

local function get_icon(filename)
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then
		return " ", ""
	end
	local icon, hl = devicons.get_icon(filename, vim.fn.fnamemodify(filename, ":e"), { default = true })
	return icon or " ", hl or ""
end

local function resolve_display_name(items, idx)
	local val = items[idx].value
	local basename = vim.fn.fnamemodify(val, ":t")

	for i = 1, SLOTS do
		if i ~= idx and items[i] and vim.fn.fnamemodify(items[i].value, ":t") == basename then
			local parent = vim.fn.fnamemodify(val, ":h:t")
			if parent ~= "" and parent ~= "." then
				return parent .. "/" .. basename
			end
		end
	end

	return basename
end

local function update_focused_buffer()
	local winid = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_win_get_buf(winid)

	focused.winid = winid
	focused.bufnr = bufnr
end

local function get_focused_buffer()
	local bufnr = focused.bufnr
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		local winid = vim.api.nvim_get_current_win()
		bufnr = vim.api.nvim_win_get_buf(winid)
	end

	return bufnr
end

local function get_current_file()
	local bufnr = get_focused_buffer()
	return vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
end

local function get_project_root(bufnr)
	return vim.fs.root(bufnr, { ".git", "package.json", "Cargo.toml", "go.mod", "pom.xml", "build.gradle", "pyproject.toml", ".nvim-project" })
		or vim.fn.getcwd()
end

local function make_relative_path(path, root)
	if path == "" then
		return ""
	end

	local normalized_path = vim.fs.normalize(path)
	local normalized_root = vim.fs.normalize(root)

	if vim.startswith(normalized_path, normalized_root .. "/") then
		return normalized_path:sub(#normalized_root + 2)
	end

	return vim.fn.fnamemodify(normalized_path, ":~:.")
end

local function strip_tail_extension(path)
	local dir = vim.fn.fnamemodify(path, ":h")
	local basename = vim.fn.fnamemodify(path, ":t")

	if basename:sub(1, 1) == "." and not basename:find("%.", 2) then
		return path
	end

	local name = basename:gsub("%.[^%.]+$", "")
	if dir == "" or dir == "." then
		return name
	end

	return dir .. "/" .. name
end

local function shorten_path(path, max_width)
	if path == "" or max_width <= 0 then
		return ""
	end

	if display_width(path) <= max_width then
		return path
	end

	local parts = vim.split(path, "/", { plain = true })
	for start = 2, #parts do
		local candidate = ".../" .. table.concat(vim.list_slice(parts, start), "/")
		if display_width(candidate) <= max_width then
			return candidate
		end
	end

	local basename = vim.fn.fnamemodify(path, ":t")
	if display_width(basename) <= max_width then
		return basename
	end

	if max_width <= 3 then
		return basename:sub(1, max_width)
	end

	return basename:sub(1, max_width - 3) .. "..."
end

local function build_current_file_segment(current_file, root, max_width)
	if max_width < 8 then
		return spaces(max_width), max_width
	end

	local relative = make_relative_path(current_file, root)
	local icon, ihl = get_icon(relative)
	local display_path = strip_tail_extension(relative)
	local prefix_width = display_width("  " .. icon .. " ")
	local suffix_width = display_width("  ")
	local path_width = max_width - prefix_width - suffix_width
	local path = shorten_path(display_path, path_width)

	if path == "" then
		return spaces(max_width), max_width
	end

	local segment = "%#" .. HL_INACTIVE .. "#  "
	if ihl ~= "" then
		segment = segment .. "%#" .. ihl .. "#" .. icon .. "%#" .. HL_INACTIVE .. "# "
	else
		segment = segment .. icon .. " "
	end

	local width = prefix_width + display_width(path) + suffix_width
	return pad_right(segment .. path .. "  ", max_width, width), max_width
end

local function build_harpoon_slot(item, items, idx, current_file, root, max_width)
	if max_width <= 0 then
		return "", 0
	end

	local active = vim.fs.normalize(root .. "/" .. item.value) == current_file
	local name = resolve_display_name(items, idx)
	local icon, ihl = get_icon(name)
	local display_name = strip_tail_extension(name)
	local slot_hl = active and HL_ACTIVE or HL_INACTIVE
	local marker = active and " ●" or ""
	local fixed_width = display_width(icon .. " " .. marker)
	local name_width = max_width - fixed_width

	if name_width < 1 then
		local text = active and "●" or tostring(idx)
		return "%#" .. slot_hl .. "#" .. text, display_width(text)
	end

	display_name = shorten_path(display_name, name_width)
	local text_width = display_width(icon .. " " .. display_name .. marker)
	local segment = "%#" .. slot_hl .. "#"

	if not active and ihl ~= "" then
		segment = segment .. "%#" .. ihl .. "#" .. icon .. "%#" .. slot_hl .. "# "
	else
		segment = segment .. icon .. " "
	end

	return segment .. display_name .. marker, text_width
end

local function get_used_harpoon_items(items)
	local used = {}

	for i = 1, SLOTS do
		if items[i] then
			table.insert(used, { item = items[i], idx = i })
		end
	end

	return used
end

local function build_harpoon_segment(current_file, max_width)
	local ok, harpoon = pcall(require, "harpoon")
	if not ok then
		return spaces(max_width), max_width
	end

	local list = harpoon:list()
	local items = list.items

	if list:length() < 1 then
		return spaces(max_width), max_width
	end

	local root = list.config:get_root_dir()
	local used = get_used_harpoon_items(items)
	local count = #used

	if count == 0 then
		return spaces(max_width), max_width
	end

	local parts = {}
	local gaps = count - 1
	local available = max_width - gaps

	if available < count then
		return spaces(max_width), max_width
	end

	local slot_width = math.floor(available / count)
	local extra = available % count
	local group_width = math.max(count - 1, 0)

	for i, entry in ipairs(used) do
		local width = slot_width + (i <= extra and 1 or 0)
		local slot, actual_width = build_harpoon_slot(entry.item, items, entry.idx, current_file, root, width)
		table.insert(parts, slot)
		group_width = group_width + actual_width
	end

	local segment = table.concat(parts, "%#" .. HL_EMPTY .. "# ")
	return pad_center(segment, max_width, group_width), max_width
end

local function count_listed_buffers()
	local count = 0

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
			count = count + 1
		end
	end

	return count
end

local function build_buffers_segment(max_width)
	if max_width < 5 then
		return spaces(max_width), max_width
	end

	local count = count_listed_buffers()
	if count <= 1 then
		return spaces(max_width), max_width
	end

	local text = " " .. count .. " 󰈚 "
	local width = display_width(text)
	if width > max_width then
		text = " " .. count .. " "
		width = display_width(text)
	end

	if width > max_width then
		return spaces(max_width), max_width
	end

	local segment = "%#" .. HL_EMPTY .. "#" .. spaces(max_width - width)
	return segment .. "%#" .. HL_BUFFERS .. "#" .. text, max_width
end

_G._harpoon_tabline = function()
	vim.o.showtabline = 2

	local current_file = get_current_file()
	local current_bufnr = get_focused_buffer()
	local columns = vim.o.columns
	local left_width = math.floor(columns / 3)
	local center_width = math.floor((columns + 1) / 3)
	local right_width = columns - left_width - center_width
	local file_segment = build_current_file_segment(current_file, get_project_root(current_bufnr), left_width)
	local harpoon_segment = build_harpoon_segment(current_file, center_width)
	local buffers_segment = build_buffers_segment(right_width)

	return file_segment .. harpoon_segment .. buffers_segment
end

return {
	"ThePrimeagen/harpoon",
	init = function()
		update_focused_buffer()
		vim.o.showtabline = 2
		vim.o.tabline = "%!v:lua._harpoon_tabline()"

		local group = vim.api.nvim_create_augroup("HarpoonTabs", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter", "VimResized", "User" }, {
			group = group,
			pattern = { "*", "HarpoonListUpdated" },
			callback = function()
				update_focused_buffer()
				vim.schedule(function()
					vim.o.showtabline = 2
					vim.cmd("redrawtabline")
				end)
			end,
		})
	end,
}
