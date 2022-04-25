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
  local function opt_use(x)
    use { x, opt=true }
  end

  -- Package manager
  use { "tani/vim-jetpack", opt=1 }

  -- Library
  use "tpope/vim-repeat"
  use "nvim-lua/plenary.nvim"
  use "nvim-lua/popup.nvim"
  use "MunifTanjim/nui.nvim"
  use "tami5/sqlite.lua"
  use "kyazdani42/nvim-web-devicons"

  -- Specific language
  use { "mboughaba/i3config.vim", ft="i3config" }
  use { "alaviss/nim.nvim", ft="nim" }
  use { "iamcco/markdown-preview.nvim", ft="markdown", run=":call mkdp#util#install()" }

  -- Language Server Protocol
  opt_use "neovim/nvim-lspconfig"
  opt_use "folke/lsp-colors.nvim"
  opt_use "folke/trouble.nvim"
  opt_use "j-hui/fidget.nvim"
	opt_use "jose-elias-alvarez/null-ls.nvim"

  -- Treesitter
  use { "nvim-treesitter/nvim-treesitter", opt=true, run=":TSUpdate" }
  opt_use "JoosepAlviste/nvim-ts-context-commentstring"
  opt_use "yioneko/nvim-yati"
  opt_use "haringsrob/nvim_context_vt"
  opt_use "m-demare/hlargs.nvim"

  -- Paren
  opt_use "andymass/vim-matchup"
  opt_use "windwp/nvim-autopairs"
  opt_use "windwp/nvim-ts-autotag"

  -- Completion
  opt_use "hrsh7th/nvim-cmp"
  opt_use "onsails/lspkind-nvim"
  opt_use "hrsh7th/cmp-nvim-lsp"
  opt_use "hrsh7th/cmp-nvim-lsp-signature-help"
  opt_use "hrsh7th/cmp-buffer"
  opt_use "hrsh7th/cmp-path"
  opt_use "hrsh7th/cmp-nvim-lua"
  opt_use "hrsh7th/cmp-emoji"
  opt_use "f3fora/cmp-spell"
  opt_use "yutkat/cmp-mocword"
  opt_use "uga-rosa/cmp-dictionary"
  opt_use "hrsh7th/cmp-cmdline"

  -- Telescope (Fuzzy finder)
  opt_use "nvim-telescope/telescope.nvim"
  opt_use "nvim-telescope/telescope-frecency.nvim"
  opt_use "tamago324/telescope-sonictemplate.nvim"

  -- Cursor move
  opt_use "phaazon/hop.nvim"
  opt_use "osyo-manga/vim-milfeulle"

  -- Edit
  opt_use "junegunn/vim-easy-align"
  opt_use "machakann/vim-sandwich"
  opt_use "mopp/vim-operator-convert-case"
  opt_use "AckslD/nvim-trevJ.lua"
  opt_use "deris/vim-rengbang"

  -- Format
  opt_use "ntpeters/vim-better-whitespace"
	opt_use "gpanders/editorconfig.nvim"

  -- Comment
  opt_use "numToStr/Comment.nvim"

  -- Search
	opt_use "kevinhwang91/nvim-hlslens"
	opt_use "haya14busa/vim-asterisk"

  -- Template
  opt_use "mattn/vim-sonictemplate"

  -- UI Components (+helper)
  opt_use "nvim-lualine/lualine.nvim"
  opt_use "SmiteshP/nvim-gps"
  opt_use "akinsho/bufferline.nvim"
  opt_use "GustavoKatel/sidebar.nvim"
  opt_use "petertriho/nvim-scrollbar"
  opt_use "nvim-neo-tree/neo-tree.nvim"
  opt_use "famiu/bufdelete.nvim"
  opt_use "stevearc/stickybuf.nvim"

  -- Git
  opt_use "TimUntersberger/neogit"
  opt_use "lewis6991/gitsigns.nvim"

  -- Memo
  opt_use "renerocksai/calendar-vim"
  opt_use "renerocksai/telekasten.nvim"

  -- Colorscheme
  opt_use "EdenEast/nightfox.nvim"

  -- Indent guide
  opt_use "lukas-reineke/indent-blankline.nvim"

  -- Highlight
  opt_use "norcalli/nvim-colorizer.lua"
  opt_use "t9md/vim-quickhl"
  opt_use "folke/todo-comments.nvim"
end)
