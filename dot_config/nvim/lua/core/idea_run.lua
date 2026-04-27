local M = {}

local function unescape(s)
	return (s:gsub("&quot;", '"'):gsub("&apos;", "'"):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&"))
end

local function subst(s, root)
	return (s:gsub("%$PROJECT_DIR%$", root):gsub("%$MODULE_DIR%$", root):gsub("%$USER_HOME%$", vim.env.HOME or ""))
end

local function parse_opts(block, root)
	local opts, env = {}, {}
	for name, value in block:gmatch('<option name="([^"]+)"%s+value="([^"]*)"') do
		opts[name] = subst(unescape(value), root)
	end
	for name, list in block:gmatch('<option name="([^"]+)"%s*>%s*<list>(.-)</list>') do
		local items = {}
		for value in list:gmatch('<option value="([^"]*)"') do
			items[#items + 1] = subst(unescape(value), root)
		end
		opts[name] = items
	end
	for name, value in block:gmatch('<env name="([^"]+)"%s+value="([^"]*)"') do
		env[name] = subst(unescape(value), root)
	end
	return opts, env
end

local function split_args(s)
	return s and s ~= "" and vim.split(s, "%s+", { trimempty = true }) or {}
end

local function gradlew(root)
	return (require("core.gradle").cmd(root))
end

local builders = {
	GradleRunConfiguration = function(opts, root)
		local cmd = { gradlew(root) }
		vim.list_extend(cmd, opts.taskNames or {})
		vim.list_extend(cmd, split_args(opts.scriptParameters))
		return #cmd > 1 and cmd or nil
	end,
	MavenRunConfiguration = function(opts, root)
		local mroot = vim.fs.root(root, { "mvnw", "pom.xml" }) or root
		local mvn = vim.fn.executable(mroot .. "/mvnw") == 1 and mroot .. "/mvnw" or "mvn"
		local cmd = { mvn }
		vim.list_extend(cmd, split_args(opts.goals or opts.commandLine))
		return #cmd > 1 and cmd or nil
	end,
	Application = function(opts, root)
		local cmd = { gradlew(root), "run" }
		if opts.PROGRAM_PARAMETERS then
			cmd[#cmd + 1] = "--args=" .. opts.PROGRAM_PARAMETERS
		end
		return cmd
	end,
	GoApplicationRunConfiguration = function(opts, root)
		local target = opts.kind == "FILE" and opts.filePath or (opts.package or "./...")
		local cmd = { "go", "run", target }
		vim.list_extend(cmd, split_args(opts.PARAMETERS))
		return cmd
	end,
	PythonConfigurationType = function(opts)
		if not opts.SCRIPT_NAME then
			return nil
		end
		local cmd = { opts.SDK_HOME ~= "" and opts.SDK_HOME or "python", opts.SCRIPT_NAME }
		vim.list_extend(cmd, split_args(opts.PARAMETERS))
		return cmd
	end,
	ShConfigurationType = function(opts)
		if not opts.SCRIPT_PATH then
			return nil
		end
		local cmd = { opts.INTERPRETER_PATH ~= "" and opts.INTERPRETER_PATH or "bash", opts.SCRIPT_PATH }
		vim.list_extend(cmd, split_args(opts.SCRIPT_OPTIONS))
		return cmd
	end,
}
builders.JetRunConfigurationType = builders.Application
builders.KotlinRunConfigurationType = builders.Application

function M.parse(xml, root)
	local out = {}
	for block in xml:gmatch("<configuration.-</configuration>") do
		local head = block:match("<configuration[^>]*>") or ""
		local name = unescape(head:match('name="([^"]*)"') or "")
		local ctype = head:match('type="([^"]*)"')
		local build = ctype and builders[ctype]
		if build and name ~= "" then
			local opts, env = parse_opts(block, root)
			local cmd = build(opts, root)
			if cmd then
				out[#out + 1] = {
					name = name,
					cmd = cmd,
					env = next(env) and env or nil,
					cwd = opts.WORKING_DIRECTORY or opts.externalProjectPath or root,
				}
			end
		end
	end
	return out
end

function M.load(root)
	local out = {}
	for _, dir in ipairs({ root .. "/.run", root .. "/.idea/runConfigurations" }) do
		for _, file in ipairs(vim.fn.glob(dir .. "/*.xml", false, true)) do
			local ok, lines = pcall(vim.fn.readfile, file)
			if ok then
				vim.list_extend(out, M.parse(table.concat(lines, "\n"), root))
			end
		end
	end
	return out
end

return M
