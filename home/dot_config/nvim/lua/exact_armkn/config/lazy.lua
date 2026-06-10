-- lazy.nvim を bootstrap する。
-- 供給網方針: floating な `--branch=stable` ではなく、人手レビュー済みの commit に固定する。
-- 更新時はこの SHA を意図的に上げてから `:Lazy restore` で同期する。
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local LAZY_COMMIT = "85c7ff3711b730b4030d03144f6db6375044ae82" -- v11.17.5

local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  vim.fn.system({ "git", "-C", lazypath, "checkout", "--detach", LAZY_COMMIT })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "armkn.plugins" } },
  defaults = { lazy = true }, -- 既定で遅延読み込み(各 spec の event/ft/keys/cmd で起こす)
  install = { colorscheme = { "tokyonight-moon", "habamax" } },

  -- 供給網方針: 自動更新しない。lazy-lock.json(commit SHA = content hash)を信頼の起点にする。
  -- 更新は `:Lazy update` → diff レビュー → lazy-lock.json を commit、復元は `:Lazy restore`。
  checker = { enabled = false },
  change_detection = { enabled = false },

  -- luarocks / packspec は非 git 成果物を引き込むため無効化し、依存を git-SHA に限定する
  rocks = { enabled = false },
  pkg = { enabled = false },

  ui = { border = "rounded" },

  performance = {
    cache = { enabled = true },
    rtp = {
      reset = true,
      -- builtin プラグインの無効化。netrw は oil.nvim / mini.files に置き換えるため切る。
      -- matchit / matchparen は安価で % の挙動に効くので残す。
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "tutor",
        "rplugin",
        "netrwPlugin",
      },
    },
  },
})

-- プラグイン管理 UI へのショートカット
vim.keymap.set("n", "<Leader>l", "<Cmd>Lazy<CR>", { desc = "Lazy" })
