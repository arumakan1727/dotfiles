local M = {}

local uv = vim.uv or vim.loop

--- カレントバッファのプロジェクトルートを推定する(0.10+ の vim.fs.root)。
--- 見つからなければ cwd を返す。
---@return string
function M.get_root()
  local buf = vim.api.nvim_get_current_buf()
  local root = vim.fs.root(buf, {
    ".git",
    "Makefile",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "pyproject.toml",
    "deno.json",
  })
  return root or uv.cwd()
end

return M
