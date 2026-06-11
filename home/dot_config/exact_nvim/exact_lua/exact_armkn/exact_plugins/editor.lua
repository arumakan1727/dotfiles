return {
  -- ジャンプ: flash.nvim(leap + flit を1本に。検索ラベル / treesitter select / 強化 f/t)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
      { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle flash search" },
    },
  },

  -- ディレクトリをテキストバッファとして編集(リネーム/移動/削除を vim 編集 + :w で適用)
  -- netrw の置き換え。`-` で親を開く。`<C-f>` で float 化。
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-mini/mini.nvim" }, -- mini.icons
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
      float = { padding = 2, max_width = 110, max_height = 30, preview_split = "right" },
      keymaps = {
        ["<C-f>"] = { "actions.preview", mode = "n" },
        ["q"] = { "actions.close", mode = "n" },
      },
    },
    -- stylua: ignore
    keys = {
      { "-", "<Cmd>Oil<CR>", desc = "Oil (parent dir)" },
      { "<Leader>o", function() require("oil").open_float() end, desc = "Oil (float)" },
    },
  },

  -- which-key v3(group ラベルは add() で。旧 register() は廃止)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<Leader>c", group = "code" },
        { "<Leader>f", group = "find/file" },
        { "<Leader>g", group = "git" },
        { "<Leader>s", group = "search" },
        { "<Leader>u", group = "ui/toggle" },
        { "<Leader>w", group = "window", proxy = "<C-w>" },
        { "<Leader>x", group = "diagnostics/trouble" },
        { "<LocalLeader>b", group = "buffer" },
        { "<LocalLeader>c", group = "code" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "]", group = "next" },
        { "[", group = "prev" },
      },
    },
    keys = {
      {
        "<Leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer keymaps (which-key)",
      },
    },
  },

  -- ドットリピートの対象を広げる(surround 等)
  { "tpope/vim-repeat", event = "VeryLazy" },
}
