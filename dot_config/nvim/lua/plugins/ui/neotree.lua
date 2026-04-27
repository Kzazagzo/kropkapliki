return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<C-1>", "<cmd>Neotree toggle<cr>", desc = "Neo-tree (Toggle)" },
	},
	config = function()
		local diff_source_node = nil

		local function file_exists(path)
			local f = io.open(path, "r")
			if f then
				f:close()
				return true
			end
			return false
		end

		local function insert_at_top(path, line)
			local content = {}
			if file_exists(path) then
				for l in io.lines(path) do
					table.insert(content, l)
				end
			end
			table.insert(content, 1, line)
			local f = io.open(path, "w")
			if f then
				f:write(table.concat(content, "\n") .. "\n")
				f:close()
			end
		end

		local function on_file_added(file_path)
			local ext = vim.fn.fnamemodify(file_path, ":e")
			local filename = vim.fn.fnamemodify(file_path, ":t:r")
			local parent_dir = vim.fn.fnamemodify(file_path, ":h")

			if ext == "java" then
				local parts = vim.split(parent_dir, "/")
				local package_parts = {}
				local found_src = false
				for _, part in ipairs(parts) do
					if found_src then
						table.insert(package_parts, part)
					elseif part == "java" or part == "src" then
						found_src = true
					end
				end
				if #package_parts > 0 then
					local pkg = table.concat(package_parts, ".")
					local f = io.open(file_path, "w")
					if f then
						f:write("package " .. pkg .. ";\n\npublic class " .. filename .. " {\n\n}\n")
						f:close()
					end
				end
			elseif ext == "rs" and filename ~= "main" and filename ~= "lib" and filename ~= "mod" then
				local choices = {
					["Add to main.rs"] = parent_dir .. "/main.rs",
					["Add to lib.rs"] = parent_dir .. "/lib.rs",
					["Add to mod.rs"] = parent_dir .. "/mod.rs",
				}

				local valid_choices = {}
				for label, path in pairs(choices) do
					if file_exists(path) or label == "Add to mod.rs" then
						table.insert(valid_choices, label)
					end
				end

				if #valid_choices > 0 then
					vim.ui.select(valid_choices, {
						prompt = "Attach '" .. filename .. "' as module to:",
					}, function(choice)
						if not choice then
							return
						end
						local target = choices[choice]
						insert_at_top(target, "mod " .. filename .. ";")
						vim.notify("Added 'mod " .. filename .. "' to " .. vim.fn.fnamemodify(target, ":t"))
					end)
				end
			end
		end

		local function diff_files(state)
			local node = state.tree:get_node()
			local log = require("neo-tree.log")

			if diff_source_node and diff_source_node ~= node.id then
				local target_path = node.id
				local source_path = diff_source_node

				vim.cmd("edit " .. source_path)
				vim.cmd("vertical diffsplit " .. target_path)

				log.info("Diffing: " .. vim.fn.fnamemodify(source_path, ":t") .. " vs " .. node.name)
				diff_source_node = nil
			else
				diff_source_node = node.id
				log.info("Diff source marked: " .. node.name)
			end
		end

		local function copy_selector(state)
			local node = state.tree:get_node()
			local filepath = node:get_id()
			local filename = node.name
			local modify = vim.fn.fnamemodify

			local results = {
				["Filename"] = filename,
				["Path (Relative)"] = modify(filepath, ":."),
				["Path (Absolute)"] = filepath,
				["Path (Home)"] = modify(filepath, ":~"),
				["Extension"] = modify(filename, ":e"),
				["URI"] = vim.uri_from_fname(filepath),
			}

			local choices = vim.tbl_keys(results)
			table.sort(choices)

			vim.ui.select(choices, {
				prompt = "Select format to copy:",
				format_item = function(item)
					return string.format("%-20s: %s", item, results[item])
				end,
			}, function(choice)
				if choice then
					local val = results[choice]
					vim.fn.setreg("+", val)
					vim.notify("Copied to clipboard: " .. val)
				end
			end)
		end

		local function smart_l(state)
			local node = state.tree:get_node()
			local renderer = require("neo-tree.ui.renderer")
			local fs_sources = require("neo-tree.sources.filesystem")

			if node.type == "directory" then
				if not node:is_expanded() then
					fs_sources.toggle_directory(state, node)
				elseif node:has_children() then
					renderer.focus_node(state, node:get_child_ids()[1])
				end
			else
				vim.cmd("normal! j")
			end
		end

		local function smart_h(state)
			local node = state.tree:get_node()
			local renderer = require("neo-tree.ui.renderer")
			local fs_sources = require("neo-tree.sources.filesystem")

			if node.type == "directory" and node:is_expanded() then
				fs_sources.toggle_directory(state, node)
			else
				local parent_id = node:get_parent_id()
				if parent_id then
					renderer.focus_node(state, parent_id)
				end
			end
		end

		require("neo-tree").setup({
			close_if_last_window = true,
			filesystem = {
				group_empty_dirs = true,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
			},
			window = {
				width = 35,
				mappings = {
					["<space>"] = "none",
					["l"] = "smart_l",
					["h"] = "smart_h",
					["<Right>"] = "smart_l",
					["<Left>"] = "smart_h",
					["j"] = "move_cursor_down",
					["k"] = "move_cursor_up",
					["D"] = "diff_files",
					["Y"] = "copy_selector",
				},
			},
			commands = {
				smart_l = smart_l,
				smart_h = smart_h,
				diff_files = diff_files,
				copy_selector = copy_selector,
			},
			event_handlers = {
				{
					event = "file_added",
					handler = on_file_added,
				},
			},
		})
	end,
}
