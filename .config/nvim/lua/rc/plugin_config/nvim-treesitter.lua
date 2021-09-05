require'nvim-treesitter.configs'.setup {
  ensure_installed = 'all',
  highlight = {
    enable = true,
    disable = {'vim', 'zsh', 'sh', 'bash', 'html', 'htmldjango', 'css', 'markdown'},
  },
  indent = {
    enable = true,
    disable = {'python', 'html', 'htmldjango', 'javascript'},
  },
}
