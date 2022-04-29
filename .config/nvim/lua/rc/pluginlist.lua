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

  -- Specific language
  use { "mboughaba/i3config.vim", ft="i3config" }
  use { "alaviss/nim.nvim", ft="nim" }
  use { "iamcco/markdown-preview.nvim", ft="markdown", run=":call mkdp#util#install()" }

  -- Language Server Protocol
  use "neovim/nvim-lspconfig"
  use "williamboman/nvim-lsp-installer"
	use "tamago324/nlsp-settings.nvim"
  use "folke/lsp-colors.nvim"
  use "folke/trouble.nvim"
  use "j-hui/fidget.nvim"
  use "jose-elias-alvarez/null-ls.nvim"

  -- Treesitter
  use { "nvim-treesitter/nvim-treesitter", --[[ run=":TSUpdate" --]] }
  use "JoosepAlviste/nvim-ts-context-commentstring"
  use "yioneko/nvim-yati"
  use "haringsrob/nvim_context_vt"
  use "m-demare/hlargs.nvim"

  -- Paren
  use "andymass/vim-matchup"
  use "windwp/nvim-autopairs"
  use "windwp/nvim-ts-autotag"

  -- Completion
  use "hrsh7th/nvim-cmp"
  use "onsails/lspkind-nvim"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lsp-signature-help"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-nvim-lua"
  use "hrsh7th/cmp-emoji"
  use "f3fora/cmp-spell"
  use "yutkat/cmp-mocword"
  use "uga-rosa/cmp-dictionary"
  use "hrsh7th/cmp-cmdline"

  -- Telescope (Fuzzy finder)
  use "nvim-telescope/telescope.nvim"
  use "nvim-telescope/telescope-frecency.nvim"
  use "tamago324/telescope-sonictemplate.nvim"

  -- Cursor move
  use "phaazon/hop.nvim"
  use "osyo-manga/vim-milfeulle"

  -- Edit
  use "junegunn/vim-easy-align"
  use "machakann/vim-sandwich"
  --use "mopp/vim-operator-convert-case"
  use "AckslD/nvim-trevJ.lua"
  use "deris/vim-rengbang"

  -- Format
  use "ntpeters/vim-better-whitespace"
  use "gpanders/editorconfig.nvim"

  -- Comment
  use "numToStr/Comment.nvim"

  -- Search
  use "kevinhwang91/nvim-hlslens"
  use "haya14busa/vim-asterisk"

  -- Template
  use "mattn/vim-sonictemplate"

  -- UI Components (+helper)
  use "nvim-lualine/lualine.nvim"
  use "SmiteshP/nvim-gps"
  use "akinsho/bufferline.nvim"
  use "GustavoKatel/sidebar.nvim"
  use "petertriho/nvim-scrollbar"
  use "nvim-neo-tree/neo-tree.nvim"
  use "famiu/bufdelete.nvim"
  use "stevearc/stickybuf.nvim"

  -- Git
  use "TimUntersberger/neogit"
  use "lewis6991/gitsigns.nvim"

  -- Memo
  use "renerocksai/calendar-vim"
  use "renerocksai/telekasten.nvim"

  -- Colorscheme
  use "EdenEast/nightfox.nvim"

  -- Indent guide
  use "lukas-reineke/indent-blankline.nvim"

  -- Highlight
  use "norcalli/nvim-colorizer.lua"
  use "t9md/vim-quickhl"
  use "folke/todo-comments.nvim"
end)
