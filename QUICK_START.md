# Plugin Management System - Quick Start Guide

Get started with the WezTerm plugin management system in 5 minutes.

## What is the Plugin System?

A simple, automatic plugin loader that discovers and manages WezTerm configuration plugins. No manual `require()` statements needed!

## How It Works

1. **Drop plugins into `plugins/` directory**
2. **Plugin manager auto-discovers them**
3. **Use them in your config**

That's it!

## Quick Examples

### 1. Using an Existing Theme Plugin

```lua
-- In wezterm.lua
config.colors = Themes["cyberdream"]
```

The `cyberdream` theme is already included and auto-loaded!

### 2. Creating Your First Plugin

**Step 1:** Create directory and file
```bash
mkdir -p plugins/my-theme
touch plugins/my-theme/init.lua
```

**Step 2:** Add your theme to `init.lua`
```lua
local M = {}

M.name = "my-theme"
M.type = "theme"

-- Define colors
M.foreground = "#ffffff"
M.background = "#000000"
M.ansi = {
    "#000000", "#ff0000", "#00ff00", "#ffff00",
    "#0000ff", "#ff00ff", "#00ffff", "#ffffff"
}
M.brights = {
    "#808080", "#ff8080", "#80ff80", "#ffff80",
    "#8080ff", "#ff80ff", "#80ffff", "#ffffff"
}

function M.setup()
    return M
end

return M
```

**Step 3:** Use it!
```lua
-- In wezterm.lua
config.colors = Themes["my-theme"]
```

### 3. Creating a Utility Plugin

**Step 1:** Create the plugin
```bash
mkdir -p plugins/my-utils
```

**Step 2:** Create `plugins/my-utils/init.lua`
```lua
local M = {}

M.name = "my-utils"
M.version = "1.0.0"

function M.greet()
    return "Hello from my utils!"
end

function M.setup()
    print("My utils loaded!")
    return M
end

return M
```

**Step 3:** Use it in `wezterm.lua`
```lua
local my_utils = PluginManager.get_plugin("my-utils")
if my_utils then
    print(my_utils.greet())
end
```

## Common Tasks

### Disable a Plugin

Edit `plugins/plugins.lua`:
```lua
plugin_manager.setup({
    auto_load = true,
    disabled_plugins = { "plugin-name" },
})
```

### Load Only Specific Plugins

Edit `plugins/plugins.lua`:
```lua
plugin_manager.setup({
    auto_load = true,
    enabled_plugins = { "cyberdream", "my-plugin" },
})
```

### Check Loaded Plugins

```lua
-- In wezterm.lua
for name, plugin in pairs(PluginManager.get_loaded_plugins()) do
    print(name .. ": " .. (plugin.loaded and "✓" or "✗"))
end
```

### Switch Themes

```lua
-- Get all available themes
local themes = PluginManager.get_themes()

-- Try multiple themes with fallback
if themes["my-theme"] then
    config.colors = themes["my-theme"]
elseif themes["cyberdream"] then
    config.colors = themes["cyberdream"]
else
    config.color_scheme = "Dracula (Official)"
end
```

## File Structure Reference

```
weztermdot/
├── wezterm.lua              # Main config - use plugins here
├── lib/
│   ├── lib.lua             # Utility functions
│   └── plugin_manager.lua  # Plugin system (don't edit)
└── plugins/
    ├── plugins.lua         # Plugin configuration
    ├── cyberdream/         # Example theme plugin
    │   ├── init.lua
    │   └── ...
    └── your-plugin/        # Your plugin
        └── init.lua        # Must have this file
```

## Plugin File Names

The plugin manager looks for:
- `init.lua` in your plugin directory, OR
- `[plugin-name].lua` matching the directory name

Example:
```
plugins/my-theme/init.lua        ✓ Works
plugins/my-theme/my-theme.lua    ✓ Also works
plugins/my-theme/theme.lua       ✗ Won't work
```

## Global Variables

Available in `wezterm.lua` after loading plugins:

- `PluginManager` - The plugin manager instance
- `Plugins` - All loaded plugin modules
- `Themes` - All theme plugins
- `Windows` - Boolean for platform detection

## Troubleshooting

### Plugin not loading?

1. Check file name: must be `init.lua` or `[plugin-name].lua`
2. Check it's in a subdirectory of `plugins/`
3. Check for Lua syntax errors
4. Look for error messages when WezTerm starts

### Can't access plugin?

```lua
local my_plugin = PluginManager.get_plugin("my-plugin")
if not my_plugin then
    print("Plugin 'my-plugin' not found!")
elseif not my_plugin.loaded then
    print("Plugin failed to load: " .. (my_plugin.error or "unknown"))
else
    -- Plugin is ready to use
    my_plugin.some_function()
end
```

## Next Steps

- 📖 Read [README.md](README.md) for complete documentation
- 📝 See [PLUGIN_TEMPLATE.md](PLUGIN_TEMPLATE.md) for detailed templates
- 💡 Check [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md) for advanced examples
- 🎨 Look at `plugins/cyberdream/` for a real theme example
- 🔧 Look at `plugins/example-plugin/` for a utility example

## Need Help?

1. Check existing plugins in `plugins/` directory
2. Review plugin manager source in `lib/plugin_manager.lua`
3. Read the comprehensive documentation in README.md

## Tips

✅ **DO:**
- Keep plugins focused on one task
- Add metadata (name, version, description)
- Include a `setup()` function
- Document your plugin with a README

❌ **DON'T:**
- Pollute global namespace
- Forget to return the module table
- Make plugins depend on specific load order (use dependencies field)
- Skip error handling

Happy plugin development! 🚀
