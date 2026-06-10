-- conform.nvim: フォーマッタは mise/system の CLI を spawn する(null-ls の後継)。
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  -- stylua: ignore
  keys = {
    { "<Leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, mode = { "n", "v" }, desc = "Format buffer/range" },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      python = { "ruff_organize_imports", "ruff_format" },
      go = { "goimports", "gofmt" },
      rust = { "rustfmt" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      toml = { "taplo" },
      terraform = { "terraform_fmt" },
      -- prettier 系(prettierd 優先、無ければ prettier)。最初に見つかった1つだけ実行。
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      vue = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      -- prisma / typst / dart / ruby 等は各 LSP の formatter に委譲(lsp_format = fallback)
    },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(bufnr)
      -- グローバル / バッファ単位の抑止スイッチ
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      -- vendored ファイルは整形しない
      if vim.api.nvim_buf_get_name(bufnr):match("/node_modules/") then
        return
      end
      return { timeout_ms = 1000, lsp_format = "fallback" }
    end,
    formatters = {
      -- prettier はプロジェクトルート(package.json 等)がある時だけ動かす
      prettier = { require_cwd = true },
      prettierd = { require_cwd = true },
    },
  },
  init = function()
    -- gq でも conform を使う
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

    vim.api.nvim_create_user_command("FormatDisable", function(a)
      if a.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { bang = true, desc = "Disable autoformat-on-save (! = buffer only)" })
    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = "Re-enable autoformat-on-save" })
  end,
}
