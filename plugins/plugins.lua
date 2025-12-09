-- Load utilities (provides Windows global for platform detection)
require("lib.lib")
-- Load plugin manager
local plugin_manager = require("lib.plugin_manager")

-- Initialize and load all plugins
plugin_manager.setup({
	plugins_dir = "plugins",
	auto_load = true,
	-- enabled_plugins = {}, -- empty means all plugins are enabled
	-- disabled_plugins = {}, -- list plugins to disable
})

-- Get all loaded themes for easy access
Themes = plugin_manager.get_themes()

-- Get all plugin modules for advanced usage
PluginManager = plugin_manager
Plugins = plugin_manager.get_plugin_modules()
