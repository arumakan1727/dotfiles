"==============================
" Plugin config, install
"==============================

if &compatible
  set nocompatible
endif

let s:dein_cache_path = expand('~/.cache') . (has('nvim') ? '/nvim/dein' : '/vim/dein')
let s:dein_repo_dir = s:dein_cache_path .'/repos/github.com/Shougo/dein.vim'

if &runtimepath !~ '/dein.vim'
  "dein_repo_dir がないならクローン
  if !isdirectory(s:dein_repo_dir)
    call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
  endif
  " パスにdeinディレクトリを追加
  let &runtimepath = s:dein_repo_dir . ',' . &runtimepath
endif

"-------------------------------------------------------------------------------
" プラグイン読み込み & キャッシュ作成
if dein#load_state(s:dein_cache_path)
  call dein#begin(s:dein_cache_path)
  call dein#load_toml('~/.config/nvim/pluginconfig/dein.toml', {'lazy' : 0})
  call dein#load_toml('~/.config/nvim/pluginconfig/deinlazy.toml', {'lazy' : 1})
  call dein#end()
  call dein#save_state()
endif

" 不足プラグインの自動インストール
if dein#check_install()
  call dein#install()
endif

"filetype plugin indent on
syntax enable
