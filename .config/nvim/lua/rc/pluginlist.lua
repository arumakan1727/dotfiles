local jetpack_root = vim.fn.stdpath('data') .. '/site/pack/jetpack'

vim.g["jetpack_copy_method"] = "symlink"

if vim.fn.empty(vim.fn.glob(jetpack_root)) == 1 then
  vim.cmd("!curl -fLo " .. jetpack_root .. "/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim")

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.cmd("packadd vim-jetpack")
      vim.cmd("JetpackSync")
    end
  })
end


vim.cmd("packadd vim-jetpack")

require"jetpack.packer".add {
	-- Package manager
	{ "tani/vim-jetpack", opt=1 },

	-- Library
	"tpope/vim-repeat",
	"nvim-lua/plenary.nvim",
	--"rcarriga/nvim-notify",
	"nvim-lua/popup.nvim",
	"MunifTanjim/nui.nvim",
	"tami5/sqlite.lua",
	"kyazdani42/nvim-web-devicons",

	-- Project-local setting
	"gpanders/editorconfig.nvim",
	"klen/nvim-config-local",

	-- Specific language
	{ "mboughaba/i3config.vim", ft="i3config" },
	{ "alaviss/nim.nvim" },
	{ "iamcco/markdown-preview.nvim", ft="markdown", run=":call mkdp#util#install()" },
	{ "preservim/vim-markdown", ft="markdown" },
	{ "qnighy/satysfi.vim" },
	{ "mechatroner/rainbow_csv", ft={"csv", "tsv"} },
	{ "kchmck/vim-coffee-script" },


	-- Language Server Protocol
	"neovim/nvim-lspconfig",
	"williamboman/nvim-lsp-installer",
	"tamago324/nlsp-settings.nvim",
	"jose-elias-alvarez/null-ls.nvim",
	"folke/lsp-colors.nvim",
	"j-hui/fidget.nvim",
	{ "folke/trouble.nvim", opt=1 },

	-- Treesitter
	{ "nvim-treesitter/nvim-treesitter", run=":TSUpdate" },
	"JoosepAlviste/nvim-ts-context-commentstring",
	"yioneko/nvim-yati",
	"m-demare/hlargs.nvim",
	-- "haringsrob/nvim_context_vt",
	"windwp/nvim-ts-autotag",
	"nvim-treesitter/nvim-treesitter-textobjects",
	"David-Kunz/treesitter-unit",

	-- Editing utility
	"junegunn/vim-easy-align",
	"machakann/vim-sandwich",
	"AckslD/nvim-trevJ.lua",
	"numToStr/Comment.nvim",
	"andymass/vim-matchup",
	"t9md/vim-quickhl",

	-- Cursor move, Search
	"phaazon/hop.nvim",
	"osyo-manga/vim-milfeulle",
	"kevinhwang91/nvim-hlslens",
	"haya14busa/vim-asterisk",

	-- Completion
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/cmp-emoji",
	"hrsh7th/cmp-nvim-lsp-signature-help",
	"hrsh7th/cmp-nvim-lua",
	"hrsh7th/cmp-path",
	"onsails/lspkind-nvim",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"windwp/nvim-autopairs",

	-- Telescope (Fuzzy finder)
	"nvim-telescope/telescope.nvim",
	"tamago324/telescope-sonictemplate.nvim",

	-- Template
	"mattn/vim-sonictemplate",

	-- Statusline
	"nvim-lualine/lualine.nvim",
	"SmiteshP/nvim-gps",

	-- Buffer, Window
	"akinsho/bufferline.nvim",
	"famiu/bufdelete.nvim",

	-- Directory tree
	"nvim-neo-tree/neo-tree.nvim",

	-- Git
	"lewis6991/gitsigns.nvim",
	"TimUntersberger/neogit",

	-- Colorscheme, Highlight
	"EdenEast/nightfox.nvim",
	"lukas-reineke/indent-blankline.nvim",
	"ntpeters/vim-better-whitespace",
	"norcalli/nvim-colorizer.lua",
	"folke/todo-comments.nvim",
}
