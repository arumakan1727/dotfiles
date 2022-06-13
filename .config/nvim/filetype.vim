au! BufRead,BufNewFile */i3/config
      \ setlocal filetype=i3config
au! BufRead,BufNewFile *.tsv
      \ setlocal filetype=tsv tabstop=8
au! BufRead,BufNewFile *.csv
      \ setlocal filetype=csv
au! BufRead,BufNewFile .clang-format
      \ setlocal filetype=yaml
au! BufRead,BufNewFile *.en
      \ setlocal filetype=txt spell
au! BufRead,BufNewFile tsconfig.json
      \ setlocal filetype=jsonc
au! BufRead,BufNewFile .flake8
      \ setlocal filetype=cfg
au! BufRead,BufNewFile *.nim
      \ setlocal filetype=nim
au! BufRead,BufNewFile *.saty,*.satyh,*satyh-*,*.satyg
      \ setlocal filetype=satysfi
au! BufRead,BufNewFile Makefile
      \ setlocal filetype=make
au! BufRead,BufNewFile *.snippets
      \ setlocal filetype=snippets
au! BufRead,BufNewFile *.prolog
      \ setlocal filetype=prolog
