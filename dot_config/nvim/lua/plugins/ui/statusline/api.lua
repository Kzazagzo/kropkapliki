local M = {}

function M.create_bubble(opts)
	local level = type(opts.level) == "function" and opts.level() or (opts.level or 1)

	local config = {
		opts.render,
		cond = opts.cond,
		color = "BubbleLevel" .. level,
		padding = { left = 1, right = 1 },
	}

	if level == 1 then
		config.separator = nil
	else
		config.separator = { left = "", right = "" }
	end

	return config
end

return M
