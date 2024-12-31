-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
config = wezterm.config_builder()
function Iswindows()
	return string.find(wezterm.target_triple, "windows") ~= nil
end

local windows = Iswindows()
if windows then
	config.default_prog = { "pwsh" }
else
	config.default_prog = { "/usr/bin/fish" }
end
config.color_scheme = "Dracula (Official)"
-- put custom font logic here
local function getFont()
	return "CaskaydiaCove NF"
end

config.font = wezterm.font_with_fallback({ getFont() })
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
if windows then
	config.max_fps = 60
else
	config.max_fps = 75
end
local function getdefualt()
	if windows then
		return "pwsh"
	else
		return "/usr/bin/fish"
	end
end

Default = getdefualt()
config.launch_menu = {
	{
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
	},
	{
		label = "Powershell",
		args = { "pwsh" },
	},
}
config.term = "wezterm"
config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- make username/project paths clickable. this implies paths like the following are for github.
-- ( "nvim-treesitter/nvim-treesitter" | wbthomason/packer.nvim | wez/wezterm | "wez/wezterm.git" )
-- as long as a full url hyperlink regex exists above this it should not match a full url to
-- github or gitlab / bitbucket (i.e. https://gitlab.com/user/project.git is still a whole clickable url)
table.insert(config.hyperlink_rules, {
	regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
	format = "https://www.github.com/$1/$3",
})
-- load plugins
require("plugins.plugins")
-- and finally, return the configuration to wezterm
return config
