local ns = vim.api.nvim_create_namespace("unresolved_highlight")

vim.diagnostic.handlers["unresolved"] = {
	show = function(_, bufnr, diagnostics, _)
		for _, d in ipairs(diagnostics) do
			if d.severity == vim.diagnostic.severity.ERROR then
				pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, d.lnum, d.col, {
					end_row = d.end_lnum or d.lnum,
					end_col = d.end_col or (d.col + 1),
					hl_group = "DiagnosticUnresolved",
					priority = 200,
				})
			end
		end
	end,
	hide = function(_, bufnr)
		vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	end,
}
