local utils = require("plugins.ui.system_ui.utils")
local M = {}

local UI = {
	transparent = {
		"Normal",
		"NormalNC",
		"MsgArea",
		"SignColumn",
		"FoldColumn",
		"NormalDim",
		"InclineNormal",
		"InclineNormalNC",
		"NormalSB",
		"StatusLineDim",
		"EndOfBuffer",
		"NonText",
		"StatusLine",
		"StatusLineNC",
	},

	surfaces = {
		"NormalFloat",
		"Pmenu",
		"PmenuKind",
		"PmenuExtra",
		"PmenuMatch",
		"BlinkCmpMenu",
		"BlinkCmpDoc",
		"LazyNormal",
		"FloatTitle",
		"DialogFloatNormal",
		"ToolWindowFloatNormal",
		"PopupCodeViewFloat",
		"SnacksPicker",
		"TroubleNormal",
		"TroubleNormalNC",
		"NotifyBackground",
		"TelescopeNormal",
		"TelescopeResultsNormal",
		"TelescopePreviewNormal",
		"TelescopePromptNormal",
		"TelescopeTitle",
		"NoiceCmdline",
		"NoicePopup",
	},

	borders = {
		"FloatBorder",
		"WinSeparator",
		"VertSplit",
		"LspInfoBorder",
		"LazyBorder",
		"BlinkCmpMenuBorder",
		"BlinkCmpDocBorder",
		"BlinkCmpSignatureHelpBorder",
		"DialogFloatBorder",
		"PopupFloatBorder",
		"PopupCodeViewFloatBorder",
		"SnacksPickerBorder",
		"WinBar",
		"WinBarNC",
		"TelescopeBorder",
		"TelescopePromptBorder",
		"TelescopeResultsBorder",
		"TelescopePreviewBorder",
		"NoiceCmdlineBorder",
		"NoicePopupBorder",
		"NotifyBorder",
	},

	selection = { "Visual" },
	search = { "Search" },
	search_current = { "CurSearch" },
}

function M.apply(c)
	local function hl(group, opts)
		vim.api.nvim_set_hl(0, group, opts)
	end
	local function link(target, source)
		vim.api.nvim_set_hl(0, target, { link = source, default = false })
	end
	local function apply_list(list, opts)
		for _, group in ipairs(list) do
			hl(group, opts)
		end
	end

	apply_list(UI.transparent, { bg = "NONE", fg = c.on_background })
	apply_list(UI.surfaces, { bg = c.surface_container_low, fg = c.on_surface })
	apply_list(UI.borders, { bg = c.surface_container_low, fg = c.outline })

	apply_list(UI.selection, { bg = c.secondary_container, fg = c.on_secondary_container })
	apply_list(UI.search, { bg = c.tertiary_container, fg = c.on_tertiary_container })
	apply_list(UI.search_current, { bg = c.primary, fg = c.on_primary, bold = true })

	local bubble_levels = {
		{ bg = "NONE", fg = c.outline_variant },
		{ bg = c.surface_container_low, fg = c.on_surface_variant },
		{ bg = c.surface_container, fg = c.on_surface },
		{ bg = c.secondary_container, fg = c.on_secondary_container },
		{ bg = c.tertiary_container, fg = c.on_tertiary_container },
		{ bg = c.primary, fg = c.on_primary },
		{ bg = c.tertiary, fg = c.on_tertiary },
		{ bg = c.error, fg = c.on_error },
	}
	for i, level in ipairs(bubble_levels) do
		hl("BubbleLevel" .. i, { bg = level.bg, fg = level.fg, bold = (i > 5) })
	end

	local semantics = {
		Error = { color = c.error, notify = "ERROR" },
		Warn = { color = c.tertiary, notify = "WARN" },
		Info = { color = c.primary, notify = "INFO" },
		Hint = { color = c.secondary, notify = "DEBUG" },
	}

	for name, data in pairs(semantics) do
		local col = data.color
		local notif = data.notify

		hl("Diagnostic" .. name, { fg = col })
		hl("DiagnosticSign" .. name, { fg = col, bg = "NONE" })
		hl("DiagnosticUnderline" .. name, { sp = col, underline = true })
		hl("DiagnosticVirtualText" .. name, { fg = col, bg = utils.blend(col, c.background, 0.15) })
		hl("DiagnosticUnresolved", { fg = c.error })

		hl("Notify" .. notif .. "Icon", { fg = col })
		hl("Notify" .. notif .. "Title", { fg = col, bold = true })
		hl("Notify" .. notif .. "Border", { fg = col })
		hl("Notify" .. notif .. "Body", { fg = c.on_surface, bg = "NONE" })
	end

	hl("DiffAdd", { fg = c.primary, bg = "NONE" })
	hl("DiffChange", { fg = c.tertiary, bg = "NONE" })
	hl("DiffDelete", { fg = c.error, bg = "NONE" })
	link("GitSignsAdd", "DiffAdd")
	link("GitSignsChange", "DiffChange")
	link("GitSignsDelete", "DiffDelete")

	hl("TelescopePromptPrefix", { fg = c.tertiary, bg = c.surface_container_high })
	hl("TelescopeMatching", { fg = c.primary, bold = true })
	hl("TelescopeSelection", { bg = c.surface_container_highest, bold = true })
	hl("TelescopeSelectionCaret", { fg = c.primary, bg = c.surface_container_highest })
	hl("TelescopePromptTitle", { bg = c.primary, fg = c.on_primary, bold = true })

	hl("CursorLine", { bg = c.surface_container_high })
	hl("CursorLineNr", { fg = c.primary, bold = true })
	hl("LineNr", { fg = c.outline_variant })

	hl("PmenuSel", { bg = c.primary, fg = c.on_primary, bold = true })
	link("BlinkCmpMenuSelection", "PmenuSel")

	hl("MatchParen", { bg = c.surface_variant, fg = c.primary, bold = true })
	hl("IblChar", { fg = c.surface_container_highest })
	hl("IblScope", { fg = c.primary })

	hl("NoiceFormatProgressTodo", { bg = "NONE", fg = c.outline })
	hl("NoiceFormatProgressDone", { bg = "NONE", fg = c.primary })
	link("NoiceFormatLevelError", "DiagnosticError")
	link("NoiceFormatLevelWarn", "DiagnosticWarn")
	link("NoiceFormatLevelInfo", "DiagnosticInfo")

	hl("SystemUITerminal", { bg = c.surface_container, fg = c.on_background })
	vim.api.nvim_create_autocmd("TermOpen", {
		group = vim.api.nvim_create_augroup("SystemUITerminalFix", { clear = true }),
		pattern = "*",
		callback = function()
			vim.opt_local.winhighlight = "Normal:SystemUITerminal,NormalNC:SystemUITerminal"
		end,
	})

	vim.g.terminal_color_0 = c.surface_container_highest
	vim.g.terminal_color_1 = c.error
	vim.g.terminal_color_2 = c.primary
	vim.g.terminal_color_3 = c.tertiary
	vim.g.terminal_color_4 = c.secondary
	vim.g.terminal_color_5 = c.inverse_primary
	vim.g.terminal_color_6 = c.primary_fixed or c.primary
	vim.g.terminal_color_7 = c.on_surface
	vim.g.terminal_color_8 = c.outline
	vim.g.terminal_color_9 = c.error
	vim.g.terminal_color_10 = c.primary
	vim.g.terminal_color_11 = c.tertiary
	vim.g.terminal_color_12 = c.secondary
	vim.g.terminal_color_13 = c.inverse_primary
	vim.g.terminal_color_14 = c.primary_fixed or c.primary
	vim.g.terminal_color_15 = c.on_surface_variant

	local rainbow_colors = {
		RainbowDelimiterRed = c.error,
		RainbowDelimiterYellow = c.tertiary,
		RainbowDelimiterBlue = c.primary,
		RainbowDelimiterOrange = c.secondary,
		RainbowDelimiterGreen = c.primary_fixed or c.primary,
		RainbowDelimiterViolet = c.inverse_primary,
		RainbowDelimiterCyan = c.outline,
	}

	link("CodeDiffLineInsert", "DiffAdd")
	link("CodeDiffLineDelete", "DiffDelete")

	hl("CodeDiffCharInsert", { bg = utils.blend(c.primary, c.background, 0.4) })
	hl("CodeDiffCharDelete", { bg = utils.blend(c.error, c.background, 0.4) })

	for group, color in pairs(rainbow_colors) do
		hl(group, { fg = color })
	end
end

return M
