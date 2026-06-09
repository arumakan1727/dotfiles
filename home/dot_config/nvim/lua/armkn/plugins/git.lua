return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
        map({ "n", "v" }, "ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
        map({ "n", "v" }, "ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "ghS", gs.stage_buffer, "Stage buffer")
        -- 新 gitsigns では stage_hunk が staged sign 上で unstage トグルになる(undo_stage_hunk は deprecated)
        map("n", "ghu", gs.stage_hunk, "Toggle stage hunk (unstage)")
        map("n", "ghR", gs.reset_buffer, "Reset buffer")
        map("n", "ghp", gs.preview_hunk, "Preview hunk")
        map("n", "ghb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "ghd", gs.diffthis, "Diff this")
        map("n", "ghD", function() gs.diffthis("~") end, "Diff this ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
        -- stylua: ignore end
      end,
    },
  },
}
