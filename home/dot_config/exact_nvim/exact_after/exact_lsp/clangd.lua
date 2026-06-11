-- clangd は mise ではなく system(Xcode/LLVM)を使う。競プロ向けに補完を強めに。
return {
  cmd = {
    "clangd",
    "--background-index",
    "--all-scopes-completion",
    "--header-insertion-decorators",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--clang-tidy",
    "-j=4",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
}
