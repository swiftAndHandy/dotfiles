vim.opt.termguicolors = true
vim.opt.title = true
vim.cmd.colorscheme("sorbet")

local function set_transparent()
	local groups = {
		"Normal", "NormalNC", "EndOfBuffer", "NormalFloat", "FloatBorder",
		"SignColumn", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill",
		"TabLineSel", 
	}
	for _, g in ipairs(groups) do
		vim.api.nvim_set_hl(0, g, { bg = "none" })
	end
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })
end

set_transparent()

-- ============================================================================
-- OPTIONS
-- ============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10

-- 4 spaces default, web filetypes get 2 via autocmd below
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.showmatch = true
vim.opt.cmdheight = 1
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.showmode = false
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.winblend = 0
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
vim.opt.synmaxcol = 300

local undodir = vim.fn.expand("~/.local/share/nvim/undodir") -- XDG-konform, nicht ~/.vim
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = undodir
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = false

vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.selection = "inclusive"
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.modifiable = true
vim.opt.encoding = "utf-8"

vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.diffopt:append("linematch:60")
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- ============================================================================
-- STATUSLINE
-- ============================================================================

local cached_branch = ""
local last_check = 0
local function git_branch()
	local now = vim.loop.now()
	if now - last_check > 5000 then
		cached_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
		last_check = now
	end
	if cached_branch ~= "" then
		return " \u{e725} " .. cached_branch .. " "
	end
	return ""
end

local function file_type()
	local ft = vim.bo.filetype
	local icons = {
		lua        = "\u{e620} ",
		javascript = "\u{e74e} ",
		typescript = "\u{e628} ",
		javascriptreact = "\u{e7ba} ",
		typescriptreact = "\u{e7ba} ",
		html       = "\u{e736} ",
		css        = "\u{e749} ",
		scss       = "\u{e749} ",
		json       = "\u{e60b} ",
		markdown   = "\u{e73e} ",
		vim        = "\u{e62b} ",
		sh         = "\u{f489} ",
		bash       = "\u{f489} ",
		zsh        = "\u{f489} ",
		rust       = "\u{e7a8} ",
		c          = "\u{e61e} ",
		cpp        = "\u{e61d} ",
		swift      = "\u{e755} ",
		python     = "\u{e73c} ",
		vue        = "\u{fd42} ",
		svelte     = "\u{e697} ",
	}
	if ft == "" then return " \u{f15b} " end
	return ((icons[ft] or " \u{f15b} ") .. ft)
end

local function file_size()
	local size = vim.fn.getfsize(vim.fn.expand("%"))
	if size < 0 then return "" end
	local size_str
	if size < 1024 then
		size_str = size .. "B"
	elseif size < 1024 * 1024 then
		size_str = string.format("%.1fK", size / 1024)
	else
		size_str = string.format("%.1fM", size / 1024 / 1024)
	end
	return " \u{f016} " .. size_str .. " "
end

local function mode_icon()
	local mode = vim.fn.mode()
	local modes = {
		n  = " \u{f121}  NORMAL",
		i  = " \u{f11c}  INSERT",
		v  = " \u{f0168} VISUAL",
		V  = " \u{f0168} V-LINE",
		["\22"] = " \u{f0168} V-BLOCK",
		c  = " \u{f120} COMMAND",
		R  = " \u{f044} REPLACE",
		r  = " \u{f044} REPLACE",
		t  = " \u{f120} TERMINAL",
	}
	return modes[mode] or (" \u{f059} " .. mode)
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch
_G.file_type = file_type
_G.file_size = file_size

local function setup_dynamic_statusline()
	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		callback = function()
			vim.opt_local.statusline = table.concat({
				"  ",
				"%#StatusLineBold#",
				"%{v:lua.mode_icon()}",
				"%#StatusLine#",
				" \u{e0b1} %f %h%m%r",
				"%{v:lua.git_branch()}",
				"\u{e0b1} ",
				"%{v:lua.file_type()}",
				"\u{e0b1} ",
				"%{v:lua.file_size()}",
				"%=",
				" \u{f017} %l:%c  %P ",
			})
		end,
	})
	vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		callback = function()
			vim.opt_local.statusline = "  %f %h%m%r \u{e0b1} %{v:lua.file_type()} %=  %l:%c   %P "
		end,
	})
end

setup_dynamic_statusline()

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "


vim.keymap.set("i", "<A-BS>", "<C-w>", { desc = "Delete word backward" })

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- 2 spaces for web filetypes, 4 everywhere else (set globally above)
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "css", "scss", "vue", "svelte", "lua", "json" },
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
    vim.opt_local.colorcolumn = "100"
	end,
})

-- Format on save (only when efm is attached)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	pattern = {
		"*.lua", "*.js", "*.jsx", "*.ts", "*.tsx",
		"*.json", "*.css", "*.scss", "*.html",
		"*.sh", "*.bash", "*.zsh", "*.c", "*.cpp", "*.h", "*.hpp", "*.swift",
		"*.py",
	},
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then return end
		if not vim.bo[args.buf].modifiable then return end
		if vim.api.nvim_buf_get_name(args.buf) == "" then return end

		local has_efm = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			if c.name == "efm" then has_efm = true; break end
		end
		if not has_efm then return end

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c) return c.name == "efm" end,
		})
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then return end
		local last_pos = vim.api.nvim_buf_get_mark(0, '"')
		local last_line = vim.api.nvim_buf_line_count(0)
		local row = last_pos[1]
		if row < 1 or row > last_line then return end
		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================
vim.pack.add({
	"https://www.github.com/lewis6991/gitsigns.nvim",
	"https://www.github.com/echasnovski/mini.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	{
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/L3MON4D3/LuaSnip",
})

local function packadd(name) vim.cmd("packadd " .. name) end
packadd("nvim-treesitter")
packadd("gitsigns.nvim")
packadd("mini.nvim")
packadd("fzf-lua")
packadd("nvim-tree.lua")
packadd("nvim-lspconfig")
packadd("mason.nvim")
packadd("efmls-configs-nvim")
packadd("blink.cmp")
packadd("LuaSnip")

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})
	local ensure_installed = {
		"vim", "vimdoc",
		"c", "cpp",
		"swift",        -- sourcekit-lsp via Xcode CLT
		"lua",
		"html", "css",
		"javascript", "typescript",
		"vue",          -- falls du reinschnupperst
		"svelte",       -- dto.
		"python",
		"json",
		"markdown",
		"bash",
	}

	local config = require("nvim-treesitter.config")
	local already_installed = config.get_installed()
	local parsers_to_install = {}
	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end
	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()

require("nvim-tree").setup({
	view = { width = 35 },
	filters = { dotfiles = false },
	renderer = { group_empty = true },
})
vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

require("fzf-lua").setup({})

vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").files() end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function() require("fzf-lua").live_grep() end, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function() require("fzf-lua").help_tags() end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function() require("fzf-lua").diagnostics_document() end, { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function() require("fzf-lua").diagnostics_workspace() end, { desc = "FZF Diagnostics Workspace" })

require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})

require("gitsigns").setup({
	signs = {
		add          = { text = "\u{2590}" },
		change       = { text = "\u{2590}" },
		delete       = { text = "\u{2590}" },
		topdelete    = { text = "\u{25e6}" },
		changedelete = { text = "\u{25cf}" },
		untracked    = { text = "\u{25cb}" },
	},
	signcolumn = true,
	current_line_blame = false,
})

vim.keymap.set("n", "]h", function() require("gitsigns").next_hunk() end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function() require("gitsigns").prev_hunk() end, { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>hs", function() require("gitsigns").stage_hunk() end, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", function() require("gitsigns").reset_hunk() end, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, { desc = "Blame line" })
vim.keymap.set("n", "<leader>hB", function() require("gitsigns").toggle_current_line_blame() end, { desc = "Toggle inline blame" })
vim.keymap.set("n", "<leader>hd", function() require("gitsigns").diffthis() end, { desc = "Diff this" })

require("mason").setup({})

-- ============================================================================
-- LSP, Linting, Formatting & Completion
-- ============================================================================
local diagnostic_signs = { Error = " ", Warn = " ", Hint = "", Info = "" }

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN]  = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO]  = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT]  = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded", source = "always",
		header = "", prefix = "", focusable = false, style = "minimal",
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then return end
	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "<leader>gd", function()
		require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
	end, opts)
	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit"); vim.lsp.buf.definition()
	end, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>D", function() vim.diagnostic.open_float({ scope = "line" }) end, opts)
	vim.keymap.set("n", "<leader>d", function() vim.diagnostic.open_float({ scope = "cursor" }) end, opts)
	vim.keymap.set("n", "<leader>nd", function() vim.diagnostic.jump({ count = 1 }) end, opts)
	vim.keymap.set("n", "<leader>pd", function() vim.diagnostic.jump({ count = -1 }) end, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>fr", function() require("fzf-lua").lsp_references() end, opts)
	vim.keymap.set("n", "<leader>ft", function() require("fzf-lua").lsp_typedefs() end, opts)
	vim.keymap.set("n", "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end, opts)
	vim.keymap.set("n", "<leader>fw", function() require("fzf-lua").lsp_workspace_symbols() end, opts)
	vim.keymap.set("n", "<leader>fi", function() require("fzf-lua").lsp_implementations() end, opts)

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true, bufnr = bufnr,
			})
			vim.defer_fn(function() vim.lsp.buf.format({ bufnr = bufnr }) end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"]      = { "accept", "fallback" },
		["<C-j>"]     = { "select_next", "fallback" },
		["<C-k>"]     = { "select_prev", "fallback" },
		["<Tab>"]     = { "snippet_forward", "fallback" },
		["<S-Tab>"]   = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = { menu = { auto_show = true } },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	snippets = {
		expand = function(snippet) require("luasnip").lsp_expand(snippet) end,
	},
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})
vim.lsp.config("bashls", {})
vim.lsp.config("ts_ls", {})    -- TypeScript/JavaScript/Angular (via tsconfig)
vim.lsp.config("clangd", {})   -- C/C++, bereits via Xcode CLT
vim.lsp.config("sourcekit", {}) -- Swift, bereits via Xcode CLT
vim.lsp.config("pyright", {})  -- Python/Django

do
	local stylua   = require("efmls-configs.formatters.stylua")
	local luacheck  = require("efmls-configs.linters.luacheck")

	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local eslint_d   = require("efmls-configs.linters.eslint_d")

	local fixjson  = require("efmls-configs.formatters.fixjson")

	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt      = require("efmls-configs.formatters.shfmt")

	local cpplint  = require("efmls-configs.linters.cpplint")
	local clangfmt = require("efmls-configs.formatters.clang_format")

	local flake8 = require("efmls-configs.linters.flake8")
	local black  = require("efmls-configs.formatters.black")

	-- go (gofumpt/go_revive) entfernt

	vim.lsp.config("efm", {
		filetypes = {
			"c", "cpp",
			"css", "scss",
			"html",
			"javascript", "javascriptreact",
			"typescript", "typescriptreact",
			"json", "jsonc",
			"lua",
			"markdown",
			"python",
			"sh",
			"vue", "svelte",
		},
		init_options = { documentFormatting = true },
		settings = {
			languages = {
				c           = { clangfmt, cpplint },
				cpp         = { clangfmt, cpplint },
				css         = { prettier_d },
				scss        = { prettier_d },
				html        = { prettier_d },
				javascript  = { eslint_d, prettier_d },
				javascriptreact = { eslint_d, prettier_d },
				json        = { eslint_d, fixjson },
				jsonc       = { eslint_d, fixjson },
				lua         = { luacheck, stylua },
				markdown    = { prettier_d },
				python      = { flake8, black },
				sh          = { shellcheck, shfmt },
				typescript  = { eslint_d, prettier_d },
				typescriptreact = { eslint_d, prettier_d },
				vue         = { eslint_d, prettier_d },
				svelte      = { eslint_d, prettier_d },
			},
		},
	})
end

vim.lsp.enable({
	"lua_ls",
	"bashls",
	"ts_ls",
	"clangd",
	"sourcekit",
	"pyright",
	"efm",
})

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================
vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

local terminal_state = { buf = nil, win = nil, is_open = false }

local function FloatingTerminal()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
		return
	end

	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		terminal_state.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[terminal_state.buf].bufhidden = "hide"
	end

	local width  = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row    = math.floor((vim.o.lines - height) / 2)
	local col    = math.floor((vim.o.columns - width) / 2)

	terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
		relative = "editor",
		width = width, height = height, row = row, col = col,
		style = "minimal", border = "rounded",
	})

	vim.wo[terminal_state.win].winblend = 0
	vim.wo[terminal_state.win].winhighlight = "Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder"
	vim.api.nvim_set_hl(0, "FloatingTermNormal", { bg = "none" })
	vim.api.nvim_set_hl(0, "FloatingTermBorder", { bg = "none" })

	local has_terminal = false
	local lines = vim.api.nvim_buf_get_lines(terminal_state.buf, 0, -1, false)
	for _, line in ipairs(lines) do
		if line ~= "" then has_terminal = true; break end
	end
	if not has_terminal then
		vim.fn.termopen(os.getenv("SHELL"))
	end

	terminal_state.is_open = true
	vim.cmd("startinsert")

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = terminal_state.buf,
		callback = function()
			if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
				vim.api.nvim_win_close(terminal_state.win, false)
				terminal_state.is_open = false
			end
		end,
		once = true,
	})
end

vim.keymap.set("n", "<leader>t", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc>", function()
	if terminal_state.is_open and terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.is_open = false
	end
end, { noremap = true, silent = true, desc = "Close floating terminal" })

-- ============================================================================
-- COLOR-ADJUSTMENTS
-- ============================================================================

vim.api.nvim_set_hl(0, "@markup.raw.block.markdown", { fg = "#ff9e64", bold = true })
