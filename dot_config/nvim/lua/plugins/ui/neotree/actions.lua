local M = {}

local diff_source_node = nil

---@param state table Neo-tree state
function M.diff_files(state)
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

---@param state table Neo-tree state
function M.copy_selector(state)
    local node = state.tree:get_node()
    local filepath = node:get_id()
    local filename = node.name
    local modify = vim.fn.fnamemodify

    local results = {
        ["Filename"]        = filename,
        ["Path (Relative)"] = modify(filepath, ":."),
        ["Path (Absolute)"] = filepath,
        ["Path (Home)"]     = modify(filepath, ":~"),
        ["Extension"]       = modify(filename, ":e"),
        ["URI"]             = vim.uri_from_fname(filepath),
    }

    local choices = vim.tbl_keys(results)
    table.sort(choices)

    vim.ui.select(choices, {
        prompt = "Select format to copy:",
        format_item = function(item) return string.format("%-20s: %s", item, results[item]) end,
    }, function(choice)
        if choice then
            local val = results[choice]
            vim.fn.setreg("+", val)
            vim.notify("Copied to clipboard: " .. val)
        end
    end)
end


---@param state table
function M.smart_l(state)
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

---@param state table
function M.smart_h(state)
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

return M
