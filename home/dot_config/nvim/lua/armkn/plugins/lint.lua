-- nvim-lint: リンタも mise/system の CLI を spawn し、結果は vim.diagnostic に流す。
return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" },
  config = function()
    local lint = require("lint")
    lint.linters_by_ft = {
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      dockerfile = { "hadolint" },
      go = { "golangcilint" },
      yaml = { "yamllint" },
      markdown = { "markdownlint" },
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      vue = { "eslint_d" },
      -- python は ruff を LSP として動かしているので nvim-lint 側では重複させない
    }

    local function try_lint()
      -- 本体が PATH に無いリンタはスキップ(mise 未導入でもエラーにしない)。
      -- 一部のリンタ(eslint_d 等)は cmd が関数なので、文字列に解決してから判定する
      -- (関数を vim.fn.executable に渡すと E1174 で try_lint 全体が落ちる)。
      local names = vim.tbl_filter(function(name)
        local linter = lint.linters[name]
        local cmd = type(linter) == "table" and linter.cmd or nil
        if type(cmd) == "function" then
          local ok, resolved = pcall(cmd)
          cmd = ok and resolved or nil
        end
        return type(cmd) == "string" and vim.fn.executable(cmd) == 1
      end, lint.linters_by_ft[vim.bo.filetype] or {})

      -- eslint は設定ファイルが無いプロジェクトでは走らせない
      if vim.tbl_contains(names, "eslint_d") then
        local root = vim.fs.root(0, {
          ".eslintrc",
          ".eslintrc.js",
          ".eslintrc.cjs",
          ".eslintrc.json",
          "eslint.config.js",
          "eslint.config.mjs",
          "eslint.config.ts",
          "package.json",
        })
        if not root then
          names = vim.tbl_filter(function(n)
            return n ~= "eslint_d"
          end, names)
        end
      end

      if #names > 0 then
        lint.try_lint(names)
      end
    end

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("armkn_nvim_lint", { clear = true }),
      callback = function()
        vim.schedule(try_lint)
      end,
    })
  end,
}
