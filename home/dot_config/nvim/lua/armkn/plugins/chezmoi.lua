-- chezmoi 管理の dotfiles(dot_zshrc 等)を nvim から編集・自動 apply する。
--
-- 注意: README / LazyVim extra は監視パターンを `~/.local/share/chezmoi/*` に決め打ちしているが、
-- ここの source は `~/ghq/.../dotfiles/home`(.chezmoiroot=home)なので決め打ちは効かない。
-- `chezmoi source-path`(=.chezmoiroot を解決した source root)から動的に導出する。
--
-- ワークフロー:
--   - source ファイル(home/dot_zshrc 等)を開いて保存 → 自動 apply で live な $HOME へ反映
--   - <Leader>cz で managed ファイルを fuzzy 選択して開く
--   - :ChezmoiEdit <target> / :ChezmoiList も使える

-- source ファイルの chezmoi prefix/suffix を剥がして filetype を補正する。
-- (例: dot_zshrc → .zshrc → zsh、private_dot_config/nvim/init.lua の basename init.lua → lua)
local function fix_chezmoi_filetype(bufnr, path)
  local base = vim.fs.basename(path)
  base = base:gsub("%.tmpl$", "")
  base = base
    :gsub("^encrypted_", "")
    :gsub("^private_", "")
    :gsub("^readonly_", "")
    :gsub("^executable_", "")
    :gsub("^symlink_", "")
    :gsub("^literal_", "")
  base = base:gsub("^dot_", ".")
  local ft = vim.filetype.match({ filename = base, buf = bufnr })
  if ft and ft ~= "" then
    vim.bo[bufnr].filetype = ft
  end
end

return {
  "xvzc/chezmoi.nvim",
  commit = "4167bbec76f693f481a5243f1be521ff0ccf1a6d", -- tag/release が無いので SHA 固定
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "ChezmoiEdit", "ChezmoiList" },
  -- stylua: ignore
  keys = {
    { "<Leader>cz", function() require("chezmoi.pick").snacks() end, desc = "Chezmoi: pick managed file" },
  },
  init = function()
    -- source root を非同期取得(.chezmoiroot を尊重)。取得後に監視 autocmd を張る。
    vim.system({ "chezmoi", "source-path" }, { text = true }, function(res)
      if res.code ~= 0 then
        return
      end
      local src = vim.trim(res.stdout or "")
      if src == "" then
        return
      end
      vim.schedule(function()
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
          group = vim.api.nvim_create_augroup("armkn_chezmoi", { clear = true }),
          pattern = src .. "/*",
          callback = function(ev)
            -- chezmoi の制御ファイルは触らない
            local name = vim.fs.basename(ev.file)
            if vim.startswith(name, ".chezmoi") then
              return
            end
            fix_chezmoi_filetype(ev.buf, ev.file)
            -- 保存時に自動 apply(内部 module だが README 公認の経路)
            pcall(function()
              require("chezmoi.commands.__edit").watch(ev.buf)
            end)
          end,
        })
      end)
    end)
  end,
  config = function()
    require("chezmoi").setup({
      edit = { watch = false, force = false },
    })
  end,
}
