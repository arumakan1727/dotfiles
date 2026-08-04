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
        -- default プリセット: <C-y> で確定、<C-n>/<C-p>・<Up>/<Down> で選択、<C-Space> で起動、<C-e> で中断。
        preset = "default",
        -- <Tab> / <CR> はどちらも「選択中の候補」を確定(accept)する。
        -- accept は選択中の候補が無いと no-op(init.lua: item==nil で return)。preselect=false で
        -- 何も自動選択されないため、Up/Down 等で明示的に選ぶまでは
        --   <Tab> → スニペット前進 or 素の Tab、<CR> → 素の改行(autopairs の CR 展開も生きる)
        -- となり「未選択なのに先頭候補が勝手に挿入される」ことはない。
        ["<Tab>"] = { "snippet_forward", "accept", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        -- 候補は未選択の状態で表示し(preselect=false)、Up/Down は menu 内のハイライト移動だけ
        -- (auto_insert=false なのでバッファは変わらない)。実際に挿入されるのは <Tab>(accept)のときだけ。
        list = { selection = { preselect = false, auto_insert = false } },
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
      -- 組み込みの <Tab>(show_and_insert_or_accept_single)は内部で initial_selected_item_idx=1
      -- する=複数候補でも先頭(最長一致)を勝手に挿入してしまう。それを避けつつ
      -- 「候補1件は確定」「複数なら初回は一覧表示だけ、2回目以降は上から順に挿入」する:
      --   メニュー非表示     → show。1件なら確定 / 複数なら未選択のまま一覧表示。
      --   表示中で1件       → その1件を確定。
      --   表示中で複数     → 次候補を選択し、コマンドラインへ preview 挿入。
      -- 常に true を返し fallback しない。blink の cmdline source は getcompletion 由来で
      -- native Tab に落としても得るものが無く、むしろ最長一致挿入が復活するため。
      cmdline = {
        keymap = {
          preset = "cmdline",
          ["<Tab>"] = {
            function(cmp)
              if cmp.is_menu_visible() then
                if #cmp.get_items() == 1 then
                  return cmp.accept({ index = 1 })
                end
                return cmp.select_next({ auto_insert = true })
              end
              -- メニュー非表示: 1件なら確定、複数なら一覧表示だけに留める。
              cmp.show({
                callback = function()
                  if #cmp.get_items() == 1 then
                    cmp.accept({ index = 1 })
                  end
                end,
              })
              return true
            end,
          },
          ["<Down>"] = { "select_next", "fallback" },
          ["<Up>"] = { "select_prev", "fallback" },
        },
        completion = {
          -- preselect=false: メニュー表示直後は何も選択しない(=挿入もしない)
          -- auto_insert=false: <Up>/<Down> は menu 内のハイライト移動のみ。
          --                    <Tab> だけ select_next の呼び出し時に true を指定し、preview 挿入する。
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
