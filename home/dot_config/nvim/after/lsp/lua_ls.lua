-- workspace.library は lazydev.nvim が動的に面倒を見るので手動設定しない。
return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
      codeLens = { enable = true },
      hint = { enable = true }, -- inlay hint
      diagnostics = { globals = { "vim", "Snacks" } },
    },
  },
}
