-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/armkn/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/armkn/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/armkn/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/armkn/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/armkn/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["apiblueprint.vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/apiblueprint.vim"
  },
  ["bufferline.nvim"] = {
    config = { "\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 rc/plugin_config/bufferline\frequire\0" },
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/bufferline.nvim"
  },
  ["clever-f.vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/clever-f.vim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/cmp-buffer"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp"
  },
  ["cmp-nvim-lua"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/cmp-nvim-lua"
  },
  ["cmp-path"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/cmp-path"
  },
  ["emmet-vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/emmet-vim"
  },
  ["galaxyline.nvim"] = {
    config = { "\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 rc/plugin_config/galaxyline\frequire\0" },
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/galaxyline.nvim"
  },
  ["github-actions-yaml.vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/github-actions-yaml.vim"
  },
  ["gitsigns.nvim"] = {
    config = { "\27LJ\2\n6\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\rgitsigns\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/gitsigns.nvim"
  },
  gruvbox = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/gruvbox"
  },
  hop = {
    config = { "\27LJ\2\nª\1\0\0\6\0\n\0\0236\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\0016\0\3\0009\0\4\0009\0\5\0'\2\6\0'\3\a\0'\4\b\0004\5\0\0B\0\5\0016\0\3\0009\0\4\0009\0\5\0'\2\t\0'\3\a\0'\4\b\0004\5\0\0B\0\5\1K\0\1\0\6x+<cmd>lua require'hop'.hint_words()<CR>\aSS\6n\20nvim_set_keymap\bapi\bvim\nsetup\bhop\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/hop"
  },
  ["i3config.vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/i3config.vim"
  },
  ["iceberg.vim"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\24colorscheme iceberg\bcmd\bvim\0" },
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/iceberg.vim"
  },
  indentLine = {
    after_files = { "/home/armkn/.local/share/nvim/site/pack/packer/opt/indentLine/after/plugin/indentLine.vim" },
    loaded = true,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/indentLine"
  },
  kommentary = {
    config = { "\27LJ\2\nO\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\26use_extended_mappings\22kommentary.config\frequire\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/kommentary"
  },
  ["kotlin-vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/kotlin-vim"
  },
  ["lsp_signature.nvim"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/lsp_signature.nvim"
  },
  ["lspkind-nvim"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/lspkind-nvim"
  },
  ["lspsaga.nvim"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/lspsaga.nvim"
  },
  ["markdown-preview.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/markdown-preview.nvim"
  },
  ["material.vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/material.vim"
  },
  mkdx = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/mkdx"
  },
  molokai = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/molokai"
  },
  ["neovim-ayu"] = {
    config = { "\27LJ\2\n,\0\0\2\0\3\0\0056\0\0\0009\0\1\0+\1\2\0=\1\2\0K\0\1\0\15ayu_mirage\6g\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/neovim-ayu"
  },
  ["nim.vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nim.vim"
  },
  ["nlua.nvim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nlua.nvim"
  },
  ["nord-vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nord-vim"
  },
  ["nvim-autopairs"] = {
    config = { "\27LJ\2\n?\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0$rc/plugin_config/nvim-autopairs\frequire\0" },
    load_after = {},
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nvim-autopairs"
  },
  ["nvim-cmp"] = {
    after = { "nvim-autopairs" },
    loaded = true,
    only_config = true
  },
  ["nvim-hlslens"] = {
    config = { "\27LJ\2\n[\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0<source ~/.config/nvim/rc/plugin_config/nvim-hlslens.vim\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nvim-hlslens"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\n?\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0$rc/plugin_config/nvim-lspconfig\frequire\0" },
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-syntax-info"] = {
    commands = { "SyntaxInfo" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nvim-syntax-info"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    after = { "nvim-ts-autotag" },
    config = { "\27LJ\2\n@\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0%rc/plugin_config/nvim-treesitter\frequire\0" },
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nvim-treesitter"
  },
  ["nvim-ts-autotag"] = {
    config = { "\27LJ\2\n=\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\20nvim-ts-autotag\frequire\0" },
    load_after = {
      ["nvim-treesitter"] = true
    },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/nvim-ts-autotag"
  },
  ["nvim-web-devicons"] = {
    config = { "\27LJ\2\nâ\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\4\0005\4\3\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\roverride\1\0\0\bnim\1\0\0\1\0\3\ncolor\f#f5d742\tname\bNim\ticon\bÔö§\nsetup\22nvim-web-devicons\frequire\0" },
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["onedark.vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/onedark.vim"
  },
  ["packer.nvim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/packer.nvim"
  },
  ["plantuml-syntax"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/plantuml-syntax"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  sonokai = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/sonokai"
  },
  ["splitjoin.vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/splitjoin.vim"
  },
  ["telescope.nvim"] = {
    config = { "\27LJ\2\n:\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\31rc/plugin_config/telescope\frequire\0" },
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/telescope.nvim"
  },
  ["tender.vim"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/tender.vim"
  },
  ["trouble.nvim"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/trouble.nvim"
  },
  ["vim-better-whitespace"] = {
    config = { "\27LJ\2\nP\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0001hi ExtraWhitespace guibg=#401000 ctermbg=red\bcmd\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-better-whitespace"
  },
  ["vim-bookmarks"] = {
    config = { "\27LJ\2\n‹\2\0\0\6\0\14\0)6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\6\0'\4\a\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\b\0'\4\t\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\n\0'\4\v\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\f\0'\4\r\0004\5\0\0B\0\5\1K\0\1\0\26<Plug>BookmarkShowAll\14<Space>ma\24<Plug>BookmarkClear\14<Space>m0\23<Plug>BookmarkPrev\14<Space>mp\23<Plug>BookmarkNext\14<Space>mn\25<Plug>BookmarkToggle\14<Space>mm\6n\20nvim_set_keymap\bapi\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-bookmarks"
  },
  ["vim-coloresque"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/vim-coloresque"
  },
  ["vim-crystal"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-crystal"
  },
  ["vim-css3-syntax"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-css3-syntax"
  },
  ["vim-easy-align"] = {
    commands = { "EasyAlign" },
    config = { "\27LJ\2\nt\0\0\5\0\a\0\0156\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0B\0\4\0016\0\0\0009\0\1\0009\0\2\0'\2\6\0'\3\4\0'\4\5\0B\0\4\1K\0\1\0\6x\22<Plug>(EasyAlign)\aga\6n\20nvim_set_keymap\bapi\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-easy-align"
  },
  ["vim-grammarous"] = {
    commands = { "GrammarousCheck" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-grammarous"
  },
  ["vim-hybrid"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-hybrid"
  },
  ["vim-javascript"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-javascript"
  },
  ["vim-jsonc"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-jsonc"
  },
  ["vim-matchup"] = {
    config = { "\27LJ\2\nÓ\1\0\0\3\0\b\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0005\1\4\0=\1\3\0006\0\0\0009\0\5\0'\2\6\0B\0\2\0016\0\0\0009\0\5\0'\2\a\0B\0\2\1K\0\1\0002hi MatchWordCur cterm=underline gui=underline3hi MatchParenCur cterm=underline gui=underline\bcmd\1\0\1\vmethod\npopup!matchup_matchparen_offscreen\19loaded_matchit\6g\bvim\0" },
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/vim-matchup"
  },
  ["vim-quickhl"] = {
    config = { "\27LJ\2\nÚ\1\0\0\6\0\t\0!6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\6\0'\3\4\0'\4\5\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\a\0'\4\b\0004\5\0\0B\0\5\0016\0\0\0009\0\1\0009\0\2\0'\2\6\0'\3\a\0'\4\b\0004\5\0\0B\0\5\1K\0\1\0!<Plug>(quickhl-manual-reset)\r<Space>H\6x <Plug>(quickhl-manual-this)\r<Space>h\6n\20nvim_set_keymap\bapi\bvim\0" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-quickhl"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/vim-repeat"
  },
  ["vim-rooter"] = {
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-rooter"
  },
  ["vim-sandwich"] = {
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-sandwich"
  },
  ["vim-silicon"] = {
    commands = { "Silicon" },
    loaded = false,
    needs_bufread = false,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-silicon"
  },
  ["vim-table-mode"] = {
    commands = { "TableModeEnable" },
    loaded = false,
    needs_bufread = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/opt/vim-table-mode"
  },
  ["vim-vsnip"] = {
    loaded = true,
    path = "/home/armkn/.local/share/nvim/site/pack/packer/start/vim-vsnip"
  }
}

time([[Defining packer_plugins]], false)
-- Setup for: indentLine
time([[Setup for indentLine]], true)
try_loadstring("\27LJ\2\n~\0\0\2\0\6\0\r6\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0)\1\0\0=\1\3\0006\0\0\0009\0\1\0'\1\5\0=\1\4\0K\0\1\0\b‚îÜ\20indentLine_char\26indentLine_setConceal\23indentLine_enabled\6g\bvim\0", "setup", "indentLine")
time([[Setup for indentLine]], false)
time([[packadd for indentLine]], true)
vim.cmd [[packadd indentLine]]
time([[packadd for indentLine]], false)
-- Setup for: emmet-vim
time([[Setup for emmet-vim]], true)
try_loadstring("\27LJ\2\n=\0\0\2\0\4\0\0056\0\0\0009\0\1\0'\1\3\0=\1\2\0K\0\1\0\n<M-y>\26user_emmet_leader_key\6g\bvim\0", "setup", "emmet-vim")
time([[Setup for emmet-vim]], false)
-- Setup for: vim-better-whitespace
time([[Setup for vim-better-whitespace]], true)
try_loadstring("\27LJ\2\nê\1\0\0\2\0\6\0\r6\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0'\1\4\0=\1\3\0006\0\0\0009\0\1\0)\1\0\0=\1\5\0K\0\1\0\29strip_whitespace_on_save\5\31better_whitespace_operator\30better_whitespace_enabled\6g\bvim\0", "setup", "vim-better-whitespace")
time([[Setup for vim-better-whitespace]], false)
-- Setup for: mkdx
time([[Setup for mkdx]], true)
try_loadstring("\27LJ\2\nì\2\0\0\6\0\17\0\0196\0\0\0009\0\1\0009\0\2\0'\2\3\0005\3\5\0005\4\4\0=\4\6\0035\4\a\0=\4\b\0035\4\t\0=\4\n\0035\4\f\0005\5\v\0=\5\r\4=\4\14\0035\4\15\0=\4\16\3B\0\3\1K\0\1\0\btoc\1\0\2\20update_on_write\3\1\ttext\22Table of Contents\nlinks\rexternal\1\0\0\1\0\1\venable\3\1\nenter\1\0\1\nshift\3\0\14highlight\1\0\1\venable\3\1\bmap\1\0\0\1\0\2\venable\3\0\vprefix\18<localleader>\18mkdx#settings\17nvim_set_var\bapi\bvim\0", "setup", "mkdx")
time([[Setup for mkdx]], false)
-- Setup for: clever-f.vim
time([[Setup for clever-f.vim]], true)
try_loadstring("\27LJ\2\nâ\1\0\0\2\0\5\0\r6\0\0\0009\0\1\0)\1\0\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\3\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0K\0\1\0\31clever_f_fix_key_direction\28clever_f_across_no_line\25clever_f_ignore_case\6g\bvim\0", "setup", "clever-f.vim")
time([[Setup for clever-f.vim]], false)
-- Setup for: vim-bookmarks
time([[Setup for vim-bookmarks]], true)
try_loadstring("\27LJ\2\nB\0\0\2\0\3\0\0056\0\0\0009\0\1\0)\1\1\0=\1\2\0K\0\1\0%bookmark_no_default_key_mappings\6g\bvim\0", "setup", "vim-bookmarks")
time([[Setup for vim-bookmarks]], false)
-- Setup for: vim-rooter
time([[Setup for vim-rooter]], true)
try_loadstring("\27LJ\2\nƒ\1\0\0\2\0\a\0\r6\0\0\0009\0\1\0'\1\3\0=\1\2\0006\0\0\0009\0\1\0)\1\1\0=\1\4\0006\0\0\0009\0\1\0005\1\6\0=\1\5\0K\0\1\0\1\v\0\0\ttags\t.git\n.git/\f_darcs/\t.hg/\n.bzr/\rMakefile\16GNUMakefile\16GNUmakefile\n.svn/\20rooter_patterns\23rooter_manual_only\blcd\18rooter_cd_cmd\6g\bvim\0", "setup", "vim-rooter")
time([[Setup for vim-rooter]], false)
-- Setup for: nvim-tree.lua
time([[Setup for nvim-tree.lua]], true)
try_loadstring("\27LJ\2\nx\0\0\6\0\a\0\t6\0\0\0009\0\1\0009\0\2\0'\2\3\0'\3\4\0'\4\5\0005\5\6\0B\0\5\1K\0\1\0\1\0\2\fnoremap\2\vsilent\2\29:<C-u>NvimTreeToggle<CR>\n<M-t>\6n\20nvim_set_keymap\bapi\bvim\0", "setup", "nvim-tree.lua")
time([[Setup for nvim-tree.lua]], false)
time([[packadd for nvim-tree.lua]], true)
vim.cmd [[packadd nvim-tree.lua]]
time([[packadd for nvim-tree.lua]], false)
-- Config for: bufferline.nvim
time([[Config for bufferline.nvim]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 rc/plugin_config/bufferline\frequire\0", "config", "bufferline.nvim")
time([[Config for bufferline.nvim]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n?\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0$rc/plugin_config/nvim-lspconfig\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: nvim-web-devicons
time([[Config for nvim-web-devicons]], true)
try_loadstring("\27LJ\2\nâ\1\0\0\5\0\b\0\v6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\6\0005\3\4\0005\4\3\0=\4\5\3=\3\a\2B\0\2\1K\0\1\0\roverride\1\0\0\bnim\1\0\0\1\0\3\ncolor\f#f5d742\tname\bNim\ticon\bÔö§\nsetup\22nvim-web-devicons\frequire\0", "config", "nvim-web-devicons")
time([[Config for nvim-web-devicons]], false)
-- Config for: nvim-cmp
time([[Config for nvim-cmp]], true)
try_loadstring("\27LJ\2\nÖ\1\0\0\3\0\5\0\b6\0\0\0'\2\1\0B\0\2\0016\0\2\0009\0\3\0'\2\4\0B\0\2\1K\0\1\0008source ~/.config/nvim/rc/plugin_config/nvim-cmp.vim\bcmd\bvim\30rc/plugin_config/nvim-cmp\frequire\0", "config", "nvim-cmp")
time([[Config for nvim-cmp]], false)
-- Config for: iceberg.vim
time([[Config for iceberg.vim]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0056\0\0\0009\0\1\0'\2\2\0B\0\2\1K\0\1\0\24colorscheme iceberg\bcmd\bvim\0", "config", "iceberg.vim")
time([[Config for iceberg.vim]], false)
-- Config for: vim-matchup
time([[Config for vim-matchup]], true)
try_loadstring("\27LJ\2\nÓ\1\0\0\3\0\b\0\0176\0\0\0009\0\1\0)\1\1\0=\1\2\0006\0\0\0009\0\1\0005\1\4\0=\1\3\0006\0\0\0009\0\5\0'\2\6\0B\0\2\0016\0\0\0009\0\5\0'\2\a\0B\0\2\1K\0\1\0002hi MatchWordCur cterm=underline gui=underline3hi MatchParenCur cterm=underline gui=underline\bcmd\1\0\1\vmethod\npopup!matchup_matchparen_offscreen\19loaded_matchit\6g\bvim\0", "config", "vim-matchup")
time([[Config for vim-matchup]], false)
-- Config for: galaxyline.nvim
time([[Config for galaxyline.nvim]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 rc/plugin_config/galaxyline\frequire\0", "config", "galaxyline.nvim")
time([[Config for galaxyline.nvim]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file SyntaxInfo lua require("packer.load")({'nvim-syntax-info'}, { cmd = "SyntaxInfo", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file Silicon lua require("packer.load")({'vim-silicon'}, { cmd = "Silicon", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file EasyAlign lua require("packer.load")({'vim-easy-align'}, { cmd = "EasyAlign", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file GrammarousCheck lua require("packer.load")({'vim-grammarous'}, { cmd = "GrammarousCheck", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
pcall(vim.cmd, [[command -nargs=* -range -bang -complete=file TableModeEnable lua require("packer.load")({'vim-table-mode'}, { cmd = "TableModeEnable", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]])
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType css ++once lua require("packer.load")({'vim-css3-syntax', 'emmet-vim'}, { ft = "css" }, _G.packer_plugins)]]
vim.cmd [[au FileType nim ++once lua require("packer.load")({'nim.vim'}, { ft = "nim" }, _G.packer_plugins)]]
vim.cmd [[au FileType plantuml ++once lua require("packer.load")({'plantuml-syntax'}, { ft = "plantuml" }, _G.packer_plugins)]]
vim.cmd [[au FileType jsonc ++once lua require("packer.load")({'vim-jsonc'}, { ft = "jsonc" }, _G.packer_plugins)]]
vim.cmd [[au FileType javascript ++once lua require("packer.load")({'vim-javascript'}, { ft = "javascript" }, _G.packer_plugins)]]
vim.cmd [[au FileType i3config ++once lua require("packer.load")({'i3config.vim'}, { ft = "i3config" }, _G.packer_plugins)]]
vim.cmd [[au FileType yaml ++once lua require("packer.load")({'github-actions-yaml.vim'}, { ft = "yaml" }, _G.packer_plugins)]]
vim.cmd [[au FileType markdown ++once lua require("packer.load")({'markdown-preview.nvim', 'mkdx', 'vim-css3-syntax', 'emmet-vim'}, { ft = "markdown" }, _G.packer_plugins)]]
vim.cmd [[au FileType crystal ++once lua require("packer.load")({'vim-crystal'}, { ft = "crystal" }, _G.packer_plugins)]]
vim.cmd [[au FileType apiblueprint ++once lua require("packer.load")({'apiblueprint.vim'}, { ft = "apiblueprint" }, _G.packer_plugins)]]
vim.cmd [[au FileType kotlin ++once lua require("packer.load")({'kotlin-vim'}, { ft = "kotlin" }, _G.packer_plugins)]]
vim.cmd [[au FileType html ++once lua require("packer.load")({'vim-css3-syntax', 'emmet-vim'}, { ft = "html" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
  -- Event lazy-loads
time([[Defining lazy-load event autocommands]], true)
vim.cmd [[au VimEnter * ++once lua require("packer.load")({'nvim-treesitter', 'nlua.nvim', 'nvim-autopairs', 'nvim-hlslens', 'hop', 'vim-quickhl', 'vim-rooter', 'vim-sandwich', 'splitjoin.vim', 'telescope.nvim', 'vim-better-whitespace', 'vim-bookmarks', 'clever-f.vim', 'gitsigns.nvim', 'kommentary'}, { event = "VimEnter *" }, _G.packer_plugins)]]
time([[Defining lazy-load event autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/nim.vim/ftdetect/nim.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/nim.vim/ftdetect/nim.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/nim.vim/ftdetect/nim.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/plantuml-syntax/ftdetect/plantuml.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/plantuml-syntax/ftdetect/plantuml.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/plantuml-syntax/ftdetect/plantuml.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/crystal.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/crystal.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/crystal.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/ecrystal.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/ecrystal.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-crystal/ftdetect/ecrystal.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/apiblueprint.vim/ftdetect/apiblueprint.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/apiblueprint.vim/ftdetect/apiblueprint.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/apiblueprint.vim/ftdetect/apiblueprint.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-jsonc/ftdetect/jsonc.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-jsonc/ftdetect/jsonc.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-jsonc/ftdetect/jsonc.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/github-actions-yaml.vim/ftdetect/gha.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/github-actions-yaml.vim/ftdetect/gha.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/github-actions-yaml.vim/ftdetect/gha.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/i3config.vim/ftdetect/i3config.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/i3config.vim/ftdetect/i3config.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/i3config.vim/ftdetect/i3config.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/kotlin-vim/ftdetect/kotlin.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/kotlin-vim/ftdetect/kotlin.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/kotlin-vim/ftdetect/kotlin.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-javascript/ftdetect/flow.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-javascript/ftdetect/flow.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-javascript/ftdetect/flow.vim]], false)
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-javascript/ftdetect/javascript.vim]], true)
vim.cmd [[source /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-javascript/ftdetect/javascript.vim]]
time([[Sourcing ftdetect script at: /home/armkn/.local/share/nvim/site/pack/packer/opt/vim-javascript/ftdetect/javascript.vim]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
