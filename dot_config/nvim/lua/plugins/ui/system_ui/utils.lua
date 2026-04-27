local M = {}

function M.read_json(path)
	local expanded = vim.fn.expand(path)
	local f = io.open(expanded, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	local ok, parsed = pcall(vim.json.decode, content)
	return ok and parsed or nil
end

function M.blend(foreground, background, alpha)
	local function hex_to_rgb(hex)
		local r, g, b = hex:sub(2, 3), hex:sub(4, 5), hex:sub(6, 7)
		return tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)
	end

	local function rgb_to_hex(r, g, b)
		return string.format("#%02x%02x%02x", math.floor(r), math.floor(g), math.floor(b))
	end

	local r1, g1, b1 = hex_to_rgb(foreground)
	local r2, g2, b2 = hex_to_rgb(background)

	local r = r1 * alpha + r2 * (1 - alpha)
	local g = g1 * alpha + g2 * (1 - alpha)
	local b = b1 * alpha + b2 * (1 - alpha)

	return rgb_to_hex(r, g, b)
end

return M
