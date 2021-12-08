set expandtab
set tabstop=2 shiftwidth=2 softtabstop=2

augroup MyIndentSettingsByFiletype
  autocmd!
  autocmd Filetype tsv
        \ setlocal shiftwidth=12 tabstop=12 softtabstop=12 noexpandtab
  autocmd FileType go
        \ setlocal noexpandtab shiftwidth=4 tabstop=4
  autocmd FileType c,cpp,java,python,nim
        \ setlocal tabstop=4 shiftwidth=4 softtabstop=4
augroup END
