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

--- cwd から上位ディレクトリを辿り、`dirname` という名前のディレクトリを探す。
---@param cwd string
---@param dirname string
---@return string|nil
function M.find_dir_in_ancestors(cwd, dirname)
  local found = vim.fs.find(dirname, { path = cwd, upward = true, type = "directory" })[1]
  return found
end

--- C/C++ の `include/` 配下のヘッダを fuzzy 選択して `#include <...>` を挿入する。
--- (旧 telescope 版を snacks.picker へ移植)
function M.cpp_include_picker()
  local ft = vim.bo.filetype
  if ft ~= "c" and ft ~= "cpp" then
    vim.notify("Current buffer is not a C/C++ file.", vim.log.levels.ERROR)
    return
  end

  local cwd = uv.cwd()
  local headers_dir = M.find_dir_in_ancestors(cwd, "include")
  if headers_dir == nil then
    vim.notify("Cannot find `include/` in ancestors.", vim.log.levels.ERROR)
    return
  end

  -- `-printf` は GNU find 専用で macOS の BSD find では使えないため避ける。
  -- 絶対パスで列挙し、headers_dir prefix を Lua 側で剥がして相対パス化する。
  local out = vim.fn.systemlist({
    "find",
    "-L",
    headers_dir,
    "-type",
    "f",
    "(",
    "-name",
    "*.hpp",
    "-o",
    "-name",
    "*.h",
    ")",
  })
  if vim.v.shell_error ~= 0 or #out == 0 then
    vim.notify("No header files found under " .. headers_dir, vim.log.levels.WARN)
    return
  end
  local prefix = headers_dir:gsub("/*$", "") .. "/"
  local files = vim.tbl_map(function(p)
    return (p:gsub("^" .. vim.pesc(prefix), ""))
  end, out)

  --- 先頭付近の #include 連続ブロックの直後の行番号を返す
  local function include_insert_line()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 30, false)
    for i, line in ipairs(lines) do
      if line:sub(1, #"#include") ~= "#include" then
        return i
      end
    end
    return 1
  end

  local items = {}
  for i, h in ipairs(files) do
    items[#items + 1] = { idx = i, text = h, header = h }
  end

  Snacks.picker.pick({
    source = "cpp_headers",
    title = "C/C++ headers (#include <...>)",
    items = items,
    format = function(item)
      return {
        { "#include <", "SnacksPickerComment" },
        { item.header, "SnacksPickerLabel" },
        { ">", "SnacksPickerComment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      local cursor = vim.api.nvim_win_get_cursor(0)
      local linenr = include_insert_line()
      vim.api.nvim_win_set_cursor(0, { linenr, 0 })
      vim.api.nvim_put({ "#include <" .. item.header .. ">" }, "l", false, false)
      vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor[2] })
    end,
  })
end

return M
