-- nvim-treesitter は 2026-04-03 に archive(read-only)化された。
-- 供給網方針: archive 済み main を「凍結 commit SHA」で固定する(SHA が二度と動かない=改竄不能)。
-- main は full-rewrite で API が一新されている(旧 require('nvim-treesitter.configs').setup は廃止):
--   - パーサは require('nvim-treesitter').install(...) で明示インストール(tree-sitter CLI + cc が必要)
--   - highlight は FileType autocmd で vim.treesitter.start() を呼んで有効化する
-- gc/gcc コメントは 0.10+ の native 機能(プラグイン不要)。embedded 言語の commentstring だけ
-- ts-comments.nvim で補う。

local PARSERS = {
  "bash",
  "c",
  "cpp",
  "comment",
  "css",
  "dart",
  "diff",
  "dockerfile",
  "git_config",
  "gitcommit",
  "git_rebase",
  "go",
  "gomod",
  "gosum",
  "hcl",
  "html",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "prisma",
  "python",
  "query",
  "regex",
  "ruby",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "typst",
  "terraform",
  "vim",
  "vimdoc",
  "vue",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    commit = "4916d6592ede8c07973490d9322f187e07dfefac", -- archive 済み main の凍結 tip(以後不変)
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup()
      -- パーサを非同期インストール(初回は cc / tree-sitter CLI でビルドされる)
      pcall(function()
        require("nvim-treesitter").install(PARSERS)
      end)

      -- FileType ごとに treesitter highlight を有効化(パーサ未導入なら pcall で握りつぶす)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("armkn_treesitter", { clear = true }),
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },

  -- textobjects(maintained, main branch)。af/if/ac/ic の選択、関数/クラス間移動、引数 swap。
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main", -- rewrite は main 側(lazy-lock.json が SHA を固定する)
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      -- select: af/if(function), ac/ic(class)
      local sel = {
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
      }
      for lhs, query in pairs(sel) do
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, "textobjects")
        end, { desc = "Select " .. query })
      end

      -- move: ]f/[f(function), ]c/[c(class)
      vim.keymap.set({ "n", "x", "o" }, "]f", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function start" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev function start" })
      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start" })
      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Prev class start" })

      -- swap: ,al / ,ah で引数を入れ替え
      vim.keymap.set("n", ",al", function()
        swap.swap_next("@parameter.inner")
      end, { desc = "Swap next parameter" })
      vim.keymap.set("n", ",ah", function()
        swap.swap_previous("@parameter.inner")
      end, { desc = "Swap prev parameter" })
    end,
  },

  -- HTML/JSX/Vue 等のタグ自動閉じ・リネーム
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "xml", "javascriptreact", "typescriptreact", "vue", "svelte", "markdown", "php" },
    opts = {
      opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
    },
  },

  -- embedded 言語を考慮した commentstring(native gc と統合)
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10") == 1,
    opts = {},
  },
}
