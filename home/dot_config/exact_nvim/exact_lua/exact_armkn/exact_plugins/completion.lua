-- cmdline 補完で「最初の <Tab> で全候補の共通 prefix まで挿入」するためのヘルパ。
-- blink には共通 prefix 挿入の組み込みが無い(show_and_insert_or_accept_single は先頭候補を
-- 丸ごと挿入するだけ)ので、候補の textEdit.newText から最長共通 prefix を自前で求める。

--- マルチバイト安全に「文字単位」の最長共通 prefix を返す。
local function char_common_prefix(strs)
  local first = vim.fn.split(strs[1], "\\zs") -- 1文字ずつ(UTF-8 境界で分割)
  local n = #first
  for i = 2, #strs do
    local cur = vim.fn.split(strs[i], "\\zs")
    local lim = math.min(n, #cur)
    local k = 0
    while k < lim and first[k + 1] == cur[k + 1] do
      k = k + 1
    end
    n = k
    if n == 0 then break end
  end
  return table.concat(first, "", 1, n)
end

--- 表示中の cmdline 候補(複数)の共通 prefix を、現在のコマンドラインのカーソル位置へ追記する。
--- 既に共通 prefix まで入力済み / 構造が想定外なら false(何もしない)。
--- 手前は削らず suffix を追記するだけなので、想定とズレても破壊しない安全側設計。
local function cmdline_insert_common_prefix(cmp)
  local items = cmp.get_items()
  if #items < 2 then return false end

  local texts = {}
  for _, it in ipairs(items) do
    local nt = it.textEdit and it.textEdit.newText -- 実際に挿入されるテキスト(file は full path)
    if not nt then return false end
    texts[#texts + 1] = nt
  end

  local lcp = char_common_prefix(texts)
  if lcp == "" then return false end

  -- 全 item 同一の挿入開始位置(start_pos = byte offset)。これより手前は触らない。
  local te = items[1].textEdit
  local s = te.insert and te.insert.start and te.insert.start.character
  if not s then return false end

  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos() - 1 -- カーソルの byte 位置(0-based)
  local typed = line:sub(s + 1, pos) -- その引数として現在入力済みの文字列
  -- typed が lcp の接頭辞でない(=想定とズレ)なら安全側に倒して何もしない。
  if lcp:sub(1, #typed) ~= typed then return false end

  local suffix = lcp:sub(#typed + 1)
  if suffix == "" then return false end -- 既に共通 prefix まで入っている

  local new = line:sub(1, pos) .. suffix .. line:sub(pos + 1)
  vim.fn.setcmdline(new, pos + #suffix + 1)
  return true
end

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
      -- 「候補1件は確定」「複数なら共通 prefix まで挿入(シェル風)」を両立させるためカスタム関数にする:
      --   メニュー非表示       → show。1件なら preselect せず確定 / 複数なら共通 prefix を挿入して一覧表示。
      --   表示中・選択あり     → その候補を確定(Up/Down で選んでから <Tab>)。
      --   表示中・未選択で1件   → その1件を確定。
      --   表示中・未選択で複数   → Tab を消費して何もしない(最長一致の自動挿入をさせない)。
      -- 常に true を返し fallback しない。blink の cmdline source は getcompletion 由来で
      -- native Tab に落としても得るものが無く、むしろ最長一致挿入が復活するため。
      -- (`path/` 確定→メニューが閉じ、次の <Tab> で `path/` 配下を出す流れは従来どおり成立)
      cmdline = {
        keymap = {
          preset = "cmdline",
          ["<Tab>"] = {
            function(cmp)
              if cmp.is_menu_visible() then
                if cmp.get_selected_item() ~= nil then return cmp.accept() end -- 選択中を確定
                if #cmp.get_items() == 1 then return cmp.accept({ index = 1 }) end -- 単一候補は未選択でも確定
                cmdline_insert_common_prefix(cmp) -- 複数候補・未選択: 伸ばせる分だけ共通 prefix を挿入
                return true -- それ以上は挿入しない(候補確定は Up/Down で選んでから)
              end
              -- メニュー非表示: 表示し、結果に応じて
              --   1件 → そのまま確定 / 複数 → 共通 prefix まで挿入(メニューは出たまま・未選択)
              cmp.show({
                callback = function()
                  if #cmp.get_items() == 1 then
                    cmp.accept({ index = 1 })
                  else
                    cmdline_insert_common_prefix(cmp)
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
