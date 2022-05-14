local jetpack_root = vim.fn.stdpath('data') .. '/site/pack/jetpack'

if vim.fn.empty(vim.fn.glob(jetpack_root)) == 1 then
  local gitclone_cmd = "git clone --depth 1 https://github.com/tani/vim-jetpack  " .. jetpack_root .. "/src/vim-jetpack"
  local mkdir_cmd = "mkdir -p " .. jetpack_root .. "/opt"
  local symlink_cmd = "ln -snf " .. jetpack_root .. "/{src,opt}/vim-jetpack"
  vim.cmd("!" .. gitclone_cmd .. " && " .. mkdir_cmd .. " && " .. symlink_cmd)

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.cmd("packadd vim-jetpack")
      vim.cmd("JetpackSync")
    end
  })
end

vim.g["jetpack#optimization"] = 1
vim.g["jetpack#copy_method"] = "symlink"

vim.cmd("packadd vim-jetpack")

require"jetpack".startup(function(use)
	local function opt_use(name)
		use {name, opt=1}
	end

	-- Package manager
	use { "tani/vim-jetpack", opt=1 }

	-- Library
	use "tpope/vim-repeat"
	use "nvim-lua/plenary.nvim"
	use "rcarriga/nvim-notify"
	use "nvim-lua/popup.nvim"
	use "MunifTanjim/nui.nvim"
	use "tami5/sqlite.lua"
	use "kyazdani42/nvim-web-devicons"

	-- Project-local setting
	use "gpanders/editorconfig.nvim"
	use "klen/nvim-config-local"

	-- Specific language
	use { "mboughaba/i3config.vim", ft="i3config" }
	use { "alaviss/nim.nvim", ft="nim" }
	use { "iamcco/markdown-preview.nvim", ft="markdown", run=":call mkdp#util#install()" }
	use { "preservim/vim-markdown", ft="markdown" }
	use { "qnighy/satysfi.vim" }

	-- Language Server Protocol
	use "neovim/nvim-lspconfig"
	use "williamboman/nvim-lsp-installer"
	use "tamago324/nlsp-settings.nvim"
	use "tami5/lspsaga.nvim"
	use "jose-elias-alvarez/null-ls.nvim"
	use "folke/lsp-colors.nvim"
	use "j-hui/fidget.nvim"
	opt_use "folke/trouble.nvim"

	-- Treesitter
	use { "nvim-treesitter/nvim-treesitter", run=":TSUpdate" }
	use "JoosepAlviste/nvim-ts-context-commentstring"
	use "yioneko/nvim-yati"
	use "m-demare/hlargs.nvim"
	-- use "haringsrob/nvim_context_vt"
	use "windwp/nvim-ts-autotag"
	use "nvim-treesitter/nvim-treesitter-textobjects"
	use "David-Kunz/treesitter-unit"

	-- Editing utility
	use "junegunn/vim-easy-align"
	use "machakann/vim-sandwich"
	use "AckslD/nvim-trevJ.lua"
	use "deris/vim-rengbang"
	use "numToStr/Comment.nvim"
	use "andymass/vim-matchup"
	use "t9md/vim-quickhl"

	-- Cursor move, Search
	use "phaazon/hop.nvim"
	use "osyo-manga/vim-milfeulle"
	use "kevinhwang91/nvim-hlslens"
	use "haya14busa/vim-asterisk"
	use "edluffy/specs.nvim"

	-- Completion
	use "hrsh7th/cmp-nvim-lsp"
	use "hrsh7th/nvim-cmp"
	use "hrsh7th/cmp-buffer"
	use "hrsh7th/cmp-cmdline"
	use "hrsh7th/cmp-emoji"
	use "hrsh7th/cmp-nvim-lsp-signature-help"
	use "hrsh7th/cmp-nvim-lua"
	use "hrsh7th/cmp-path"
	use "onsails/lspkind-nvim"
	use "L3MON4D3/LuaSnip"
	use "saadparwaiz1/cmp_luasnip"
	use "windwp/nvim-autopairs"

	-- Telescope (Fuzzy finder)
	use "nvim-telescope/telescope.nvim"
	use "tamago324/telescope-sonictemplate.nvim"

	-- Template
	opt_use "mattn/vim-sonictemplate"

	-- Statusline
	use "nvim-lualine/lualine.nvim"
	use "SmiteshP/nvim-gps"

	-- Buffer, Window
	use "akinsho/bufferline.nvim"
	use "famiu/bufdelete.nvim"

	-- Directory tree
	use "nvim-neo-tree/neo-tree.nvim"

	-- Git
	use "lewis6991/gitsigns.nvim"
	use "TimUntersberger/neogit"

	-- Memo
	use "renerocksai/calendar-vim"
	use "renerocksai/telekasten.nvim"

	-- Colorscheme, Highlight
	use "EdenEast/nightfox.nvim"
	use "lukas-reineke/indent-blankline.nvim"
	use "ntpeters/vim-better-whitespace"
	use "norcalli/nvim-colorizer.lua"
	use "folke/todo-comments.nvim"
end)
