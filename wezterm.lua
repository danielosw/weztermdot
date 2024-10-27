-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
function Iswindows()
	if package.config:sub(1, 1) == "\\" then
		return true
	else
		return false
	end
end
if Iswindows() then
    config.default_prog = {'pwsh'}
else
    config.default_prog = {'/usr/bin/fish'}
end
config.color_scheme = 'Dracula (Official)'
config.font = wezterm.font("CaskaydiaCove Nerd Font")
config.enable_tab_bar = true
if Iswindows() then
    config.max_fps = 60
else
    config.max_fps = 75
end
config.term = "wezterm"

-- and finally, return the configuration to wezterm
return config
