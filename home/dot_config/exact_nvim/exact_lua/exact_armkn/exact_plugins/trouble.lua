return {
  -- 診断 / symbol / 参照などの一覧(v3。旧 TroubleToggle ではなく `Trouble <mode>`)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { use_diagnostic_signs = true },
    -- stylua: ignore
    keys = {
      { "<Leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<Leader>xX", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics (Trouble)" },
      { "<Leader>xs", "<Cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
      { "<Leader>xl", "<Cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP refs/defs (Trouble)" },
      { "<Leader>xL", "<Cmd>Trouble loclist toggle<CR>", desc = "Location list (Trouble)" },
      { "<Leader>xQ", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix list (Trouble)" },
    },
  },

  -- 複数ファイル一括検索置換(ripgrep ベース。nvim-spectre の現役メンテ代替)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    -- stylua: ignore
    keys = {
      { "<Leader>sr", function() require("grug-far").open() end, desc = "Search & replace in files (grug-far)" },
      { "<Leader>sr", function() require("grug-far").open({ visualSelectionUsage = "operate-within-range" }) end, mode = "v", desc = "Search & replace within range" },
    },
    opts = {},
  },
}
