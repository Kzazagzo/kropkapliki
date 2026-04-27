vim.opt.spelllang = { "en", "pl" }

-- │     SECURITY     │
vim.opt.modelines = 0
vim.opt.exrc = true
vim.opt.secure = true

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = false
vim.opt.shada = "!,'1000,<0,s10,h"
local undodir_path = vim.fn.expand("~/.local/share/nvim/undodir")
vim.opt.undodir = undodir_path
if vim.fn.isdirectory(undodir_path) == 0 then
	vim.fn.mkdir(undodir_path, "p")
end

vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")
vim.opt.selection = "inclusive"
vim.opt.clipboard:append("unnamedplus")
vim.opt.modifiable = true
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.opt.viewoptions:remove("curdir")

vim.opt.wildmode = "longest:list,full"
vim.opt.wildmenu = true
vim.opt.wildignorecase = true
vim.opt.wildignore:append(".git,.hg,.svn")
vim.opt.wildignore:append(".aux,*.out,*.toc")
vim.opt.wildignore:append(".o,*.obj,*.exe,*.dll,*.manifest,*.rbc,*.class")
vim.opt.wildignore:append(".ai,*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png,*.psd,*.webp")
vim.opt.wildignore:append(".avi,*.divx,*.mp4,*.webm,*.mov,*.m2ts,*.mkv,*.vob,*.mpg,*.mpeg")
vim.opt.wildignore:append(".mp3,*.oga,*.ogg,*.wav,*.flac")
vim.opt.wildignore:append(".eot,*.otf,*.ttf,*.woff")
vim.opt.wildignore:append(".doc,*.pdf,*.cbr,*.cbz")
vim.opt.wildignore:append(".zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz,*.kgb")
vim.opt.wildignore:append(".swp,.lock,.DS_Store,._*")
vim.opt.wildignore:append(".,..")

vim.opt.showmatch = true
vim.opt.shortmess:append("sI")
vim.opt.cmdheight = 0
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.termguicolors = true
vim.opt.synmaxcol = 512
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.listchars = { tab = "▏ ", trail = "·", extends = "»", precedes = "«", nbsp = "░" }
vim.opt.list = true
vim.opt.lazyredraw = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.smoothscroll = true
vim.opt.showcmd = false

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "0"

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.helpheight = 30
vim.opt.splitkeep = "screen"
vim.opt.inccommand = "nosplit"
vim.opt.jumpoptions = "stack"

vim.opt.fillchars = {
	horiz = "─",
	horizup = "⏊",
	horizdown = "┬",
	vert = "▒",
	vertleft = "┤",
	vertright = "├",
	verthoriz = "┼",
	diff = "╱",
	eob = " ",
	foldclose = "",
	foldopen = "",
	fold = " ",
	foldsep = " ",
	msgsep = "─",
}

vim.opt.guicursor = {
	"n-c:block-Cursor",
	"i-ci-ve:ver25-Cursor-blinkwait300-blinkon200-blinkoff150",
	"v-V:hor10-Cursor",
	"r-cr:hor20-Cursor",
	"o:block-Cursor-blinkwait300-blinkon200-blinkoff150",
}

vim.filetype.add({
	extension = {
		env = "sh",
		tf = "terraform",
		tfvars = "terraform",
		pipeline = "groovy",
		jenkinsfile = "groovy",
	},
	filename = {
		["Dockerfile"] = "dockerfile",
		[".env"] = "sh",
		["docker-compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
	},
	pattern = {
		["%.env%.[%w_.-]+"] = "sh",
		["Dockerfile.*"] = "dockerfile",
		["docker%-compose.*%.j2"] = "yaml.docker-compose.j2",
		["compose.*%.j2"] = "yaml.docker-compose.j2",
		["%.user%.css"] = "less",
		[".*%.conf"] = "nginx",
		[".*/tasks/.*%.ya?ml"] = "yaml.ansible",
		[".*/handlers/.*%.ya?ml"] = "yaml.ansible",
		[".*/defaults/.*%.ya?ml"] = "yaml.ansible",
		[".*/vars/.*%.ya?ml"] = "yaml.ansible",
		[".*/meta/.*%.ya?ml"] = "yaml.ansible",
		[".*playbook.*%.ya?ml"] = "yaml.ansible",
		[".*site%.ya?ml"] = "yaml.ansible",
	},
})

vim.diagnostic.config({
	virtual_text = {
		prefix = function(diagnostic)
			local icons = {
				[vim.diagnostic.severity.ERROR] = "󰅚",
				[vim.diagnostic.severity.WARN] = "󰀪",
				[vim.diagnostic.severity.INFO] = "󰋽",
				[vim.diagnostic.severity.HINT] = "󰌶",
			}
			return icons[diagnostic.severity] or "●"
		end,
		spacing = 4,
	},
	unresolved = true,
	virtual_lines = false,
	signs = true,
})
