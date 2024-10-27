-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.default_prog = {'/usr/bin/fish'}
config.color_scheme = 'Dracula (Official)'
config.font = wezterm.font("CaskaydiaCove Nerd Font")
config.enable_tab_bar = false
config.max_fps = 75
config.term = "wezterm"
-- and finally, return the configuration to wezterm
return config
