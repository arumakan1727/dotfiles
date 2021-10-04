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
    enable = false,
    -- disable = {'python', 'html', 'javascript', 'vue',},
  },
  matchup = {
    enable = true,
    disable = {'html', 'htmldjango', 'vue', 'xml'},
  }
}
