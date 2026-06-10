-- Deno: deno.json(c) があるディレクトリでのみ起動(ts_ls とは排他。ts_ls.lua 側で deno を除外)
return {
  root_markers = { "deno.json", "deno.jsonc" },
  single_file_support = false,
  settings = {
    deno = {
      enable = true,
      lint = true,
      unstable = true,
    },
  },
}
