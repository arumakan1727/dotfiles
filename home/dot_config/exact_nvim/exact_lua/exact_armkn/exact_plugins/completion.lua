return {
  -- 補完エンジン: blink.cmp。
  -- 供給網方針により Rust の prebuilt バイナリ DL(同梱 .sha256 のみで検証=信頼の起点にできない)も
  -- cargo build(重い)も避け、純 Lua の fuzzy matcher を使う(fuzzy.implementation='lua')。
  {
    "saghen/blink.cmp",
    version = "1.10.2", -- exact tag pin(floating な '1.*' は使わない)
    event = "InsertEnter",
    dependencies = { "folke/lazydev.nvim" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "enter", -- <CR> で確定、<C-n>/<C-p> で選択、<C-Space> で起動、<C-e> で中断
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        menu = { border = "rounded" },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lazydev", "lsp", "path", "buffer" },
        providers = {
          -- lazydev: require() のパス補完を LSP より優先
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
      -- 純 Lua matcher(native バイナリ不要・DL 不要)。巨大候補で僅かに遅いが供給網は最小。
      fuzzy = { implementation = "lua" },
      -- コマンドライン補完(`:e <Tab>` 等)。
      -- デフォルトの <Tab> は { 'show_and_insert_or_accept_single', 'select_next' } で
      -- 1回目から最長一致を挿入してしまう。代わりに:
      --   <Tab>        = メニュー非表示なら show / 表示中なら選択中候補を確定(accept)
      --   <Up>/<Down>  = 候補のハイライト移動(menu 非表示時は history へ fallback)
      -- これで `path/` を accept するとメニューが一旦閉じ、次の <Tab> で `path/` 配下を出せる
      -- (select_next だと accept 後も選択モードが続き兄弟へ切り替わってしまう)。
      cmdline = {
        keymap = {
          preset = "cmdline",
          ["<Tab>"] = { "show", "select_and_accept" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<Up>"] = { "select_prev", "fallback" },
        },
        completion = {
          -- preselect=false: メニュー表示直後は何も選択しない(=挿入もしない)
          -- auto_insert=false: <Up>/<Down> は menu 内のハイライト移動のみ。
          --                    入力欄へ反映されるのは <Tab>(accept)を押したときだけ。
          list = { selection = { preselect = false, auto_insert = false } },
          menu = { auto_show = false }, -- Tab を押すまでメニューを出さない
        },
      },
    },
    opts_extend = { "sources.default" },
  },

  -- 括弧の自動補完(markdown のコードフェンス等の edge case 処理が mini.pairs より堅い)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true, -- treesitter を見て文字列/コメント内では補完しない
      ts_config = { lua = { "string" }, javascript = { "template_string" } },
    },
  },
}
