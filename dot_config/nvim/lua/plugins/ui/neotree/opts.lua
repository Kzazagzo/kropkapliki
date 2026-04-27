local M = {}

function M.get()
    local actions = require("plugins.neotree.actions")

    return {
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
                ["<Left>"]  = "smart_h",

                ["j"] = "move_cursor_down",
                ["k"] = "move_cursor_up",

                ["D"] = "diff_files",
                ["Y"] = "copy_selector",
            },
        },
        commands = {
            smart_l = actions.smart_l,
            smart_h = actions.smart_h,
            diff_files = actions.diff_files,
            copy_selector = actions.copy_selector,
        },
    }
end

return M