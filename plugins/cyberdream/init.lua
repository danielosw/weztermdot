-- Cyberdream Theme Plugin for WezTerm
-- A modern, dark colorscheme with vibrant colors

local M = {}

-- Plugin metadata
M.name = "cyberdream"
M.version = "1.0.0"
M.description = "Cyberdream theme for WezTerm - a modern dark colorscheme"
M.author = "danielosw"
M.type = "theme"
M.dependencies = {}

-- Load theme variants
M.dark = require("plugins.cyberdream.cyberdream")
M.light = require("plugins.cyberdream.cyberdream-light")

-- Default to dark theme
M.foreground = M.dark.foreground
M.background = M.dark.background
M.cursor_bg = M.dark.cursor_bg
M.cursor_fg = M.dark.cursor_fg
M.cursor_border = M.dark.cursor_border
M.selection_fg = M.dark.selection_fg
M.selection_bg = M.dark.selection_bg
M.scrollbar_thumb = M.dark.scrollbar_thumb
M.split = M.dark.split
M.ansi = M.dark.ansi
M.brights = M.dark.brights
M.indexed = M.dark.indexed

-- Setup function (called when plugin is loaded)
function M.setup(opts)
    opts = opts or {}
    
    -- Allow switching between light and dark variants
    if opts.variant == "light" then
        for key, value in pairs(M.light) do
            M[key] = value
        end
    end
    
    return M
end

-- Helper function to get the dark variant
function M.get_dark()
    return M.dark
end

-- Helper function to get the light variant
function M.get_light()
    return M.light
end

return M
