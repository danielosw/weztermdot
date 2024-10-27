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
function getdefualt()
	if Iswindows() then
	    return "pwsh"
	else
	    return "/usr/bin/fish"
	end
end
Defualt = getdefualt()
config.launch_menu = {
  {
    -- Optional label to show in the launcher. If omitted, a label
    -- is derived from the `args`
    label = 'Fish',
    -- The argument array to spawn.  If omitted the default program
    -- will be used as described in the documentation above
    args = { '/usr/bin/fish' },

    -- You can specify an alternative current working directory;
    -- if you don't specify one then a default based on the OSC 7
    -- escape sequence will be used (see the Shell Integration
    -- docs), falling back to the home directory.
    -- cwd = "/some/path"

    -- You can override environment variables just for this command
    -- by setting this here.  It has the same semantics as the main
    -- set_environment_variables configuration option described above
    -- set_environment_variables = { FOO = "bar" },
  },
  {label = 'Powershell',
  args =  {'pwsh'},
  },
  {
    label = 'Cycle server',
    args = {Defualt, '-c ssh d932v894@cycle3.eecs.ku.edu'}
  }

}
config.term = "wezterm"

-- and finally, return the configuration to wezterm
return config
