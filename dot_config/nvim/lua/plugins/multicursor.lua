return {
	"jake-stewart/multicursor.nvim",
	branch = "1.0",
	event = "VeryLazy",
	config = function()
		local mc = require("multicursor-nvim")
		local map = vim.keymap.set

		mc.setup()

		map({ "n", "v" }, "<C-Up>", function()
			mc.lineAddCursor(-1)
		end, { desc = "Add cursor above" })
		map({ "n", "v" }, "<C-Down>", function()
			mc.lineAddCursor(1)
		end, { desc = "Add cursor below" })
		map({ "n", "v" }, "<leader><Up>", function()
			mc.lineSkipCursor(-1)
		end, { desc = "Skip cursor above" })
		map({ "n", "v" }, "<leader><Down>", function()
			mc.lineSkipCursor(1)
		end, { desc = "Skip cursor below" })

		map({ "n", "v" }, "<C-n>", function()
			mc.matchAddCursor(1)
		end, { desc = "Add cursor next match" })
		map({ "n", "v" }, "<C-S-n>", function()
			mc.matchAddCursor(-1)
		end, { desc = "Add cursor prev match" })
		map({ "n", "v" }, "<C-x>", function()
			mc.matchSkipCursor(1)
		end, { desc = "Skip next match" })
		map({ "n", "v" }, "<leader>A", mc.matchAllAddCursors, { desc = "Add cursors to all matches" })

		map("n", "<C-LeftMouse>", mc.handleMouse)
		map("n", "<C-LeftDrag>", mc.handleMouseDrag)
		map({ "n", "v" }, "<C-q>", mc.toggleCursor, { desc = "Toggle cursor" })

		map("v", "I", mc.insertVisual, { desc = "Insert at beginning" })
		map("v", "A", mc.appendVisual, { desc = "Append at end" })

		mc.addKeymapLayer(function(layerSet)
			layerSet("n", "<Esc>", function()
				if not mc.cursorsEnabled() then
					mc.enableCursors()
				elseif mc.hasCursors() then
					mc.clearCursors()
				end
			end)

			layerSet({ "n", "v" }, "<Tab>", mc.nextCursor, { desc = "Next cursor" })
			layerSet({ "n", "v" }, "<S-Tab>", mc.prevCursor, { desc = "Prev cursor" })
			layerSet({ "n", "v" }, "<leader>x", mc.deleteCursor, { desc = "Delete cursor" })
			layerSet("n", "<leader>a", mc.alignCursors, { desc = "Align cursors" })
		end)

		local hl = vim.api.nvim_set_hl
		hl(0, "MultiCursorCursor", { link = "Substitute" })
		hl(0, "MultiCursorVisual", { link = "Visual" })
		hl(0, "MultiCursorSign", { link = "SignColumn" })
		hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
	end,
}
