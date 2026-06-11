vim.filetype.add({
  extension = {
    bnf = "ebnf",
    ebnf = "ebnf",
    envrc = "sh",
    dig = "yaml",

    ---@param path string
    ---@param bufnr integer
    sample = function(path, bufnr)
      return vim.filetype.match({ buf = bufnr, filename = path:gsub("%.sample$", "") })
    end,
  },
  filename = {
    [".envrc"] = "sh",
    [".flake8"] = "cfg",
  },
  pattern = {
    ["%.env%..*"] = "sh",
  },
})
