augroup MyFiletypeSpecificSettings
  autocmd!
  autocmd FileType html,vue syntax sync fromstart
  autocmd FileType go,lua setlocal noexpandtab shiftwidth=4
  autocmd FileType * set formatoptions-=o
augroup END
