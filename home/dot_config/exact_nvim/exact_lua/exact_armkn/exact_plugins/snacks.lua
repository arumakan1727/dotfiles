-- snacks.nvim: 多数の小プラグインを1リポジトリへ集約する folke 製の QoL コレクション。
-- picker(telescope 代替)/ notifier(nvim-notify 代替)/ input(dressing 代替)/
-- indent(indent-blankline 代替)/ statuscolumn / bigfile / quickfile などを担う。

local function root_grep()
  Snacks.picker.grep({ cwd = require("armkn.util").get_root() })
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false, -- bigfile/quickfile/statuscolumn は file 描画前に hook する必要があるため
    ---@type snacks.Config
    opts = {
      -- 起動・大ファイル対策(常時 on・安価)
      bigfile = { enabled = true }, -- 巨大ファイルで重い機能を自動 off
      quickfile = { enabled = true }, -- プラグイン読込前に file を先に描画
      statuscolumn = { enabled = true }, -- number + sign + fold を統合

      -- UI 置き換え
      indent = { enabled = true }, -- indent ガイド + scope(indent-blankline 代替)
      scope = { enabled = true }, -- treesitter ベースの scope textobject/motion
      notifier = { enabled = true, timeout = 3000 }, -- vim.notify(nvim-notify 代替)
      input = { enabled = true }, -- vim.ui.input(dressing 代替)
      words = { enabled = true }, -- LSP 参照の自動ハイライト + ]]/[[ で巡回

      -- finder + ui.select
      picker = {
        enabled = true,
        ui_select = true, -- vim.ui.select も置き換え(dressing の select 相当)
        matcher = { frecency = true, cwd_bonus = true },
        formatters = { file = { filename_first = false } },
      },

      -- explorer は使わない(ホバー型は mini.files、バッファ編集型は oil.nvim を採用)
      explorer = { enabled = false },
      dashboard = { enabled = false }, -- 起動時間優先のため無効
    },
    -- stylua: ignore
    keys = {
      -- top-level
      { "<Leader><Space>", function() Snacks.picker.smart() end, desc = "Smart find files" },
      { "<Leader>/", function() Snacks.picker.lines() end, desc = "Buffer lines" },
      { "<Leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<Leader>:", function() Snacks.picker.command_history() end, desc = "Command history" },
      { "<Leader>n", function() Snacks.picker.notifications() end, desc = "Notification history" },

      -- find
      { "<Leader>ff", function() Snacks.picker.files() end, desc = "Find files (cwd)" },
      { "<Leader>fF", function() Snacks.picker.files({ cwd = require("armkn.util").get_root() }) end, desc = "Find files (root)" },
      { "<Leader>fg", function() Snacks.picker.git_files() end, desc = "Find git files" },
      { "<Leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<Leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<Leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find config file" },
      { "<Leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },

      -- search / grep
      { "<Leader>sg", function() Snacks.picker.grep() end, desc = "Grep (cwd)" },
      { "<Leader>sG", root_grep, desc = "Grep (root)" },
      { "<Leader>sw", function() Snacks.picker.grep_word() end, mode = { "n", "x" }, desc = "Grep word/selection" },
      { "<Leader>sb", function() Snacks.picker.lines() end, desc = "Buffer fuzzy" },
      { "<Leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<Leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Diagnostics (buffer)" },
      { "<Leader>sh", function() Snacks.picker.help() end, desc = "Help pages" },
      { "<Leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<Leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<Leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<Leader>sR", function() Snacks.picker.resume() end, desc = "Resume picker" },
      { "<Leader>sH", function() Snacks.picker.highlights() end, desc = "Highlight groups" },
      { "<Leader>s/", function() Snacks.picker.search_history() end, desc = "Search history" },
      { '<Leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { "<Leader>su", function() Snacks.picker.undo() end, desc = "Undo history" },

      -- git
      { "<Leader>gc", function() Snacks.picker.git_log() end, desc = "Git log" },
      { "<Leader>gC", function() Snacks.picker.git_log_file() end, desc = "Git log (file)" },
      { "<Leader>gs", function() Snacks.picker.git_status() end, desc = "Git status" },
      { "<Leader>gb", function() Snacks.picker.git_branches() end, desc = "Git branches" },
      { "<Leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<Leader>gB", function() Snacks.gitbrowse() end, mode = { "n", "v" }, desc = "Git browse (open in browser)" },

      -- ui
      { "<Leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
      { "<Leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },

      -- misc
      { "<Leader>.", function() Snacks.scratch() end, desc = "Toggle scratch buffer" },
      { "<Leader>S", function() Snacks.scratch.select() end, desc = "Select scratch buffer" },
      { "<C-/>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "Toggle terminal" },
      { "<LocalLeader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer" },
      { "<LocalLeader>bD", function() Snacks.bufdelete({ force = true }) end, desc = "Delete buffer (force)" },
      { "<LocalLeader>cR", function() Snacks.rename.rename_file() end, desc = "Rename file (LSP-aware)" },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- 便利トグル(<Leader>u プレフィックス)
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<Leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<Leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<Leader>uL")
          Snacks.toggle.diagnostics():map("<Leader>ud")
          Snacks.toggle.line_number():map("<Leader>ul")
          Snacks.toggle.treesitter():map("<Leader>uT")
          Snacks.toggle.inlay_hints():map("<Leader>uh")
          Snacks.toggle.indent():map("<Leader>ug")
        end,
      })
    end,
  },
}
