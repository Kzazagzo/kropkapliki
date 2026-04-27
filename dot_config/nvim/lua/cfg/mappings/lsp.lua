local M = {}

function M.attach(bufnr, client_id)
    local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    local builtin = require("telescope.builtin")

    map("gd", builtin.lsp_definitions, "Go to Definition")
    map("gr", builtin.lsp_references, "Go to References")
    map("gI", builtin.lsp_implementations, "Go to Implementation")
    map("gy", builtin.lsp_type_definitions, "Type Definition")
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("gD", vim.lsp.buf.declaration, "Go to Declaration")

    map("<C-LeftMouse>", "<LeftMouse><cmd>lua require('telescope.builtin').lsp_definitions()<cr>", "Go to Definition (mouse)")
    map("<C-RightMouse>", "<C-o>", "Back (mouse)")

    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")

    map("<leader>cR", "<cmd>LspRestart<CR>", "Restart LSP")
end

return M
