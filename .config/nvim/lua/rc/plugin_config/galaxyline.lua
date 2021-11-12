local gl = require('galaxyline')
local gls = gl.section
gl.short_line_list = {'LuaTree', 'NvimTree', 'vista', 'dbui'}

local colors = {
  bg = '#282c34',
  yellow = '#fabd2f',
  cyan = '#008080',
  darkblue = '#081633',
  green = '#a0c700',
  orange = '#FF8800',
  purple = '#082f4a',
  magenta = '#d16d9e',
  grey = '#c0c0c0',
  blue = '#0087d7',
  red = '#ec5f67'
}

local buffer_not_empty = function()
  if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then
    return true
  end
  return false
end

gls.left[1] = {
  Whitespace = {
    provider = function() return ' ' end,
    highlight = {colors.magenta, colors.darkblue}
  }
}
gls.left[3] ={
  FileIcon = {
    provider = 'FileIcon',
    condition = buffer_not_empty,
    highlight = {require('galaxyline.provider_fileinfo').get_file_icon_color,colors.darkblue},
  },
}
gls.left[4] = {
  FileName = {
    provider = function()
      local res =  vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.')
      if vim.bo.readonly then
        res = res .. '[RO]'
      end
      if vim.bo.modifiable and vim.bo.modified then
        res = res .. '*'
      end
      return res .. ' '
    end,
    condition = buffer_not_empty,
    separator_highlight = {colors.purple,colors.darkblue},
    highlight = {colors.grey, colors.darkblue}
  }
}

gls.left[6] = {
  GitBranch = {
    provider = 'GitBranch',
    icon = '   ',
    separator = ' ',
    condition = buffer_not_empty,
    highlight = {colors.orange,colors.bg},
    separator_highlight = {colors.orange,colors.bg},
  }
}

local checkwidth = function()
  local squeeze_width  = vim.fn.winwidth(0) / 2
  if squeeze_width > 40 then
    return true
  end
  return false
end

gls.left[7] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    icon = '  ',
    highlight = {colors.green,colors.purple},
  }
}
gls.left[8] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    icon = '  ',
    highlight = {colors.orange,colors.purple},
  }
}
gls.left[9] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    icon = '  ',
    highlight = {colors.red,colors.purple},
  }
}
gls.left[10] = {
  LspAreaLeftSpace = {
    provider = function() return ' ' end,
    highlight = {colors.green, colors.bg}
  }
}
gls.left[11] = {
  GetLspClient = {
    provider = 'GetLspClient',
    separator = ' ',
    separator_highlight = {colors.green,colors.bg},
    highlight = {colors.green, colors.bg}
  }
}
gls.left[12] = {
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red,colors.bg}
  }
}
gls.left[13] = {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.yellow,colors.bg},
  }
}

gls.right[1]= {
  FileFormat = {
    provider = 'FileTypeName',
    separator = ' ',
    separator_highlight = {colors.bg,colors.purple},
    highlight = {colors.grey,colors.purple},
  }
}
gls.right[2]= {
  FileFormat = {
    provider = 'FileFormat',
    separator = ' ',
    separator_highlight = {colors.bg,colors.purple},
    highlight = {colors.grey,colors.purple},
  }
}
gls.right[3]= {
  FileEncode = {
    provider = 'FileEncode',
    separator = ' |',
    separator_highlight = {colors.darkblue,colors.purple},
    highlight = {colors.grey,colors.purple},
  }
}
gls.right[4] = {
  LineInfo = {
    provider = 'LineColumn',
    separator = ' |',
    separator_highlight = {colors.darkblue,colors.purple},
    highlight = {colors.grey,colors.purple},
  },
}
gls.right[5] = {
  PerCent = {
    provider = 'LinePercent',
    separator = ' ',
    separator_highlight = {colors.darkblue,colors.purple},
    highlight = {colors.grey,colors.darkblue},
  }
}

gls.short_line_left[1] = {
  BufferType = {
    provider = 'FileTypeName',
    separator = ' ',
    separator_highlight = {colors.purple,colors.bg},
    highlight = {colors.grey,colors.purple}
  }
}


gls.short_line_right[1] = {
  BufferIcon = {
    provider= 'BufferIcon',
    -- separator = '',
    -- separator_highlight = {colors.purple,colors.bg},
    highlight = {colors.grey,colors.purple}
  }
}
gls.short_line_left[2] = {
  FileName = {
    provider = function()
      local res = vim.fn.fnamemodify(vim.fn.expand('%'), ':~:.')
      if vim.bo.readonly then
        res = res .. '[RO]'
      end
      if vim.bo.modifiable and vim.bo.modified then
        res = res .. '*'
      end
      return res .. ' '
    end,
    condition = buffer_not_empty,
    separator_highlight = {colors.purple,colors.darkblue},
    highlight = {colors.grey, colors.darkblue}
  }
}
