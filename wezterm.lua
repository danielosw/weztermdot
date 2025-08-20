-- Pull in the Wezterm API
Wezterm = require("wezterm")
-- This will hold the configuration.
config = Wezterm.config_builder()
require("lib.lib")
require("plugins.plugins")
if Windows then
	config.default_prog = { "pwsh" }
else
	config.default_prog = { "/usr/bin/fish" }
end

config.color_scheme = "Dracula (Official)"
-- put custom font logic here
local function getFont()
	return "CaskaydiaCove NF"
end
config.window_background_opacity = 1
config.font = Wezterm.font_with_fallback({ getFont() })
config.harfbuzz_features = {
	"calt",
	"case",
	"ccmp",
	"fina",
	"init",
	"rclt",
	"rlig",
	"ss02",
	"ss19",
	"ss20",
	"zero",
	"mark",
	"mkmk",
}
config.enable_tab_bar = true
if Windows then
	config.max_fps = 60
else
	config.max_fps = 75
end
local function getdefualt()
	if Windows then
		return "pwsh"
	else
		return "/usr/bin/fish"
	end
end

Default = getdefualt()
local function getlaunch()
	local launches = {}
	if Windows then
		launches[#launches + 1] = {
			label = "Powershell",
			args = { "pwsh" },
		}
		launches[#launches + 1] = {
			label = "Debian",
			args = { "wsl -d debian" },
		}
	else
		launches[#launches + 1] = {
			-- Optional label to show in the launcher. If omitted, a label
			-- is derived from the `args`
			label = "Fish",
			-- The argument array to spawn.  If omitted the default program
			-- will be used as described in the documentation above
			args = { "/usr/bin/fish" },

			-- You can specify an alternative current working directory;
			-- if you don't specify one then a default based on the OSC 7
			-- escape sequence will be used (see the Shell Integration
			-- docs), falling back to the home directory.
			-- cwd = "/some/path"

			-- You can override environment variables just for this command
			-- by setting this here.  It has the same semantics as the main
			-- set_environment_variables configuration option described above
			-- set_environment_variables = { FOO = "bar" },
		}
	end
	return launches
end
config.launch_menu = getlaunch()
config.term = "wezterm"
config.hyperlink_rules = Wezterm.default_hyperlink_rules() -- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/Wezterm | "wez/Wezterm.git" )
-- as long as a full url hyperlink regex exists above this it should not match a full url to
-- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
-- and finally, return the configuration to Wezterm
return config
