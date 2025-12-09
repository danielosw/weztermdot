-- Plugin Manager for WezTerm Configuration
-- Provides automatic plugin discovery, loading, and management
-- 
-- Note: This module can use the global Windows variable if available
-- (set by lib/lib.lua) but will fallback to detecting the platform
-- using package.config if not present.

local M = {}

-- Configuration
M.config = {
    plugins_dir = "plugins",
    auto_load = true,
    enabled_plugins = {}, -- empty means all plugins are enabled
    disabled_plugins = {}, -- plugins to explicitly disable
    verbose = false, -- enable logging output
}

-- Store loaded plugins
M.loaded_plugins = {}
M.available_plugins = {}

-- Helper function to check if a file exists
local function file_exists(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Helper function to check if a directory exists
local function dir_exists(path)
    local ok, err, code = os.rename(path, path)
    if not ok then
        if code == 13 then
            -- Permission denied, but it exists
            return true
        end
    end
    return ok
end

-- Helper function to check if running on Windows
local function is_windows()
    -- Check if Windows global is set (from lib.lib)
    if type(Windows) ~= "nil" then
        return Windows
    end
    -- Fallback: check package.config separator
    return package.config:sub(1,1) == '\\'
end

-- Helper function to sanitize path for shell commands
local function sanitize_path(path)
    -- Remove potentially dangerous characters
    -- Keep only alphanumeric, -, _, /, \, and .
    local sanitized = path:gsub('[^%w%-%_/%\\%.]', '')
    
    -- Prevent directory traversal by removing .. sequences
    sanitized = sanitized:gsub('%.%.', '')
    
    -- Normalize path separators based on platform
    if is_windows() then
        sanitized = sanitized:gsub('/', '\\')
    else
        sanitized = sanitized:gsub('\\', '/')
    end
    
    return sanitized
end

-- Helper function to scan directory for plugins
-- Note: This uses shell commands as a fallback since LuaFileSystem is not
-- available by default in WezTerm's Lua environment. The path is sanitized
-- to mitigate command injection risks, but this is not ideal for production.
-- A future improvement would be to use native WezTerm file system APIs if available.
local function scan_plugins_dir(base_path)
    local plugins = {}
    
    -- Validate that base_path doesn't try to escape the intended directory
    if base_path:match("%.%.") then
        if M.config.verbose then
            print("Warning: Invalid plugin directory path (contains ..)")
        end
        return plugins
    end
    
    -- Sanitize path to prevent command injection
    local safe_path = sanitize_path(base_path)
    
    -- Additional validation: ensure path is what we expect
    if not safe_path:match("^plugins") then
        if M.config.verbose then
            print("Warning: Plugin directory path does not start with 'plugins'")
        end
        return plugins
    end
    
    local handle
    local success, err
    
    -- Try to open directory using different methods
    if is_windows() then
        -- Windows: use dir command
        success, handle = pcall(io.popen, 'dir "' .. safe_path .. '" /b /ad 2>nul')
    else
        -- Unix-like: use ls command
        success, handle = pcall(io.popen, 'ls -1 "' .. safe_path .. '" 2>/dev/null')
    end
    
    if not success or not handle then
        if M.config.verbose then
            print("Warning: Could not scan plugins directory: " .. tostring(err))
        end
        return plugins
    end
    
    for dir in handle:lines() do
        -- Skip hidden directories and special entries
        if dir ~= "." and dir ~= ".." and not dir:match("^%.") then
            -- Additional validation: only accept alphanumeric, dash, underscore
            if dir:match("^[%w%-_]+$") then
                local plugin_path = base_path .. "/" .. dir
                -- Check if it's a directory and has an init.lua or plugin_name.lua
                if dir_exists(plugin_path) then
                    local init_path = plugin_path .. "/init.lua"
                    local plugin_file = plugin_path .. "/" .. dir .. ".lua"
                    
                    if file_exists(init_path) or file_exists(plugin_file) then
                        table.insert(plugins, dir)
                    end
                end
            end
        end
    end
    
    handle:close()
    return plugins
end

-- Check if a plugin should be loaded
local function should_load_plugin(plugin_name)
    -- Check if explicitly disabled
    for _, disabled in ipairs(M.config.disabled_plugins) do
        if disabled == plugin_name then
            return false
        end
    end
    
    -- If enabled_plugins is empty, load all (except disabled)
    if #M.config.enabled_plugins == 0 then
        return true
    end
    
    -- Check if explicitly enabled
    for _, enabled in ipairs(M.config.enabled_plugins) do
        if enabled == plugin_name then
            return true
        end
    end
    
    return false
end

-- Load a single plugin
local function load_plugin(plugin_name, base_path)
    local plugin_path = base_path .. "/" .. plugin_name
    local plugin_data = {
        name = plugin_name,
        path = plugin_path,
        loaded = false,
        error = nil,
        module = nil,
        metadata = {},
    }
    
    -- Try to load init.lua first, then plugin_name.lua
    local init_path = "plugins." .. plugin_name .. ".init"
    local plugin_module_path = "plugins." .. plugin_name .. "." .. plugin_name
    
    local success, result = pcall(require, init_path)
    if not success then
        success, result = pcall(require, plugin_module_path)
    end
    
    if success then
        plugin_data.loaded = true
        plugin_data.module = result
        
        -- Extract metadata if available
        if type(result) == "table" then
            plugin_data.metadata = {
                name = result.name or plugin_name,
                version = result.version or "unknown",
                description = result.description or "",
                author = result.author or "",
                dependencies = result.dependencies or {},
            }
            
            -- Call setup function if exists
            if type(result.setup) == "function" then
                local setup_success, setup_error = pcall(result.setup)
                if not setup_success then
                    plugin_data.error = "Setup failed: " .. tostring(setup_error)
                end
            end
        end
    else
        plugin_data.error = tostring(result)
    end
    
    return plugin_data
end

-- Discover all available plugins
function M.discover_plugins()
    local base_path = M.config.plugins_dir
    M.available_plugins = scan_plugins_dir(base_path)
    return M.available_plugins
end

-- Load all enabled plugins
function M.load_plugins()
    local base_path = M.config.plugins_dir
    
    -- Discover plugins if not already done
    if #M.available_plugins == 0 then
        M.discover_plugins()
    end
    
    -- Load each plugin
    for _, plugin_name in ipairs(M.available_plugins) do
        if should_load_plugin(plugin_name) then
            local plugin_data = load_plugin(plugin_name, base_path)
            M.loaded_plugins[plugin_name] = plugin_data
            
            if M.config.verbose then
                if plugin_data.loaded then
                    print("✓ Loaded plugin: " .. plugin_name)
                else
                    print("✗ Failed to load plugin: " .. plugin_name)
                    if plugin_data.error then
                        print("  Error: " .. plugin_data.error)
                    end
                end
            end
        end
    end
    
    return M.loaded_plugins
end

-- Get a specific loaded plugin
function M.get_plugin(plugin_name)
    return M.loaded_plugins[plugin_name]
end

-- Get all loaded plugins
function M.get_loaded_plugins()
    return M.loaded_plugins
end

-- Get all available plugins (discovered but not necessarily loaded)
function M.get_available_plugins()
    return M.available_plugins
end

-- Get plugin modules (for themes, configs, etc.)
function M.get_plugin_modules()
    local modules = {}
    for name, plugin in pairs(M.loaded_plugins) do
        if plugin.loaded and plugin.module then
            modules[name] = plugin.module
        end
    end
    return modules
end

-- Get all theme plugins
function M.get_themes()
    local themes = {}
    for name, plugin in pairs(M.loaded_plugins) do
        if plugin.loaded and plugin.module then
            -- Check if it's a theme (has color definitions)
            if type(plugin.module) == "table" and 
               (plugin.module.foreground or plugin.module.background or 
                plugin.module.ansi or plugin.metadata.type == "theme") then
                themes[name] = plugin.module
            end
        end
    end
    return themes
end

-- Configure the plugin manager
function M.setup(opts)
    opts = opts or {}
    
    -- Merge options with defaults
    if opts.plugins_dir then
        M.config.plugins_dir = opts.plugins_dir
    end
    if opts.auto_load ~= nil then
        M.config.auto_load = opts.auto_load
    end
    if opts.enabled_plugins then
        M.config.enabled_plugins = opts.enabled_plugins
    end
    if opts.disabled_plugins then
        M.config.disabled_plugins = opts.disabled_plugins
    end
    if opts.verbose ~= nil then
        M.config.verbose = opts.verbose
    end
    
    -- Auto-load plugins if configured
    if M.config.auto_load then
        M.discover_plugins()
        M.load_plugins()
    end
    
    return M
end

-- Initialize with defaults
function M.init()
    return M.setup()
end

return M
