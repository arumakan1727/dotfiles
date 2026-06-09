-- LSP は nvim 0.11+ の native API(vim.lsp.config / vim.lsp.enable)で構成する。
-- mason は使わず、言語サーバ本体は mise/system で PATH に用意する(供給網の信頼源を一本化)。
-- nvim-lspconfig は「lsp/<server>.lua の設定データ集」としてのみ使い、setup() は呼ばない。
-- サーバ個別の上書きは after/lsp/<server>.lua に置く。

-- vim.lsp.enable で有効化するサーバ一覧。PATH に本体が無いものは黙って attach しない。
local SERVERS = {
  "lua_ls",
  "clangd",
  "gopls",
  "rust_analyzer",
  "ts_ls",
  "denols",
  "basedpyright",
  "ruff",
  "jsonls",
  "cssls",
  "html",
  "eslint",
  "yamlls",
  "taplo",
  "terraformls",
  "bashls",
  "dockerls",
  "prismals",
  "tinymist",
  "vue_ls",
  "dartls",
  "cmake",
}

local function on_attach(client, bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  -- 参照系は snacks.picker の UI で開く(native の grr/gri 等は quickfix を開くため上書き)
  map("n", "gd", function()
    Snacks.picker.lsp_definitions()
  end, "Goto definition")
  map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
  map("n", "grr", function()
    Snacks.picker.lsp_references()
  end, "References")
  map("n", "gri", function()
    Snacks.picker.lsp_implementations()
  end, "Goto implementation")
  map("n", "gy", function()
    Snacks.picker.lsp_type_definitions()
  end, "Goto type definition")
  map("n", "<Leader>ss", function()
    Snacks.picker.lsp_symbols()
  end, "Document symbols")
  map("n", "<Leader>sS", function()
    Snacks.picker.lsp_workspace_symbols()
  end, "Workspace symbols")

  -- grn(rename)/ gra(code action)/ K(hover)/ <C-s>(signature) は 0.11+ の native default を使う。
  -- 慣れ用に <LocalLeader>c 系のエイリアスも張る。
  map("n", "<LocalLeader>cr", vim.lsp.buf.rename, "Rename symbol")
  map({ "n", "v" }, "<LocalLeader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<LocalLeader>cd", vim.diagnostic.open_float, "Line diagnostics")
  map("n", "<LocalLeader>ci", "<Cmd>checkhealth vim.lsp<CR>", "LSP info")

  -- 診断ジャンプ([d/]d は native default。重大度別を追加)
  map("n", "]e", function()
    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
  end, "Next error")
  map("n", "[e", function()
    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
  end, "Prev error")
  map("n", "]w", function()
    vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN })
  end, "Next warning")
  map("n", "[w", function()
    vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN })
  end, "Prev warning")

  -- inlay hint は既定で on(snacks.toggle.inlay_hints で切替可)
  if client:supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

return {
  -- Lua/Neovim API 開発支援(neodev の後継)
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- 診断表示
      local icons = require("armkn.util.icons").diagnostics
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = { spacing = 4, prefix = "●", source = "if_many" },
        float = { border = "rounded", source = "if_many" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = icons.Error,
            [vim.diagnostic.severity.WARN] = icons.Warn,
            [vim.diagnostic.severity.HINT] = icons.Hint,
            [vim.diagnostic.severity.INFO] = icons.Info,
          },
        },
      })

      -- 補完 capabilities を全サーバの既定に合流(blink.cmp)
      local caps = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        caps = blink.get_lsp_capabilities(caps)
      end
      vim.lsp.config("*", { capabilities = caps })

      -- LspAttach 時にバッファローカルなキーマップを張る
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("armkn_lsp_attach", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then
            on_attach(client, ev.buf)
          end
        end,
      })

      vim.lsp.enable(SERVERS)
    end,
  },
}
