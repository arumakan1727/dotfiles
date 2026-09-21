-- Astro: astro-ls(volar ベース)。TS 機能には init_options.typescript.tsdk(typescript の lib ディレクトリ)が
-- 必須で、無いと "typescript.tsdk init option is required" で起動に失敗する。
-- nvim-lspconfig 既定はプロジェクトの node_modules/typescript/lib しか探さないので、見つからない場合は
-- mise の global typescript(config.toml の "npm:typescript")へフォールバックする。
-- tsgo(TS7 ネイティブ)は lib/typescript.js を持たないため tsdk には使えない。

local util = require("lspconfig.util")

--- tsc の実体パスから、それを含む node_modules/typescript/lib を上方向に探す。
--- mise npm backend は `<install>/node_modules/.bin/tsc`(sh の shim)+ `<install>/node_modules/typescript` の
--- 配置なので、tsc の親ディレクトリから node_modules を遡れば SDK に当たる。
---@param tsc string|nil
---@return string|nil
local function tsdk_from_tsc(tsc)
  if tsc == nil or tsc == "" then
    return nil
  end
  tsc = vim.uv.fs_realpath(tsc) or tsc
  local tsdk = util.get_typescript_server_path(vim.fs.dirname(tsc))
  return tsdk ~= "" and tsdk or nil
end

--- global(mise)の typescript SDK を探す。
--- mise activate 済みなら PATH の tsc が実体を指す。shims 経由(非対話 shell 等)だと realpath が
--- mise 本体になり SDK に辿れないので、その場合は `mise which tsc` で実体を引く。
---@return string|nil
local function global_tsdk()
  local tsdk = tsdk_from_tsc(vim.fn.exepath("tsc"))
  if tsdk then
    return tsdk
  end
  if vim.fn.executable("mise") == 1 then
    local res = vim.system({ "mise", "which", "tsc" }, { text = true }):wait()
    if res.code == 0 then
      return tsdk_from_tsc(vim.trim(res.stdout))
    end
  end
  return nil
end

return {
  before_init = function(_, config)
    local ts = config.init_options and config.init_options.typescript
    if not ts or (ts.tsdk and ts.tsdk ~= "") then
      return
    end
    local tsdk = util.get_typescript_server_path(config.root_dir)
    if tsdk == "" then
      tsdk = global_tsdk()
    end
    if tsdk then
      ts.tsdk = tsdk
    else
      vim.notify(
        "astro-ls: typescript SDK が見つかりません(プロジェクトの node_modules/typescript か mise の npm:typescript が必要)",
        vim.log.levels.WARN
      )
    end
  end,
}
