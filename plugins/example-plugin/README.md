# Example Plugin

This is an example plugin that demonstrates the plugin management system.

## Features

- Shows basic plugin structure
- Demonstrates metadata usage
- Includes setup function
- Provides example functions

## Usage

The plugin is automatically loaded. Access it via:

```lua
local example = PluginManager.get_plugin("example-plugin")
print(example.greet("WezTerm"))  -- Output: Hello, WezTerm!

local info = example.get_info()
print(info.name)  -- Output: example-plugin
```

## Configuration

Configure the plugin in `plugins/plugins.lua`:

```lua
local example = PluginManager.get_plugin("example-plugin")
if example then
    example.setup({
        enabled = true,
        greeting = "Custom greeting!",
    })
end
```

## API

### Functions

- `greet(name)` - Returns a greeting message
- `get_info()` - Returns plugin metadata

### Configuration Options

- `enabled` (boolean) - Enable/disable the plugin (default: true)
- `greeting` (string) - Custom greeting message

## Development

This plugin serves as a template for creating new plugins. See `PLUGIN_TEMPLATE.md` in the root directory for more details.
