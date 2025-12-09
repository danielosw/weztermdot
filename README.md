# WezTerm Configuration with Plugin Management

A modular WezTerm configuration with a powerful plugin management system.

## Features

- 🔌 **Plugin Management System**: Automatic plugin discovery and loading
- 🎨 **Theme Support**: Easy theme management with plugin system
- 🔧 **Modular Configuration**: Organized structure for maintainability
- 🚀 **Auto-Discovery**: Plugins are automatically detected from the plugins directory
- ⚙️ **Flexible Configuration**: Enable/disable plugins as needed

## Directory Structure

```
.
├── wezterm.lua           # Main WezTerm configuration
├── lib/
│   ├── lib.lua          # Utility functions
│   └── plugin_manager.lua # Plugin management system
└── plugins/
    ├── plugins.lua      # Plugin initialization
    └── [plugin-name]/   # Individual plugin directories
        ├── init.lua     # Plugin entry point
        └── ...          # Plugin files
```

## Plugin Management System

### How It Works

The plugin manager automatically:
1. Scans the `plugins/` directory for plugin folders
2. Loads plugins that have an `init.lua` or `[plugin-name].lua` file
3. Initializes plugins with their `setup()` function if available
4. Makes plugins accessible through global variables

### Using Plugins

Plugins are automatically loaded when WezTerm starts. You can access them through:

```lua
-- Get all loaded plugins
local all_plugins = PluginManager.get_loaded_plugins()

-- Get a specific plugin
local my_plugin = PluginManager.get_plugin("plugin-name")

-- Get all themes
local themes = PluginManager.get_themes()
```

### Configuring the Plugin Manager

Edit `plugins/plugins.lua` to configure plugin loading:

```lua
plugin_manager.setup({
    plugins_dir = "plugins",  -- Directory to scan for plugins
    auto_load = true,         -- Automatically load plugins on startup
    
    -- Load only specific plugins (leave empty to load all)
    enabled_plugins = {},
    
    -- Disable specific plugins
    disabled_plugins = { "plugin-to-disable" },
})
```

## Creating a Plugin

### Basic Plugin Structure

Create a new directory in `plugins/` with an `init.lua` file:

```
plugins/
└── my-plugin/
    └── init.lua
```

### Plugin Template

```lua
-- plugins/my-plugin/init.lua

local M = {}

-- Plugin metadata (optional but recommended)
M.name = "my-plugin"
M.version = "1.0.0"
M.description = "Description of my plugin"
M.author = "Your Name"
M.type = "theme" -- or "utility", "config", etc.
M.dependencies = {} -- List of required plugins

-- Setup function (called when plugin is loaded)
function M.setup(opts)
    opts = opts or {}
    
    -- Plugin initialization code here
    print("My plugin loaded!")
    
    return M
end

-- Plugin functionality
function M.some_function()
    -- Your code here
end

return M
```

### Theme Plugin Example

For a theme plugin, return a table with WezTerm color definitions:

```lua
local M = {}

M.name = "my-theme"
M.type = "theme"
M.description = "My custom theme"

-- WezTerm color scheme
M.foreground = "#ffffff"
M.background = "#000000"
M.cursor_bg = "#ffffff"
M.cursor_fg = "#000000"
M.cursor_border = "#ffffff"

M.ansi = {
    "#000000", -- black
    "#ff0000", -- red
    "#00ff00", -- green
    "#ffff00", -- yellow
    "#0000ff", -- blue
    "#ff00ff", -- magenta
    "#00ffff", -- cyan
    "#ffffff", -- white
}

M.brights = {
    "#808080", -- bright black
    "#ff8080", -- bright red
    "#80ff80", -- bright green
    "#ffff80", -- bright yellow
    "#8080ff", -- bright blue
    "#ff80ff", -- bright magenta
    "#80ffff", -- bright cyan
    "#ffffff", -- bright white
}

function M.setup(opts)
    opts = opts or {}
    return M
end

return M
```

### Using Your Plugin

Once created, your plugin will be automatically discovered and loaded. Access it via:

```lua
-- In wezterm.lua
local my_plugin = PluginManager.get_plugin("my-plugin")

-- For themes
local themes = PluginManager.get_themes()
config.colors = themes["my-theme"]
```

## Example: Cyberdream Theme Plugin

The included `cyberdream` plugin demonstrates the plugin system:

```lua
-- Using the cyberdream theme
local themes = PluginManager.get_themes()
config.colors = themes["cyberdream"]

-- Or access the plugin directly
local cyberdream = PluginManager.get_plugin("cyberdream")
config.colors = cyberdream.get_dark()  -- Use dark variant
config.colors = cyberdream.get_light() -- Use light variant
```

## Advanced Usage

### Plugin with Multiple Files

Organize complex plugins with multiple files:

```
plugins/
└── my-plugin/
    ├── init.lua      # Main entry point
    ├── config.lua    # Configuration
    ├── utils.lua     # Utilities
    └── theme.lua     # Theme data
```

In `init.lua`:

```lua
local M = {}

M.name = "my-plugin"
M.config = require("plugins.my-plugin.config")
M.utils = require("plugins.my-plugin.utils")
M.theme = require("plugins.my-plugin.theme")

function M.setup(opts)
    opts = opts or {}
    -- Initialize using other modules
    M.config.apply(opts)
    return M
end

return M
```

### Conditional Plugin Loading

Disable plugins based on platform or conditions:

```lua
-- In plugins/plugins.lua
local disabled = {}

-- Disable certain plugins on Windows
if Windows then
    table.insert(disabled, "unix-only-plugin")
end

plugin_manager.setup({
    disabled_plugins = disabled,
})
```

## Security Considerations

The plugin manager implements several security measures:

- **Path Sanitization**: Plugin directory paths are sanitized to prevent command injection
- **Directory Validation**: Only paths starting with "plugins" are allowed
- **Pattern Validation**: Plugin names must be alphanumeric with dashes/underscores only
- **No Directory Traversal**: ".." sequences are blocked to prevent path traversal attacks

⚠️ **Important**: Only load plugins from trusted sources. Plugins execute with the same privileges as WezTerm.

### Best Practices

1. **Review plugin code** before using it
2. **Keep plugins updated** to the latest versions
3. **Use the `disabled_plugins`** option to disable untrusted plugins
4. **Monitor plugin output** with `verbose = true` during testing

## API Reference

### PluginManager Methods

- `setup(opts)` - Configure and initialize the plugin manager
- `discover_plugins()` - Scan for available plugins
- `load_plugins()` - Load all enabled plugins
- `get_plugin(name)` - Get a specific plugin by name
- `get_loaded_plugins()` - Get all loaded plugins
- `get_available_plugins()` - Get list of discovered plugins
- `get_plugin_modules()` - Get all plugin modules
- `get_themes()` - Get all theme plugins

### Configuration Options

- `plugins_dir` - Directory to scan for plugins (default: "plugins")
- `auto_load` - Automatically load plugins on startup (default: true)
- `enabled_plugins` - Array of plugin names to load (empty = all)
- `disabled_plugins` - Array of plugin names to skip
- `verbose` - Enable detailed logging output (default: false)

### Plugin Metadata Fields

- `name` - Plugin name (string)
- `version` - Plugin version (string)
- `description` - Short description (string)
- `author` - Author name (string)
- `type` - Plugin type: "theme", "utility", "config", etc.
- `dependencies` - Array of required plugin names

### Global Variables

- `PluginManager` - The plugin manager instance
- `Plugins` - Table of all loaded plugin modules
- `Themes` - Table of all theme plugins
- `Windows` - Boolean indicating if running on Windows

## Contributing

When adding a plugin:

1. Create a new directory in `plugins/`
2. Add an `init.lua` file with plugin metadata
3. Implement the `setup()` function
4. Document your plugin with a README.md
5. Test with both enabled and disabled states

## License

See LICENSE file for details.
