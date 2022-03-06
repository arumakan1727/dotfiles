local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.cmd 'packadd packer.nvim'

vim.cmd [[autocmd BufWritePost plugin_*.lua source <afile> | PackerCompile]]

vim.api.nvim_exec([[
function! IsPluginInstalled(name) abort
  return luaeval("_G.packer_plugins['" .. a:name .. "'] ~= nil")
endfunction
]], true)


return require('packer').startup(function(use)
  -- plugin manager for neovim
  use {'wbthomason/packer.nvim', opt = true}

  use {'tpope/vim-repeat'}

  use {
    'kyazdani42/nvim-web-devicons',
    config = function()
      require'nvim-web-devicons'.setup {
        override = {
          nim = {
            icon = '',
            color = '#f5d742',
            name = 'Nim'
          }
        }
      }
    end
  }

  --------------------------------
  -- specific language
  use {'mboughaba/i3config.vim', ft = 'i3config'}
  use { 'alaviss/nim.nvim', ft = 'nim' }

  -- Markdown
  use {'iamcco/markdown-preview.nvim', ft = {'markdown'}, run = ':call mkdp#util#install()'}
  use {
    'plasticboy/vim-markdown',
    ft = 'markdown',
    setup = function()
      vim.g.vim_markdown_math = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_strikethrough = 1
      vim.g.vim_markdown_folding_disabled = 1
    end,
  }

  -- CSV
  use {
    'mechatroner/rainbow_csv',
    ft = 'csv',
  }

  -----------------------------------------------
  -- colorscheme
  use {
    'EdenEast/nightfox.nvim',
    config = function()
      vim.cmd 'colorscheme duskfox'
      vim.cmd 'hi IndentBlanklineIndent1 guibg=#2f2b44 gui=nocombine'
      vim.cmd 'hi IndentBlanklineIndent2 guibg=#231d36 gui=nocombine'
    end
  }

  --------------------------------
  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    event = "VimEnter",
    run = ':TSUpdate',
    config = function() require 'rc/plugin_config/nvim-treesitter' end
  }

  --------------------------------
  -- LSP
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'folke/trouble.nvim',
      'ray-x/lsp_signature.nvim',
      -- {'jose-elias-alvarez/null-ls.nvim', requires = {'nvim-lua/plenary.nvim'}},
    },
    config = function() require'rc/plugin_config/nvim-lspconfig' end
  }


  --------------------------------
  -- brackets
  use {
    'andymass/vim-matchup',
    after = {'nvim-treesitter'},
    config = function()
      vim.g.loaded_matchit = 1
      vim.g.matchup_matchparen_offscreen = {method = 'popup'}
      vim.cmd("hi MatchParenCur cterm=underline gui=underline")
      vim.cmd("hi MatchWordCur cterm=underline gui=underline")
    end
  }
  use {
    'windwp/nvim-ts-autotag',
    after = {'nvim-treesitter'},
    config = function()
      require('nvim-ts-autotag').setup()
    end
  }

  --------------------------------
  -- Completion
  use {
  'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-vsnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'onsails/lspkind-nvim',
      'windwp/nvim-autopairs',
    },
    setup = function()
      vim.cmd 'source ~/.config/nvim/rc/plugin_setup/vsnip.vim'
    end,
    config = function()
      require'rc/plugin_config/nvim-cmp'
      vim.cmd 'source ~/.config/nvim/rc/plugin_config/nvim-cmp.vim'
    end
  }

  use {
    'mattn/vim-sonictemplate',
    setup = function()
      vim.api.nvim_set_keymap('n', '<F9>', ':<C-u>%d<CR>:Template main<CR>:LspRestart<CR>', {noremap = true, silent = false})
      vim.g.sonictemplate_vim_template_dir = {
        vim.fn.expand('~/.config/nvim/sonictemplate'),
        vim.fn.expand('~/kyopro/sonictemplate'),
      }
    end,
  }

  -- Neovim Lua
  use {'tjdevries/nlua.nvim', event = "VimEnter"}

  --------------------------------
  -- formatting
  use {
    'mhartington/formatter.nvim',
    config = function()
      local prettier = {
        function()
          return {
            exe = 'prettier',
            args = {'--stdin-filepath', vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), },
            stdin = true,
          }
        end
      }

      require'formatter'.setup {
        filetype = {
          html = prettier,
          javascript = prettier,
          typescript = prettier,
          vue = prettier,
        }
      }
      vim.api.nvim_set_keymap('n', ',f', '<cmd>Format<CR>', {noremap = true, silent = true})
    end,
  }

  --------------------------------
  -- emmet
  use {
    'mattn/emmet-vim',
    ft = {'html', 'htmldjango', 'css', 'markdown', 'vue'},
    setup = function()
    end
  }

  -----------------------------------------------
  -- edit
  use {
    'junegunn/vim-easy-align',
    config = function()
      vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', {})
      vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', {})
    end
  }
  use {'dhruvasagar/vim-table-mode', cmd = {'TableModeEnable'}}
  use {'machakann/vim-sandwich', event = "VimEnter"}
  use {
    'AndrewRadev/splitjoin.vim',
    event = 'VimEnter'
  }

  --------------------------------
  -- comment out
  use {
    'b3nj5m1n/kommentary',
    event = "VimEnter",
    config = function()
      require('kommentary.config').use_extended_mappings()
    end
  }

  -----------------------------------------------
  -- status line
  use {
    "SmiteshP/nvim-gps",
    after = "nvim-treesitter",
    config = function()
      require('nvim-gps').setup()
    end
  }
  use {
    'nvim-lualine/lualine.nvim',
    after = "nvim-gps",
    event = "VimEnter",
    config = function()
      local gps = require('nvim-gps')

      local function get_active_lsp_names()
        local fallback_msg = 'No Active LSP'
        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
        local clients = vim.lsp.get_active_clients()

        if next(clients) == nil then
          return fallback_msg
        end

        res = ''
        for _, client in ipairs(clients) do
          local filetypes = client.config.filetypes
          if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
            if res == '' then
              res = client.name
            else
              res = res .. ',' .. client.name
            end
          end
        end

        if res == '' then
          return fallback_msg
        else
          return res
        end
      end

      require'lualine'.setup {
        options = {
          theme = 'solarized_dark'
        },
        sections = {
          lualine_b = {
            {
              'filename',
              path = 1,  -- 0: Just the filename / 1: Relative path / 2: Absolute path
            }
          },
          lualine_c = {
            'branch',
            'diff',
            {
              'diagnostics',
              sources = {'nvim_lsp'},
              diagnostics_color = {
                error = {fg = '#ff3333'}
              }
            },
            {
              gps.get_location,
              cond = gps.is_available
            },
          },
          lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
            {
              'active_lsp_name',
              fmt = get_active_lsp_names,
              color = {fg = '#60c3c0'}
            },
          },
        },
      }
    end,
  }

  -----------------------------------------------
  -- file tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    setup = function()
      vim.api.nvim_set_keymap('n', '<M-t>', ':<C-u>NvimTreeToggle<CR>', {noremap = true, silent = true})
    end,
    config = function() require'nvim-tree'.setup() end
  }

  -----------------------------------------------
  -- cursor move
  use {
    'rhysd/clever-f.vim',
    event = "VimEnter",
    setup = function()
      vim.g.clever_f_ignore_case = 0
      vim.g.clever_f_across_no_line = 1
      vim.g.clever_f_fix_key_direction = 1
    end
  }

  -----------------------------------------------
  use {
    't9md/vim-quickhl',
    event = "VimEnter",
    config = function()
      vim.api.nvim_set_keymap('n', '<Space>h', '<Plug>(quickhl-manual-this)', {})
      vim.api.nvim_set_keymap('x', '<Space>h', '<Plug>(quickhl-manual-this)', {})
      vim.api.nvim_set_keymap('n', '<Space>H', '<Plug>(quickhl-manual-reset)', {})
      vim.api.nvim_set_keymap('x', '<Space>H', '<Plug>(quickhl-manual-reset)', {})
    end
  }

  -----------------------------------------------
  -- buffer tab & switching buffer
  use {
    'akinsho/bufferline.nvim',
    config = function() require 'rc/plugin_config/bufferline' end
  }

  ----------------------------------------------
  -- indent guide
  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('indent_blankline').setup {
        char = "",
        char_highlight_list = {
          "IndentBlanklineIndent1",
          "IndentBlanklineIndent2",
        },
        space_char_highlight_list = {
          "IndentBlanklineIndent1",
          "IndentBlanklineIndent2",
        },
        show_trailing_blankline_indent = false,
      }
    end
  }

  -----------------------------------------------
  -- mark
  use {
    'MattesGroeger/vim-bookmarks',
    event = "VimEnter",
    setup = function()
      vim.g.bookmark_no_default_key_mappings = 1
    end,
    config = function()
      vim.api.nvim_set_keymap('n', '<Space>mm', '<Plug>BookmarkToggle', {})
      vim.api.nvim_set_keymap('n', '<Space>mn', '<Plug>BookmarkNext', {})
      vim.api.nvim_set_keymap('n', '<Space>mp', '<Plug>BookmarkPrev', {})
      vim.api.nvim_set_keymap('n', '<Space>m0', '<Plug>BookmarkClear', {})
      vim.api.nvim_set_keymap('n', '<Space>ma', '<Plug>BookmarkShowAll', {})
    end
  }
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end
  }

  --------------------------------
  -- telescope (nvim-featured fuzzy finder)
  use {'nvim-lua/popup.nvim'}
  use {'nvim-lua/plenary.nvim'}
  use {'tamago324/telescope-sonictemplate.nvim'}
  use {
    'nvim-telescope/telescope.nvim',
    event = "VimEnter",
    after = {'popup.nvim', 'plenary.nvim'},
    config = function() require 'rc/plugin_config/telescope' end
  }

  use {
    'ntpeters/vim-better-whitespace',
    event = "VimEnter",
    setup = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.better_whitespace_operator = ''
      vim.g.strip_whitespace_on_save = 0
      vim.cmd("autocmd ColorScheme * hi ExtraWhitespace guibg=#401000 ctermbg=red")
    end,
  }

  --------------------------------
  -- git
  use {
    'lewis6991/gitsigns.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    event = "VimEnter",
    config = function()
      require('gitsigns').setup()
    end
  }

  --------------------------------
  -- DB client
  use {
    'kristijanhusak/vim-dadbod-ui',
    requires = { 'tpope/vim-dadbod' },
  }
end)
