-- Mock Love2D functions for testing
local love_mock = {}

-- Graphics module mock
love_mock.graphics = {
    newImage = function(path)
        return {
            getWidth = function() return 100 end,
            getHeight = function() return 100 end
        }
    end,
    getWidth = function() return 800 end,
    getHeight = function() return 600 end,
    setColor = function() end,
    circle = function() end,
    rectangle = function() end,
    draw = function() end,
    push = function() end,
    pop = function() end,
    translate = function() end,
    rotate = function() end,
    scale = function() end,
    newFont = function(size)
        return {
            getWidth = function(text) return #text * (size or 12) * 0.6 end,
            getHeight = function() return size or 12 end
        }
    end,
    getFont = function()
        return {
            getWidth = function(text) return #text * 12 * 0.6 end,
            getHeight = function() return 12 end
        }
    end,
    setFont = function() end,
    print = function() end
}

-- Timer module mock
love_mock.timer = {
    getTime = function() return 1.0 end
}

-- Store original math.random before mocking
local original_math_random = math.random

-- Math module mock
love_mock.math = {
    random = function(min, max)
        if not min then return original_math_random() end
        if not max then return original_math_random(min) end
        return original_math_random(min, max)
    end
}

-- Set up global love object for tests
function love_mock.setup()
    _G.love = love_mock
    -- Also mock math.random to use love.math.random for consistency
    _G.math.random = love_mock.math.random
end

return love_mock