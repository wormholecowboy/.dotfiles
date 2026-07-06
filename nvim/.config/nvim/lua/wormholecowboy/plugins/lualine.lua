local function get_current_buffer_path()
  local path = vim.fn.expand('%:p')
  if path == '' then
    return ''
  end
  -- Show only the last 5 path segments, prefixed with … when truncated
  local parts = vim.split(path, '/', { trimempty = true })
  local keep = 5
  if #parts <= keep then
    return path
  end
  local tail = vim.list_slice(parts, #parts - keep + 1, #parts)
  return '…/' .. table.concat(tail, '/')
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "codedark",
        component_separators = { left = "|", right = "|" },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true, -- matches vim.opt.laststatus = 3 in options.lua
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = {
          { 'mode', separator = { left = '', right = '' } }
        },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { get_current_buffer_path } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = {
          { 'location', separator = { left = '', right = '' } },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    })
  end,
}
