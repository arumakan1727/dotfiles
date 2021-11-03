local nvim_lsp = require'lspconfig'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = {noremap=true, silent=true}

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  -- buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  -- buf_set_keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  -- buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  -- buf_set_keymap('n', '<M-CR>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  -- buf_set_keymap('n', '[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  -- buf_set_keymap('n', ']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  vim.cmd 'hi LspDiagnosticsDefaultError guifg=#ff0000'
  vim.cmd 'hi LspDiagnosticsDefaultWarning guifg=#f0ac00'
  vim.cmd 'hi LspDiagnosticsDefaultHint guifg=#66ddff'
  vim.cmd 'hi LspSagaLightBulbSign guifg=#ffe090'
  vim.cmd 'hi LspSagaLightBulb     guifg=#ffe090'

  require'lsp_signature'.on_attach({
      bind = true,
      max_height = 3,
      max_width = 80,
      zindex = 50,  -- send floating window to back layer
    })
end

local autoStartDisable = {}
autoStartDisable['volar'] = 1
autoStartDisable['vuels'] = 1

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local flags = {
  debounce_text_changes = 1000,
}

local defaultConfig = {
  autostart = true,
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
}

nvim_lsp.bashls.setup(defaultConfig)
nvim_lsp.cssls.setup(defaultConfig)
nvim_lsp.gopls.setup(defaultConfig)
nvim_lsp.hls.setup(defaultConfig)
nvim_lsp.html.setup(defaultConfig)
nvim_lsp.jsonls.setup(defaultConfig)
nvim_lsp.nimls.setup(defaultConfig)
nvim_lsp.pyright.setup(defaultConfig)
nvim_lsp.tsserver.setup(defaultConfig)
nvim_lsp.vimls.setup(defaultConfig)

nvim_lsp.clangd.setup {
  autostart = true,
  cmd = { 'clangd', '--background-index', '--enable-config', '--header-insertion=never' },
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
}
nvim_lsp.vuels.setup {
  autostart = false,
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
}
nvim_lsp.volar.setup {
  autostart = false,
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
}

---------------------------------------------------------------------
-- null-ls
--[[ local null_ls = require'null-ls'
null_ls.config {
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint_d,
  }
}
nvim_lsp['null-ls'].setup{} ]]

---------------------------------------------------------------------
-- lspsaga
local saga = require'lspsaga'
saga.init_lsp_saga {
  error_sign = '',
  warn_sign = '',
  hint_sign = '',
  infor_sign = '',
  code_action_prompt = {
    enable = false,
  },
}

-- find the cursor word definition and references
vim.api.nvim_set_keymap('n', 'gh',
  '<cmd>lua require("lspsaga.provider").lsp_finder()<CR>',
  {noremap = true, silent = true}
)

-- code action
vim.api.nvim_set_keymap('n', '<M-CR>',
  '<cmd>lua require("lspsaga.codeaction").code_action()<CR>',
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap('v', '<M-CR>',
  '<cmd>lua require("lspsaga.codeaction").range_code_action()<CR>',
  {noremap = true, silent = true}
)

-- hover doc
vim.api.nvim_set_keymap('n', 'K',
  '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>',
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap('n', '<M-j>',
  '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(1)<CR>',
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap('n', '<M-k>',
  '<cmd>lua require("lspsaga.action").smart_scroll_with_saga(-1)<CR>',
  {noremap = true, silent = true}
)

-- signature help
vim.api.nvim_set_keymap('n', 'gs',
  '<cmd>lua require("lspsaga.signaturehelp").signature_help()<CR>',
  {noremap = true, silent = true}
)

-- rename
vim.api.nvim_set_keymap('n', '<Space>rn',
  '<cmd>lua require("lspsaga.rename").rename()<CR>',
  {noremap = true, silent = true}
)

-- preiew definition
vim.api.nvim_set_keymap('n', '<M-d>',
  '<cmd>lua require("lspsaga.provider").preview_definition()<CR>',
  {noremap = true, silent = true}
)

-- show diagnostic
vim.api.nvim_set_keymap('n', '<Space>dl',
  '<cmd>lua require("lspsaga.diagnostic").show_line_diagnostics()<CR>',
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap('n', '<Space>dc',
  '<cmd>lua require("lspsaga.diagnostic").show_cursor_diagnostics()<CR>',
  {noremap = true, silent = true}
)

-- jump diagnostic
vim.api.nvim_set_keymap('n', '[e',
  '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<CR>',
  {noremap = true, silent = true}
)
vim.api.nvim_set_keymap('n', ']e',
  '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<CR>',
  {noremap = true, silent = true}
)

---------------------------------------------------------------------
-- trouble
require'trouble'.setup {
}
vim.api.nvim_set_keymap('n', '<Space>e',
  '<cmd>TroubleToggle<CR>', {noremap = true, silent = true}
)
