local function lsp_names()
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  if #clients == 0 then
    return ""
  end
  local names = vim.tbl_map(function(c)
    return c.name
  end, clients)
  return "  " .. table.concat(names, ",")
end

return {
  -- statusline(グローバル)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true, -- laststatus=3
        disabled_filetypes = { statusline = { "snacks_dashboard" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          { "diagnostics", sources = { "nvim_lsp" } },
          { "filename", path = 1 },
        },
        lualine_x = {
          { lsp_names, color = { fg = "#60c3c0" } },
          "encoding",
          "fileformat",
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "lazy", "oil", "quickfix", "trouble" },
    },
  },

  -- tabline(buffer 一覧)は mini.tabline を使用(plugins/mini.lua で setup)。
  -- bufferline は約1.5年メンテ停滞のため、現役メンテの mini.nvim へ集約した。

  -- breadcrumbs / winbar(navic + navbuddy + barbecue を1本に置換)
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      {
        "<Leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "Pick breadcrumb (dropbar)",
      },
    },
  },
}
