# Plugin Management System - Usage Examples

This document provides practical examples of using the plugin management system.

## Basic Usage

### Default Configuration (Load All Plugins)

In `plugins/plugins.lua`:
```lua
local plugin_manager = require("lib.plugin_manager")

-- Load all plugins automatically
plugin_manager.setup({
    plugins_dir = "plugins",
    auto_load = true,
})

-- Access loaded plugins
Themes = plugin_manager.get_themes()
PluginManager = plugin_manager
Plugins = plugin_manager.get_plugin_modules()
```

In `wezterm.lua`:
```lua
-- Use a theme from loaded plugins
config.colors = Themes["cyberdream"]

-- Or access a specific plugin
local cyberdream = PluginManager.get_plugin("cyberdream")
if cyberdream then
    config.colors = cyberdream.get_dark()
end
```

## Selective Plugin Loading

### Load Only Specific Plugins

```lua
plugin_manager.setup({
    plugins_dir = "plugins",
    auto_load = true,
    enabled_plugins = { "cyberdream", "example-plugin" },
})
```

### Disable Specific Plugins

```lua
plugin_manager.setup({
    plugins_dir = "plugins",
    auto_load = true,
    disabled_plugins = { "example-plugin" },
})
```

## Platform-Specific Configuration

### Disable Plugins on Specific Platforms

```lua
local disabled = {}

-- Disable certain plugins on Windows
if Windows then
    table.insert(disabled, "unix-specific-plugin")
end

-- Disable certain plugins on Unix
if not Windows then
    table.insert(disabled, "windows-specific-plugin")
end

plugin_manager.setup({
    disabled_plugins = disabled,
})
```

## Working with Themes

### Use a Theme Plugin

```lua
-- Get all themes
local themes = PluginManager.get_themes()

-- Apply a theme
config.colors = themes["cyberdream"]

-- Or use the plugin directly
local cyberdream = PluginManager.get_plugin("cyberdream")
config.colors = cyberdream  -- Uses default (dark) variant
```

### Switch Between Theme Variants

```lua
local cyberdream = PluginManager.get_plugin("cyberdream")
if cyberdream then
    -- Use dark variant
    config.colors = cyberdream.get_dark()
    
    -- Or use light variant
    -- config.colors = cyberdream.get_light()
end
```

### Dynamic Theme Switching

```lua
local function get_theme_for_time()
    local hour = os.date("*t").hour
    local cyberdream = PluginManager.get_plugin("cyberdream")
    
    if cyberdream then
        if hour >= 6 and hour < 18 then
            return cyberdream.get_light()
        else
            return cyberdream.get_dark()
        end
    end
    
    return nil
end

config.colors = get_theme_for_time()
```

## Working with Utility Plugins

### Access Plugin Functions

```lua
local example = PluginManager.get_plugin("example-plugin")
if example then
    print(example.greet("User"))
    
    local info = example.get_info()
    print("Plugin: " .. info.name .. " v" .. info.version)
end
```

### Configure a Plugin After Loading

```lua
plugin_manager.setup({ auto_load = true })

-- Get and reconfigure a plugin
local example = PluginManager.get_plugin("example-plugin")
if example then
    example.setup({
        greeting = "Custom greeting!",
        enabled = true,
    })
end
```

## Manual Plugin Loading

### Load Plugins Manually

```lua
-- Don't auto-load
plugin_manager.setup({
    auto_load = false,
})

-- Discover available plugins
local available = plugin_manager.discover_plugins()
print("Found " .. #available .. " plugins")

-- Load plugins manually
plugin_manager.load_plugins()
```

### Load Specific Plugin Manually

```lua
-- This requires modifying the plugin manager or loading directly
local my_plugin = require("plugins.my-plugin.init")
my_plugin.setup()
```

## Checking Plugin Status

### List All Loaded Plugins

```lua
local loaded = PluginManager.get_loaded_plugins()

for name, plugin in pairs(loaded) do
    if plugin.loaded then
        print("✓ " .. name .. " (v" .. plugin.metadata.version .. ")")
    else
        print("✗ " .. name .. " - Error: " .. (plugin.error or "unknown"))
    end
end
```

### Check if a Plugin is Loaded

```lua
local plugin = PluginManager.get_plugin("cyberdream")
if plugin and plugin.loaded then
    print("Cyberdream is loaded and ready")
    config.colors = plugin
else
    print("Cyberdream is not available")
    -- Fallback to built-in theme
    config.color_scheme = "Dracula (Official)"
end
```

## Advanced Usage

### Plugin with Custom Configuration

Create a plugin configuration file:

```lua
-- plugins/my-plugin-config.lua
return {
    my_plugin = {
        enabled = true,
        custom_option = "value",
    },
    another_plugin = {
        enabled = false,
    },
}
```

Use it in plugins.lua:

```lua
local plugin_manager = require("lib.plugin_manager")
local plugin_config = require("plugins.my-plugin-config")

plugin_manager.setup({ auto_load = true })

-- Apply custom configurations
for plugin_name, config in pairs(plugin_config) do
    local plugin = plugin_manager.get_plugin(plugin_name)
    if plugin and plugin.module and plugin.module.setup then
        plugin.module.setup(config)
    end
end
```

### Conditional Plugin Features

```lua
local plugin = PluginManager.get_plugin("example-plugin")
if plugin and plugin.metadata.version >= "2.0.0" then
    -- Use new features
    plugin.new_feature()
else
    -- Use old features or fallback
    if plugin then
        plugin.old_feature()
    end
end
```

### Accessing Plugin Modules

```lua
-- Get all plugin modules
local all_plugins = PluginManager.get_plugin_modules()

for name, module in pairs(all_plugins) do
    print("Plugin: " .. name)
    
    -- Check if module has specific functions
    if type(module) == "table" then
        if module.setup then
            print("  - has setup()")
        end
        if module.config then
            print("  - has config")
        end
    end
end
```

## Error Handling

### Safe Plugin Access

```lua
local function safely_use_plugin(plugin_name, callback)
    local plugin = PluginManager.get_plugin(plugin_name)
    
    if not plugin then
        print("Plugin '" .. plugin_name .. "' not found")
        return nil
    end
    
    if not plugin.loaded then
        print("Plugin '" .. plugin_name .. "' failed to load: " .. (plugin.error or "unknown error"))
        return nil
    end
    
    return callback(plugin)
end

-- Usage
safely_use_plugin("cyberdream", function(plugin)
    config.colors = plugin
end)
```

### Fallback Configuration

```lua
-- Try to use plugin theme, fallback to built-in
local function apply_theme()
    local themes = PluginManager.get_themes()
    
    if themes["cyberdream"] then
        config.colors = themes["cyberdream"]
        print("Using cyberdream theme")
    elseif themes["example-theme"] then
        config.colors = themes["example-theme"]
        print("Using example-theme")
    else
        config.color_scheme = "Dracula (Official)"
        print("Using built-in Dracula theme")
    end
end

apply_theme()
```

## Performance Optimization

### Lazy Loading Plugins

```lua
-- Don't auto-load all plugins
plugin_manager.setup({
    auto_load = false,
})

-- Load only what you need
plugin_manager.setup({
    enabled_plugins = { "cyberdream" },
    auto_load = true,
})
```

### Cache Plugin References

```lua
-- Cache frequently accessed plugins
local CACHED_PLUGINS = {}

local function get_cached_plugin(name)
    if not CACHED_PLUGINS[name] then
        CACHED_PLUGINS[name] = PluginManager.get_plugin(name)
    end
    return CACHED_PLUGINS[name]
end

-- Use cached reference
config.colors = get_cached_plugin("cyberdream")
```

## Debugging

### Enable Debug Output

```lua
-- In your plugin's setup:
function M.setup(opts)
    opts = opts or {}
    
    if opts.debug then
        M.debug = true
        print("Debug mode enabled for " .. M.name)
    end
    
    return M
end

-- Enable debug when loading
local plugin = PluginManager.get_plugin("my-plugin")
if plugin and plugin.module then
    plugin.module.setup({ debug = true })
end
```

### Check Plugin Load Errors

```lua
local loaded = PluginManager.get_loaded_plugins()

print("=== Plugin Load Status ===")
for name, plugin in pairs(loaded) do
    print(name .. ":")
    print("  Loaded: " .. tostring(plugin.loaded))
    if plugin.error then
        print("  Error: " .. plugin.error)
    end
    if plugin.metadata.version then
        print("  Version: " .. plugin.metadata.version)
    end
end
```

## Integration with WezTerm Features

### Use Plugin for Key Bindings

```lua
-- In your plugin:
function M.get_keybinds()
    return {
        { key = "t", mods = "CTRL", action = wezterm.action.SpawnTab("DefaultDomain") },
        { key = "w", mods = "CTRL", action = wezterm.action.CloseCurrentTab{ confirm = true } },
    }
end

-- In wezterm.lua:
local my_plugin = PluginManager.get_plugin("my-plugin")
if my_plugin and my_plugin.get_keybinds then
    config.keys = my_plugin.get_keybinds()
end
```

### Use Plugin for Status Bar

```lua
-- In your plugin:
function M.get_status_bar(window, pane)
    return "Custom Status: " .. os.date("%H:%M")
end

-- In wezterm.lua:
wezterm.on("update-right-status", function(window, pane)
    local status_plugin = PluginManager.get_plugin("status-plugin")
    if status_plugin and status_plugin.get_status_bar then
        window:set_right_status(status_plugin.get_status_bar(window, pane))
    end
end)
```

## Testing Plugins

### Simple Plugin Test

Create a test file:

```lua
-- test_plugins.lua
package.path = package.path .. ";./lib/?.lua;./plugins/?.lua"

-- Mock Windows detection
Windows = false

-- Load plugin manager
local plugin_manager = require("lib.plugin_manager")

-- Setup and load
plugin_manager.setup({
    auto_load = true,
})

-- Test results
print("\n=== Test Results ===")
print("Available plugins: " .. #plugin_manager.get_available_plugins())
print("Loaded plugins: " .. vim.tbl_count(plugin_manager.get_loaded_plugins()))

local themes = plugin_manager.get_themes()
print("Themes found: " .. vim.tbl_count(themes))

for name, theme in pairs(themes) do
    print("  - " .. name)
end
```

Run with: `lua test_plugins.lua`

## Complete Example Configuration

Here's a complete example of `wezterm.lua` using the plugin system:

```lua
-- Pull in the WezTerm API
local wezterm = require("wezterm")
Wezterm = wezterm

-- Configuration builder
local config = wezterm.config_builder()

-- Load utilities and plugins
require("lib.lib")
require("plugins.plugins")

-- Platform-specific configuration
if Windows then
    config.default_prog = { "pwsh" }
    config.max_fps = 60
else
    config.term = "wezterm"
    config.default_prog = { "/usr/bin/fish" }
    config.max_fps = 75
end

-- Apply theme from plugin
local themes = PluginManager.get_themes()
if themes["cyberdream"] then
    config.colors = themes["cyberdream"]
else
    config.color_scheme = "Dracula (Official)"
end

-- Font configuration
config.font = wezterm.font_with_fallback({ "CaskaydiaCove NF" })
config.harfbuzz_features = { "calt", "case", "ccmp", "fina", "init", "rclt", "rlig", "ss02", "ss19", "ss20", "zero", "mark", "mkmk" }

-- Window configuration
config.window_background_opacity = 1
config.enable_tab_bar = true

-- Return configuration
return config
```
