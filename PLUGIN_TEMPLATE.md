# Plugin Template

This template helps you create a new plugin for the WezTerm configuration.

## Quick Start

1. Copy the template directory structure below to `plugins/your-plugin-name/`
2. Customize the `init.lua` file with your plugin logic
3. The plugin will be automatically discovered and loaded

## Directory Structure

```
plugins/
└── your-plugin-name/
    ├── init.lua              # Main plugin file (required)
    ├── README.md             # Plugin documentation (recommended)
    └── [additional files]    # Optional: other Lua files
```

## Template: Basic Plugin

```lua
-- plugins/your-plugin-name/init.lua

local M = {}

-- ============================================================================
-- Plugin Metadata (Optional but Recommended)
-- ============================================================================

M.name = "your-plugin-name"
M.version = "1.0.0"
M.description = "Brief description of what your plugin does"
M.author = "Your Name"
M.type = "utility"  -- Options: "theme", "utility", "config", "keybinds", etc.
M.dependencies = {} -- List of other plugin names this plugin requires

-- ============================================================================
-- Plugin Configuration
-- ============================================================================

M.config = {
    -- Default configuration values
    enabled = true,
    option1 = "default_value",
    option2 = true,
}

-- ============================================================================
-- Setup Function (Called when plugin is loaded)
-- ============================================================================

function M.setup(opts)
    opts = opts or {}
    
    -- Merge user options with defaults
    for key, value in pairs(opts) do
        M.config[key] = value
    end
    
    -- Plugin initialization code
    print("✓ " .. M.name .. " v" .. M.version .. " loaded")
    
    -- Initialize your plugin here
    
    return M
end

-- ============================================================================
-- Plugin Functions
-- ============================================================================

-- Add your plugin functions here
function M.your_function()
    -- Implementation
end

-- ============================================================================
-- Return the module
-- ============================================================================

return M
```

## Template: Theme Plugin

```lua
-- plugins/your-theme-name/init.lua

local M = {}

-- ============================================================================
-- Plugin Metadata
-- ============================================================================

M.name = "your-theme-name"
M.version = "1.0.0"
M.description = "Your custom WezTerm theme"
M.author = "Your Name"
M.type = "theme"

-- ============================================================================
-- Color Definitions
-- ============================================================================

M.foreground = "#ffffff"
M.background = "#000000"

M.cursor_bg = "#ffffff"
M.cursor_fg = "#000000"
M.cursor_border = "#ffffff"

M.selection_fg = "#ffffff"
M.selection_bg = "#333333"

M.scrollbar_thumb = "#333333"
M.split = "#333333"

-- Standard ANSI colors
M.ansi = {
    "#000000",  -- black
    "#ff0000",  -- red
    "#00ff00",  -- green
    "#ffff00",  -- yellow
    "#0000ff",  -- blue
    "#ff00ff",  -- magenta
    "#00ffff",  -- cyan
    "#ffffff",  -- white
}

-- Bright ANSI colors
M.brights = {
    "#808080",  -- bright black
    "#ff8080",  -- bright red
    "#80ff80",  -- bright green
    "#ffff80",  -- bright yellow
    "#8080ff",  -- bright blue
    "#ff80ff",  -- bright magenta
    "#80ffff",  -- bright cyan
    "#ffffff",  -- bright white
}

-- Indexed colors (optional)
M.indexed = {
    [16] = "#ffaa00",
    [17] = "#ff5500",
}

-- Tab bar colors (optional)
M.tab_bar = {
    background = "#000000",
    active_tab = {
        bg_color = "#333333",
        fg_color = "#ffffff",
    },
    inactive_tab = {
        bg_color = "#1a1a1a",
        fg_color = "#808080",
    },
    inactive_tab_hover = {
        bg_color = "#262626",
        fg_color = "#ffffff",
    },
    new_tab = {
        bg_color = "#1a1a1a",
        fg_color = "#808080",
    },
    new_tab_hover = {
        bg_color = "#262626",
        fg_color = "#ffffff",
    },
}

-- ============================================================================
-- Setup Function
-- ============================================================================

function M.setup(opts)
    opts = opts or {}
    
    -- Add any theme initialization logic here
    
    return M
end

-- ============================================================================
-- Helper Functions (Optional)
-- ============================================================================

function M.apply_to_config(config)
    config.colors = M
    return config
end

return M
```

## Template: Multi-file Plugin

For complex plugins with multiple files:

```
plugins/
└── your-plugin-name/
    ├── init.lua      # Main entry point
    ├── config.lua    # Configuration options
    ├── utils.lua     # Helper functions
    └── README.md     # Documentation
```

### init.lua
```lua
local M = {}

M.name = "your-plugin-name"
M.version = "1.0.0"

-- Load submodules
M.config = require("plugins.your-plugin-name.config")
M.utils = require("plugins.your-plugin-name.utils")

function M.setup(opts)
    opts = opts or {}
    
    -- Initialize with submodules
    M.config.apply(opts)
    
    return M
end

return M
```

### config.lua
```lua
local M = {}

M.defaults = {
    enabled = true,
    option1 = "value1",
}

function M.apply(opts)
    -- Apply configuration
    for key, value in pairs(opts) do
        M.defaults[key] = value
    end
end

return M
```

### utils.lua
```lua
local M = {}

function M.helper_function()
    -- Utility functions
end

return M
```

## Usage Examples

### In wezterm.lua

```lua
-- Using your plugin
local your_plugin = PluginManager.get_plugin("your-plugin-name")
your_plugin.your_function()

-- Using your theme
local themes = PluginManager.get_themes()
config.colors = themes["your-theme-name"]
```

### With Configuration

```lua
-- In plugins/plugins.lua, before setup:
-- Configure a specific plugin after it loads
local plugin_manager = require("lib.plugin_manager")
plugin_manager.setup({
    auto_load = true,
})

-- Get and configure your plugin
local your_plugin = plugin_manager.get_plugin("your-plugin-name")
if your_plugin then
    your_plugin.setup({
        option1 = "custom_value",
        option2 = false,
    })
end
```

## Best Practices

1. **Always include metadata** - Name, version, description help users understand your plugin
2. **Provide a setup() function** - Even if it does nothing, it's expected by the plugin manager
3. **Document your plugin** - Include a README.md with usage examples
4. **Handle errors gracefully** - Use pcall() for risky operations
5. **Follow Lua conventions** - Use local variables, return tables, avoid global pollution
6. **Test on multiple platforms** - Check Windows and Unix compatibility if applicable
7. **Use semantic versioning** - Major.Minor.Patch (e.g., 1.0.0)
8. **Keep it focused** - One plugin should do one thing well

## Testing Your Plugin

1. Place your plugin in the `plugins/` directory
2. Reload WezTerm configuration
3. Check for load messages in WezTerm output
4. Test plugin functions in `wezterm.lua`
5. Try disabling the plugin to ensure it fails gracefully

## Common Issues

### Plugin not loading
- Check file name: must be `init.lua` or `[plugin-name].lua`
- Verify directory structure
- Look for syntax errors in Lua code
- Check if plugin is in `disabled_plugins` list

### Module not found errors
- Use correct require paths: `require("plugins.your-plugin.module")`
- Ensure all referenced files exist
- Check for typos in module names

### Plugin conflicts
- Check `dependencies` array
- Avoid global variable pollution
- Use local variables when possible
- Namespace your plugin functions

## Need Help?

- Check the main README.md for API documentation
- Look at existing plugins (like `cyberdream`) for examples
- Review the plugin manager source code in `lib/plugin_manager.lua`
