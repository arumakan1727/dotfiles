-- TypeScript: deno プロジェクト(deno.json(c) あり)では起動しない(denols と排他)。
return {
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then
      return
    end
    if vim.fs.root(fname, { "deno.json", "deno.jsonc" }) then
      return
    end
    local root = vim.fs.root(fname, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
    if root then
      on_dir(root)
    end
  end,
}
