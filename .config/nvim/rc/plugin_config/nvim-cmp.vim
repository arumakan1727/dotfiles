augroup nvim_cmp_filetype_config
  autocmd!
  autocmd FileType lua,vim lua require'cmp'.setup.buffer {
        \   sources = {
          \     {name = 'nvim_lua'},
          \     {name = 'path'},
          \     {name = 'buffer'},
          \   },
          \ }
augroup END
