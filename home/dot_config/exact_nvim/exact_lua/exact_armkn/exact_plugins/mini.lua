-- mini.nvim(monorepo)を1 pin で導入し、使うモジュールだけ setup する。
-- 採用: icons(devicons の mock)/ ai(textobject)/ surround / splitjoin / files(ホバー型ファイラ)。
-- comment は native gc、bufremove は snacks.bufdelete、indentscope は snacks.indent に置換済み。
return {
  "nvim-mini/mini.nvim",
  lazy = false, -- mini.icons の mock を bufferline/lualine 読み込み前に効かせるため
  priority = 900,
  -- stylua: ignore
  keys = {
    { "<Leader>e", function()
      local mf = require("mini.files")
      -- close() は 成功=true / 未オープン=nil / 保留中で拒否=false。
      -- 未オープン(nil)のときだけ開く(false=保留中は二重 open しない)。
      if mf.close() == nil then
        local buf = vim.api.nvim_buf_get_name(0)
        mf.open(buf ~= "" and buf or (vim.uv or vim.loop).cwd(), true)
      end
    end, desc = "Explorer (mini.files, hover)" },
    { "<Leader>E", function()
      require("mini.files").open((vim.uv or vim.loop).cwd(), true)
    end, desc = "Explorer (mini.files, cwd)" },
  },
  config = function()
    -- icons: nvim-web-devicons を mock して bufferline/lualine/snacks に供給(別 dep を増やさない)
    require("mini.icons").setup()
    MiniIcons.mock_nvim_web_devicons()

    -- textobjects: 既定 + underscore を跨がない word `s`。af/if/ac/ic と移動/swap は
    -- nvim-treesitter-textobjects 側が担当する(treesitter.lua)。
    require("mini.ai").setup({
      search_method = "cover",
      custom_textobjects = {
        s = { "%f[%w]%w+", "^().*()$" },
      },
    })

    -- surround: gs プレフィックス(s は flash.jump が使うため衝突回避)。
    -- gsa(add) gsd(delete) gsr(replace) gsf/gsF(find) gsh(highlight) gsn(update n_lines)
    require("mini.surround").setup({
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    })

    -- gS で split/join トグル
    require("mini.splitjoin").setup()

    -- ホバー型ファイラ(浮動 Miller カラム)。default explorer は oil.nvim に任せる。
    require("mini.files").setup({
      windows = { preview = true, width_focus = 30, width_preview = 60 },
      options = { use_as_default_explorer = false },
    })

    -- tabline(buffer 一覧)。bufferline の代替(現役メンテ + 新規依存ゼロ)。
    require("mini.tabline").setup({ show_icons = true })
  end,
}
