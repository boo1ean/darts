-- Luacheck configuration for Love2D darts game

-- Define standard Love2D globals
std = "max"
globals = {
    "love",
}

-- Allow reading these globals
read_globals = {
    -- Love2D modules
    "love.graphics",
    "love.window",
    "love.timer",
    "love.event",
    "love.keyboard",
    "love.mouse",
    "love.audio",
    "love.filesystem",
    "love.system",
    "love.math",
    
    -- Love2D callbacks
    "love.load",
    "love.update",
    "love.draw",
    "love.mousepressed",
    "love.mousereleased",
    "love.keypressed",
    "love.keyreleased",
    "love.quit",
    
    -- Standard Lua
    "math",
    "table",
    "string",
    "io",
    "os",
    "debug",
    "package",
    "require",
    "assert",
    "error",
    "ipairs",
    "pairs",
    "next",
    "print",
    "type",
    "tostring",
    "tonumber",
    "setmetatable",
    "getmetatable",
    "rawget",
    "rawset",
    "pcall",
    "xpcall",
    "select",
    "unpack",
}

-- Project-specific settings
files = {
    -- Ignore specific directories if needed
    exclude_files = {
        ".luacheckrc",
    }
}

-- Line length
max_line_length = 120

-- Allow unused arguments in functions (common in Love2D callbacks)
unused_args = false

-- Allow unused loop variables (common pattern)
unused_secondaries = false

-- Ignore certain warnings
ignore = {
    "122", -- Setting read-only field (Love2D callbacks)
    "212", -- Unused argument
    "213", -- Unused loop variable
    "311", -- Value assigned to a local variable is unused
    "611", -- Line contains only whitespace
    "612", -- Line contains trailing whitespace
    "614", -- Trailing whitespace in comment
}

-- Module-specific overrides
files["main.lua"] = {
    -- Main file can define globals
    allow_defined_top = true,
}

-- Test file patterns
files["tests/**/*_spec.lua"] = {
    read_globals = {
        "describe", "it", "before_each", "after_each", "setup", "teardown",
        "assert", "spy", "stub", "mock", "pending"
    }
}

files["**/*Test.lua"] = {
    -- Test files might have different rules
    ignore = {"111", "112", "113"}, -- Allow globals in tests
}