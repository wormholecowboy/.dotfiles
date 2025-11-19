-- Neovim Lua Configuration - luacheck settings

-- Recognize Neovim globals
globals = {
	"vim",
}

-- Ignore certain warnings
ignore = {
	"212", -- Unused argument (common in plugin callbacks)
	"213", -- Unused loop variable
}

-- Check specific directories
include_files = {
	"lua/**/*.lua",
	"init.lua",
}

-- Exclude directories
exclude_files = {
	"lua/plugins/**/vendor/**",
}

-- Set max line length (optional, match your style)
max_line_length = false

-- Allow defining functions inside loops (common in Neovim config)
allow_defined_top = true
