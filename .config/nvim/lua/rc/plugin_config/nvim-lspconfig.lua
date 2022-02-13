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
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  -- buf_set_keymap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<M-CR>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

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
  debounce_text_changes = 300,
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
nvim_lsp.ocamllsp.setup(defaultConfig)
nvim_lsp.pyright.setup(defaultConfig)
nvim_lsp.rust_analyzer.setup(defaultConfig)
nvim_lsp.tsserver.setup(defaultConfig)
nvim_lsp.vimls.setup(defaultConfig)

nvim_lsp.clangd.setup {
  autostart = true,
  cmd = { 'clangd', '--background-index', '--enable-config', '--header-insertion=never' },
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
}
--[[ nvim_lsp.java_language_server.setup {
  autostart = true,
  cmd = { vim.fn.expand('~/ghq/github.com/georgewfraser/java-language-server/dist/lang_server_linux.sh') },
  on_attach = on_attach,
  capabilities = capabilities,
  flags = flags,
} ]]
nvim_lsp.jdtls.setup {
  autostart = true,
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "-Xmx2G",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    vim.fn.expand("~/.local/share/jdtls-manual-install/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar"),
    "-configuration",
    vim.fn.expand("~/.local/share/jdtls-manual-install/config_linux"),
    "-data",
    vim.fn.expand("~/.cache/jdtls/projdata/tmp"),
  },
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
-- trouble
require'trouble'.setup {
}
vim.api.nvim_set_keymap('n', '<M-e>',
  '<cmd>TroubleToggle<CR>', {noremap = true, silent = true}
)
