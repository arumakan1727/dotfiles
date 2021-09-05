au! BufRead,BufNewFile */i3/config
      \ setlocal filetype=i3config
au! BufRead,BufNewFile *.tsv
      \ setlocal filetype=tsv
au! BufRead,BufNewFile .clang-format
      \ setlocal filetype=yaml
au! BufRead,BufNewFile *.en
      \ setlocal filetype=txt spell
au! BufRead,BufNewFile tsconfig.json
      \ setlocal filetype=jsonc
