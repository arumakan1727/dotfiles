set expandtab
set tabstop=2 shiftwidth=2 softtabstop=2

augroup MyIndentSettingsByFiletype
  autocmd!
  autocmd Filetype tsv
        \ setlocal shiftwidth=16 tabstop=16 softtabstop=16 noexpandtab
  autocmd FileType go
        \ setlocal noexpandtab shiftwidth=4 tabstop=4
  autocmd FileType c,cpp,java,python
        \ setlocal tabstop=4 shiftwidth=4 softtabstop=4
augroup END
