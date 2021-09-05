local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-y>'] = cmp.mapping.confirm({
      select = true,
      behavior = cmp.ConfirmBehavior.Insert,
    }),
    ['<CR>'] = cmp.mapping.confirm({
      select = true,
      behavior = cmp.ConfirmBehavior.Replace,
    }),
    ['<M-j>'] = cmp.mapping.scroll_docs(2),
    ['<M-k>'] = cmp.mapping.scroll_docs(-2),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-q>'] = cmp.mapping.close(),
  },
  sources = {
    {name = 'nvim_lsp'},
    {name = 'path'},
    {name = 'buffer'},
  },
  preselect = cmp.PreselectMode.None,
  formatting = {
    format = function(entry, vim_item)
      -- fancy icons and a name of kind
      vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind

      -- set a name for each source
      vim_item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        latex_symbols = "[Latex]",
      })[entry.source.name]
      return vim_item
    end,
  },
})
