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
  use {'zah/nim.vim', ft = 'nim'}
  use {'yasuhiroki/github-actions-yaml.vim', ft='yaml'}
  use {'vim-crystal/vim-crystal', ft = 'crystal'}
  use {'udalov/kotlin-vim', ft = 'kotlin'}
  use {'kylef/apiblueprint.vim', ft = 'apiblueprint'}
  use {'aklt/plantuml-syntax', ft = 'plantuml'}
  use {'kevinoid/vim-jsonc', ft = 'jsonc'}
  use {'pangloss/vim-javascript', ft = 'javascript'}
  use {'hail2u/vim-css3-syntax', ft = {'html', 'css', 'markdown'}}

  -- Markdown
  use {'iamcco/markdown-preview.nvim', ft = {'markdown'}, run = ':call mkdp#util#install()'}
  use {
    'SidOfc/mkdx',
    ft = {'markdown'},
    setup = function()
      vim.api.nvim_set_var('mkdx#settings', {
        map = {enable = 0, prefix = '<localleader>'},
        highlight = {enable = 1},
        enter = {shift = 0},
        links = {external = {enable =  1}},
        toc = {text = 'Table of Contents', update_on_write = 1},
      })
    end
  }

  -----------------------------------------------
  -- colorscheme
  use {'joshdick/onedark.vim', opt = true}
  use {'kaicataldo/material.vim', opt = true}
  use {'morhetz/gruvbox', opt = true}
  use {'w0ng/vim-hybrid', opt = true}
  use {'sainnhe/sonokai', opt = true}
  use {'tomasr/molokai', opt = true}
  use {'jacoborus/tender.vim', opt = true}
  use {'arcticicestudio/nord-vim', opt = true}
  use {'cocopon/iceberg.vim', config = function() vim.cmd 'colorscheme iceberg' end }
  use {'Shatur/neovim-ayu',
    config = function()
      vim.g.ayu_mirage = true
    end,
    opt = true
  }

  -- get syntax info under cursor
  use {'wadackel/nvim-syntax-info', cmd = {'SyntaxInfo'}}

  -- color code
  use {'gko/vim-coloresque', on = 'VimEnter'}

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
  use {'glepnir/lspsaga.nvim'}
  use {'folke/trouble.nvim'}
  use {'ray-x/lsp_signature.nvim'}
  --[[ use {
    'jose-elias-alvarez/null-ls.nvim',
    requires = {'nvim-lua/plenary.nvim'},
  } ]]
  use {
    'neovim/nvim-lspconfig',
    requires = 'hrsh7th/cmp-nvim-lsp',
    config = function() require'rc/plugin_config/nvim-lspconfig' end
  }

  --------------------------------
  -- Completion
  use {
  'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'onsails/lspkind-nvim',
    },
    config = function()
      require'rc/plugin_config/nvim-cmp'
      vim.cmd 'source ~/.config/nvim/rc/plugin_config/nvim-cmp.vim'
    end
  }

  -- Neovim Lua
  use {'tjdevries/nlua.nvim', event = "VimEnter"}

  --------------------------------
  -- brackets
  use {
    'andymass/vim-matchup',
    config = function()
      vim.g.loaded_matchit = 1
      vim.g.matchup_matchparen_offscreen = {method = 'popup'}
      vim.cmd("hi MatchParenCur cterm=underline gui=underline")
      vim.cmd("hi MatchWordCur cterm=underline gui=underline")
    end
  }
  use {
    'windwp/nvim-autopairs',
    event = "VimEnter",
    after = 'nvim-cmp',
    config = function() require 'rc/plugin_config/nvim-autopairs' end
  }
  use {
    'windwp/nvim-ts-autotag',
    after = {'nvim-treesitter'},
    config = function()
      require('nvim-ts-autotag').setup()
    end
  }

  --------------------------------
  -- emmet
  use {
    'mattn/emmet-vim',
    ft = {'html', 'css', 'markdown'},
    setup = function()
    end
  }

  -----------------------------------------------
  -- edit
  use {
    'junegunn/vim-easy-align',
    -- event = "VimEnter",
    cmd = {'EasyAlign'},
    config = function()
      vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)')
      vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)')
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
  -- statusline
  use {
    'glepnir/galaxyline.nvim',
    branch = 'main',
    config = function() require 'rc/plugin_config/galaxyline' end
  }

  -----------------------------------------------
  -- file tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    setup = function()
      vim.api.nvim_set_keymap('n', '<M-t>', ':<C-u>NvimTreeToggle<CR>', {noremap = true, silent = true})
    end
  }

  -----------------------------------------------
  -- cursor move
  use {
    'phaazon/hop.nvim',
    as = 'hop',
    event = "VimEnter",
    config = function()
      require'hop'.setup {}
      vim.api.nvim_set_keymap('n', 'SS', "<cmd>lua require'hop'.hint_words()<CR>", {})
      vim.api.nvim_set_keymap('x', 'SS', "<cmd>lua require'hop'.hint_words()<CR>", {})
    end
  }
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
  -- find
  use {
    'kevinhwang91/nvim-hlslens',
    event = "VimEnter",
    config = function() vim.cmd('source ~/.config/nvim/rc/plugin_config/nvim-hlslens.vim') end
  }
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

  -----------------------------------------------
  -- spell check, grammar check
  if vim.fn.executable('java') == 1 then
    use {'rhysd/vim-grammarous', cmd = {'GrammarousCheck'}}
  end

  --------------------------------
  -- screenshot
  use {'segeljakt/vim-silicon', cmd = {'Silicon'}}

  --------------------------------
  -- telescope (nvim-featured fuzzy finder)
  use {'nvim-lua/popup.nvim'}
  use {'nvim-lua/plenary.nvim'}
  use {
    'nvim-telescope/telescope.nvim',
    event = "VimEnter",
    after = {'popup.nvim', 'plenary.nvim'},
    config = function() require 'rc/plugin_config/telescope' end
  }

  use {
    'Yggdroot/indentLine',
    setup = function()
      vim.g.indentLine_enabled = 1
      vim.g.indentLine_setConceal = 0
      vim.g.indentLine_char = '┆'
    end
  }

  use {
    'ntpeters/vim-better-whitespace',
    event = "VimEnter",
    setup = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.better_whitespace_operator = ''
      vim.g.strip_whitespace_on_save = 0
    end,
    config = function()
      vim.cmd("hi ExtraWhitespace guibg=#401000 ctermbg=red")
    end
  }

  --------------------------------
  -- project
  use {
    'airblade/vim-rooter',
    event = "VimEnter",
    setup = function()
      vim.g.rooter_cd_cmd = 'lcd'
      vim.g.rooter_manual_only = 1
      vim.g.rooter_patterns = {
        'tags', '.git', '.git/', '_darcs/', '.hg/',
        '.bzr/', 'Makefile', 'GNUMakefile', 'GNUmakefile', '.svn/'
      }
    end
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
end)
