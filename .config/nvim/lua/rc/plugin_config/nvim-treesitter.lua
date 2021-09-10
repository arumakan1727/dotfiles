require'nvim-treesitter.configs'.setup {
  ensure_installed = 'all',
  highlight = {
    enable = true,
    disable = {
      'bash',
      'css',
      'html',
      'htmldjango',
      'markdown',
      'sh',
      'vim',
      'vue',
      'zsh',
    },
  },
  indent = {
    enable = true,
    disable = {'python'},
  },
}
