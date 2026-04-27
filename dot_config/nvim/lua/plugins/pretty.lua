return {
	"pretty_formatter",
	dir = vim.fn.stdpath("config") .. "/lua/plugins",
	lazy = false,
	config = function()
		local function run_pipe(cmd, input)
			local out = vim.fn.systemlist(cmd, input)
			if vim.v.shell_error ~= 0 then
				return nil, table.concat(out, "\n")
			end
			return out, nil
		end

		local function detect(buf)
			local ft = vim.bo[buf].filetype
			if ft == "json" or ft == "jsonc" then
				return "json"
			end
			if ft == "yaml" or ft:match("^yaml%.") then
				return "yaml"
			end
			if ft == "toml" then
				return "toml"
			end

			local lines = vim.api.nvim_buf_get_lines(buf, 0, 50, false)
			local first = ""
			for _, l in ipairs(lines) do
				if l:match("%S") then
					first = l
					break
				end
			end
			if first:match("^%s*[{%[]") then
				local jsonl = true
				local count = 0
				for _, l in ipairs(lines) do
					if l:match("%S") then
						count = count + 1
						if not l:match("^%s*[{%[]") then
							jsonl = false
							break
						end
					end
				end
				if jsonl and count > 1 then
					return "jsonl"
				end
				return "json"
			end
			if first:match("^%s*[%w_-]+%s*=") or first:match("^%s*%[.+%]%s*$") then
				return "toml"
			end
			if first:match("^%s*[%w_-]+%s*:") or first:match("^%s*%-") then
				return "yaml"
			end
			return "json"
		end

		local formatters = {
			json = function(input)
				if vim.fn.executable("jq") == 1 then
					return run_pipe({ "jq", "." }, input)
				end
				local ok, decoded = pcall(vim.json.decode, table.concat(input, "\n"))
				if not ok then
					return nil, "vim.json decode failed: " .. decoded
				end
				local encoded = vim.json.encode(decoded)
				if vim.fn.executable("python3") == 1 then
					return run_pipe({ "python3", "-m", "json.tool", "--indent=2" }, input)
				end
				return vim.split(encoded, "\n"), nil
			end,
			jsonl = function(input)
				if vim.fn.executable("jq") ~= 1 then
					return nil, "jq required for jsonl"
				end
				local result = {}
				for i, line in ipairs(input) do
					if line:match("%S") then
						local out, err = run_pipe({ "jq", "." }, { line })
						if err then
							return nil, "line " .. i .. ": " .. err
						end
						for _, l in ipairs(out) do
							table.insert(result, l)
						end
						table.insert(result, "")
					end
				end
				return result, nil
			end,
			yaml = function(input)
				if vim.fn.executable("yq") == 1 then
					return run_pipe({ "yq", "-P", "." }, input)
				end
				if vim.fn.executable("prettier") == 1 then
					return run_pipe({ "prettier", "--parser", "yaml" }, input)
				end
				return nil, "yq or prettier required"
			end,
			toml = function(input)
				if vim.fn.executable("taplo") == 1 then
					return run_pipe({ "taplo", "fmt", "-" }, input)
				end
				return nil, "taplo required"
			end,
		}

		local function pretty(opts)
			local buf = vim.api.nvim_get_current_buf()
			local kind = opts.args ~= "" and opts.args or detect(buf)
			local fmt = formatters[kind]
			if not fmt then
				vim.notify("Unknown format: " .. kind, vim.log.levels.ERROR)
				return
			end

			local input = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			local output, err = fmt(input)
			if err then
				vim.notify("Pretty[" .. kind .. "]: " .. err, vim.log.levels.ERROR)
				return
			end

			vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
			vim.bo[buf].filetype = kind == "jsonl" and "json" or kind
			vim.notify("Pretty: " .. kind, vim.log.levels.INFO)
		end

		vim.api.nvim_create_user_command("Pretty", pretty, {
			nargs = "?",
			complete = function()
				return { "json", "jsonl", "yaml", "toml" }
			end,
			desc = "Format buffer (auto-detect or explicit type)",
		})

		vim.api.nvim_create_autocmd("StdinReadPost", {
			callback = function()
				vim.bo.buftype = "nofile"
				vim.schedule(function()
					pretty({ args = "" })
				end)
			end,
		})
	end,
}
