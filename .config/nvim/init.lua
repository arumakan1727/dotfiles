vim.o.encoding = "utf-8"
vim.o.fileencodings = "ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,sjis,latin1"
vim.o.fileformats = "unix,dos,mac"

vim.cmd 'source ~/.config/nvim/rc/base.vim'
vim.cmd 'source ~/.config/nvim/rc/mappings.vim'
require 'rc/plugin_list'
vim.cmd 'source ~/.config/nvim/rc/functions.vim'
