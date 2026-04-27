local M = {}

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
        for l in io.lines(path) do table.insert(content, l) end
    end
    table.insert(content, 1, line)
    local f = io.open(path, "w")
    if f then
        f:write(table.concat(content, "\n") .. "\n")
        f:close()
    end
end

function M.on_file_added(file_path)
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
            ["Add to lib.rs"]  = parent_dir .. "/lib.rs",
            ["Add to mod.rs"]  = parent_dir .. "/mod.rs",
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
                if not choice then return end
                local target = choices[choice]
                insert_at_top(target, "mod " .. filename .. ";")
                vim.notify("Added 'mod " .. filename .. "' to " .. vim.fn.fnamemodify(target, ":t"))
            end)
        end
    end
end

return M
