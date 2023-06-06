local colorscheme = "darkplus"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  return
end

-- function colorme(color) 
--     color = color or "dark-plus"
--     vim.cmd.colorscheme(color)
--     
--     vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--     vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- 
-- end
-- 
-- colorme()
