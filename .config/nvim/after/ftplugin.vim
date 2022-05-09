augroup MyFiletypeSpecificSettings
  autocmd!
  autocmd FileType html,vue syntax sync fromstart
  autocmd FileType lua setlocal noexpandtab
  autocmd FileType * set formatoptions-=o
augroup END
