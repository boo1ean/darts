-- =============================================================================
-- PULSE SYSTEM
-- =============================================================================
local Config = require('config')

local PulseSystem = {}

function PulseSystem.update(dot, gameState, dt)
    -- Calculate pulsing size using sine wave
    local pulseValue = math.sin(gameState.time * Config.PULSE_SPEED * math.pi * 2)
    local pulseRatio = (pulseValue + 1) / 2  -- Convert from [-1,1] to [0,1]
    
    -- Interpolate between minimum and maximum size
    local minSize = Config.DOT_SIZE * Config.PULSE_MIN_RATIO
    dot.size = minSize + (Config.DOT_SIZE - minSize) * pulseRatio
end

return PulseSystem 
