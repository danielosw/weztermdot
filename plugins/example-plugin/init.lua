-- Example Plugin - Demonstrates the plugin system
-- This is a sample plugin showing the basic structure

local M = {}

-- Plugin metadata
M.name = "example-plugin"
M.version = "1.0.0"
M.description = "Example plugin demonstrating the plugin management system"
M.author = "WezTerm Plugin System"
M.type = "utility"
M.dependencies = {}

-- Configuration
M.config = {
    enabled = true,
    verbose = false,
    greeting = "Hello from Example Plugin!",
}

-- Setup function
function M.setup(opts)
    opts = opts or {}
    
    -- Merge options
    for key, value in pairs(opts) do
        M.config[key] = value
    end
    
    -- Initialization - only log if verbose mode is enabled
    if M.config.enabled and M.config.verbose then
        print("✓ " .. M.name .. " loaded: " .. M.config.greeting)
    end
    
    return M
end

-- Example function
function M.greet(name)
    return "Hello, " .. (name or "World") .. "!"
end

-- Example function to demonstrate utility
function M.get_info()
    return {
        name = M.name,
        version = M.version,
        description = M.description,
    }
end

return M
